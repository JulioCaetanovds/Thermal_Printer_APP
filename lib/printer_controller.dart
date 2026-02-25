import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterController extends ChangeNotifier {
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? _txCharacteristic;
  List<ScanResult> scanResults = [];

  bool isScanning = false;
  bool isPrinting = false;
  bool isProcessing = false; 

  File? selectedImage; 
  Uint8List? previewBytes; 
  img.Image? _processedImageRaw; 

  double contrast = 1.0;
  double brightness = 1.0; 

  String statusMessage = "Desconectado";

  final _picker = ImagePicker();
  
  // --- ADICIONADO: controle de isolates concorrentes ---
  int _previewTaskId = 0;

  Future<void> init() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
      Permission.camera,
    ].request();

    FlutterBluePlus.scanResults.listen((results) {
      scanResults = results;
      notifyListeners();
    });

    FlutterBluePlus.isScanning.listen((state) {
      isScanning = state;
      notifyListeners();
    });

    await _tryAutoConnect();
  }

  Future<void> startScan() async {
    if (isScanning) return;
    scanResults.clear();
    statusMessage = "Buscando...";
    notifyListeners();

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    } catch (e) {
      statusMessage = "Erro ao buscar: $e";
      notifyListeners();
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    try {
      statusMessage = "Conectando...";
      notifyListeners();

      await device.connect();
      connectedDevice = device;

      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var char in service.characteristics) {
          if (char.properties.write || char.properties.writeWithoutResponse) {
            _txCharacteristic = char;
            break;
          }
        }
      }
      statusMessage = "Conectado a ${device.platformName}";

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_device_id', device.remoteId.str);
    } catch (e) {
      statusMessage = "Erro conexão: $e";
      connectedDevice = null;
    }
    notifyListeners();
  }

  Future<void> disconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_device_id');

    await connectedDevice?.disconnect();
    connectedDevice = null;
    _txCharacteristic = null;
    statusMessage = "Desconectado";
    notifyListeners();
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) await _cropImage(File(image.path));
  }

  Future<void> takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) await _cropImage(File(image.path));
  }

  Future<void> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recortar & Ajustar',
          toolbarColor: const Color(0xFF0D1B50),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          showCropGrid: true,
        ),
        IOSUiSettings(
          title: 'Recortar',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
      ],
    );

    if (croppedFile != null) {
      selectedImage = File(croppedFile.path);
      contrast = 1.2;
      brightness = 0.8; 
      await generatePreview(); 
    }
  }

  void updateParams(double newContrast, double newBrightness) {
    contrast = newContrast;
    brightness = newBrightness;
    notifyListeners();
  }

  Future<void> generatePreview() async {
    if (selectedImage == null) return;

    // --- ADICIONADO: incrementa ID para cancelar isolates antigos ---
    _previewTaskId++;
    final currentTaskId = _previewTaskId;

    isProcessing = true;
    notifyListeners();

    try {
      final rawBytes = await selectedImage!.readAsBytes();

      final result = await compute(processImageTask, {
        'bytes': rawBytes,
        'contrast': contrast,
        'brightness': brightness,
      });

      // --- ADICIONADO: verifica se é a requisição mais recente ---
      if (currentTaskId != _previewTaskId) return;

      _processedImageRaw = result['image'] as img.Image;
      previewBytes = result['pngBytes'] as Uint8List; 
    } catch (e) {
      statusMessage = "Erro no processamento: $e";
    } finally {
      if (currentTaskId == _previewTaskId) {
        isProcessing = false;
        notifyListeners();
      }
    }
  }

  Future<void> saveToGallery() async {
    if (previewBytes == null) return;

    try {
      statusMessage = "Salvando na galeria...";
      notifyListeners();

      await Gal.putImageBytes(previewBytes!);
      statusMessage = "Salvo na Galeria com sucesso!";
    } catch (e) {
      statusMessage = "Erro ao salvar: $e";
    } finally {
      notifyListeners();
    }
  }

  Future<void> printImage() async {
    if (connectedDevice == null || _txCharacteristic == null) {
      statusMessage = "Impressora não conectada";
      notifyListeners();
      return;
    }
    if (_processedImageRaw == null) {
      await generatePreview(); 
    }

    isPrinting = true;
    notifyListeners();

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      bytes += generator.reset();
      bytes += generator.image(_processedImageRaw!, align: PosAlign.center);
      bytes += generator.feed(3);

      await _sendBytesInChunks(bytes);
      statusMessage = "Impressão enviada!";
    } catch (e) {
      statusMessage = "Erro impressão: $e";
    } finally {
      isPrinting = false;
      notifyListeners();
    }
  }

  Future<void> _sendBytesInChunks(List<int> bytes) async {
    // --- ALTERADO: otimizado para buffer KP-1025 ---
    const int chunkSize = 128; 
    final bool canWriteWithoutResponse =
        _txCharacteristic!.properties.writeWithoutResponse;

    for (var i = 0; i < bytes.length; i += chunkSize) {
      var end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      final data = bytes.sublist(i, end);

      if (canWriteWithoutResponse) {
        await _txCharacteristic!.write(data, withoutResponse: true);
        await Future.delayed(const Duration(milliseconds: 15)); 
      } else {
        await _txCharacteristic!.write(data, withoutResponse: false);
      }
    }
  }

  Future<void> _tryAutoConnect() async {
    final prefs = await SharedPreferences.getInstance();
    final lastId = prefs.getString('last_device_id');
    if (lastId == null) return;

    try {
      statusMessage = "Reconectando automaticamente...";
      notifyListeners();

      final device = BluetoothDevice.fromId(lastId);
      // --- ALTERADO: timeout no auto connect ---
      await device.connect(timeout: const Duration(seconds: 4));
      await connect(device);
    } catch (e) {
      statusMessage = "Desconectado";
      notifyListeners();
    }
  }
}

Map<String, dynamic> processImageTask(Map<String, dynamic> params) {
  final Uint8List bytes = params['bytes'];
  final double contrast = params['contrast'];
  final double brightness = params['brightness'];
  
  // --- ALTERADO: cravado 384 pontos para 58mm ---
  final int targetWidth = 384; 

  img.Image? image = img.decodeImage(bytes);
  if (image == null) throw Exception("Falha ao decodificar imagem");

  image = img.copyResize(image, width: targetWidth);
  image = img.grayscale(image);
  
  // --- ADICIONADO: contraste agressivo antes do dithering ---
  image = img.contrast(image, contrast: 1.3);
  image = img.adjustColor(image, contrast: contrast, brightness: brightness);

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final int oldPixel = pixel.r.toInt();
      final int newPixel = oldPixel < 128 ? 0 : 255;
      final int error = oldPixel - newPixel;

      image.setPixelRgb(x, y, newPixel, newPixel, newPixel);

      if (x + 1 < image.width) _addError(image, x + 1, y, error * 7 ~/ 16);
      if (x - 1 >= 0 && y + 1 < image.height) {
        _addError(image, x - 1, y + 1, error * 3 ~/ 16);
      }
      if (y + 1 < image.height) _addError(image, x, y + 1, error * 5 ~/ 16);
      if (x + 1 < image.width && y + 1 < image.height) {
        _addError(image, x + 1, y + 1, error * 1 ~/ 16);
      }
    }
  }

  return {'image': image, 'pngBytes': Uint8List.fromList(img.encodePng(image))};
}

void _addError(img.Image image, int x, int y, int errorAmount) {
  final pixel = image.getPixel(x, y);
  int newVal = pixel.r.toInt() + errorAmount;
  newVal = newVal.clamp(0, 255);
  image.setPixelRgb(x, y, newVal, newVal, newVal);
}