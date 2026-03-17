import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeminiApiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  static const String _endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-001:predict';

  static const String _thermalModifiers = 
      ", pure black and white line art, 1-bit pixel art style, high contrast stencil, solid white background, no shading, no grayscale";

  static Future<Uint8List> generateImage(String userPrompt) async {
    final String finalPrompt = userPrompt + _thermalModifiers;

    final Map<String, dynamic> body = {
      "instances": [
        {"prompt": finalPrompt}
      ],
      "parameters": {
        "sampleCount": 1,
        "aspectRatio": "1:1"
      }
    };

    try {
      final response = await http.post(
        Uri.parse('$_endpoint?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('predictions') && data['predictions'].isNotEmpty) {
          final String base64Image = data['predictions'][0]['bytesBase64Encoded'];
          return base64Decode(base64Image);
        } else {
          throw Exception('A API não retornou nenhuma imagem.');
        }
      } else {
        throw Exception('Erro na API: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro no GeminiApiService: $e');
      rethrow;
    }
  }
}