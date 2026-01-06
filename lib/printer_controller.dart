import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PrinterController extends ChangeNotifier {
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? _txCharacteristic;
  List<ScanResult> scanResults = [];

  bool isScanning = false;
  bool isPrinting = false;
  bool isProcessing = false; // Novo: indica processamento de imagem

  File? selectedImage; // Imagem original colorida
  Uint8List? previewBytes; // Imagem processada (BW) para preview
  img.Image? _processedImageRaw; // Imagem processada em memória para envio

  // Parametros de ajuste
  double contrast = 1.0;
  double brightness = 1.0; // 1.0 = original

  String statusMessage = "Desconectado";

  final _picker = ImagePicker();

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
    } catch (e) {
      statusMessage = "Erro conexão: $e";
      connectedDevice = null;
    }
    notifyListeners();
  }

  Future<void> disconnect() async {
    await connectedDevice?.disconnect();
    connectedDevice = null;
    _txCharacteristic = null;
    statusMessage = "Desconectado";
    notifyListeners();
  }

  // --- IMAGEM ---

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
          toolbarTitle: 'Recortar',
          toolbarColor: const Color(0xFF0D1B50),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Recortar'),
      ],
    );

    if (croppedFile != null) {
      selectedImage = File(croppedFile.path);
      // Reseta parametros ao carregar nova imagem
      contrast = 1.2;
      brightness = 0.8; // Defaults bons para termicas
      await generatePreview(); // Gera o primeiro preview auto
    }
  }

  void updateParams(double newContrast, double newBrightness) {
    contrast = newContrast;
    brightness = newBrightness;
    notifyListeners();
    // Debounce manual: Chame generatePreview() na UI quando soltar o slider
  }

  // Roda em Isolate para não travar a UI
  Future<void> generatePreview() async {
    if (selectedImage == null) return;

    isProcessing = true;
    notifyListeners();

    try {
      final rawBytes = await selectedImage!.readAsBytes();

      // Envia para thread separada
      final result = await compute(processImageTask, {
        'bytes': rawBytes,
        'contrast': contrast,
        'brightness': brightness,
        'width': 380, // Largura segura para 58mm
      });

      _processedImageRaw = result['image'] as img.Image;
      previewBytes = result['pngBytes'] as Uint8List; // Para exibir na tela
    } catch (e) {
      statusMessage = "Erro no processamento: $e";
    } finally {
      isProcessing = false;
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
      await generatePreview(); // Garante que temos a imagem processada
    }

    isPrinting = true;
    notifyListeners();

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      bytes += generator.reset();
      // Usa a imagem já processada (dithered)
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
    const int chunkSize = 200; // Safe spot para genericas
    final bool canWriteWithoutResponse =
        _txCharacteristic!.properties.writeWithoutResponse;

    for (var i = 0; i < bytes.length; i += chunkSize) {
      var end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      final data = bytes.sublist(i, end);

      if (canWriteWithoutResponse) {
        await _txCharacteristic!.write(data, withoutResponse: true);
        // Delay crucial para buffer da impressora chinesa não estourar
        await Future.delayed(const Duration(milliseconds: 10));
      } else {
        await _txCharacteristic!.write(data, withoutResponse: false);
      }
    }
  }
}

// --- TOP LEVEL FUNCTION (ISOLATE) ---
// Deve ficar fora da classe para ser chamada pelo compute
Map<String, dynamic> processImageTask(Map<String, dynamic> params) {
  final Uint8List bytes = params['bytes'];
  final double contrast = params['contrast'];
  final double brightness = params['brightness'];
  final int targetWidth = params['width'];

  img.Image? image = img.decodeImage(bytes);
  if (image == null) throw Exception("Falha ao decodificar imagem");

  // 1. Resize
  image = img.copyResize(image, width: targetWidth);

  // 2. Grayscale
  image = img.grayscale(image);

  // 3. Ajuste de Contraste/Brilho
  // image lib usa ranges diferentes as vezes, mas adjustColor é padrao
  image = img.adjustColor(image, contrast: contrast, brightness: brightness);

  // 4. Dithering (Floyd-Steinberg Manual)
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final int oldPixel = pixel.r.toInt();
      final int newPixel = oldPixel < 128 ? 0 : 255;
      final int error = oldPixel - newPixel;

      image.setPixelRgb(x, y, newPixel, newPixel, newPixel);

      if (x + 1 < image.width) _addError(image, x + 1, y, error * 7 ~/ 16);
      if (x - 1 >= 0 && y + 1 < image.height)
        _addError(image, x - 1, y + 1, error * 3 ~/ 16);
      if (y + 1 < image.height) _addError(image, x, y + 1, error * 5 ~/ 16);
      if (x + 1 < image.width && y + 1 < image.height)
        _addError(image, x + 1, y + 1, error * 1 ~/ 16);
    }
  }

  // Retorna map com imagem crua (para printer) e bytes PNG (para UI)
  return {'image': image, 'pngBytes': Uint8List.fromList(img.encodePng(image))};
}

void _addError(img.Image image, int x, int y, int errorAmount) {
  final pixel = image.getPixel(x, y);
  int newVal = pixel.r.toInt() + errorAmount;
  newVal = newVal.clamp(0, 255);
  image.setPixelRgb(x, y, newVal, newVal, newVal);
}
