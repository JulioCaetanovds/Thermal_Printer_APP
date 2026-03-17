import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiApiService {
  static String get _apiKey => dotenv.env['HF_API_KEY'] ?? ''; 
  
  static const String _endpoint = 'https://router.huggingface.co/hf-inference/models/stabilityai/stable-diffusion-xl-base-1.0';

  static const String _thermalModifiers = 
      ", pure black and white line art, 1-bit pixel art style, high contrast stencil, solid white background, no shading, no grayscale";

  static Future<Uint8List> generateImage(String userPrompt) async {
    if (_apiKey.isEmpty) {
      throw Exception('API Key do Hugging Face (HF_API_KEY) não encontrada no .env');
    }

    final String finalPrompt = userPrompt + _thermalModifiers;

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"inputs": finalPrompt}),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 503) {
         throw Exception('O modelo está aquecendo no servidor. Tente novamente em 20 segundos.');
      } else {
         final errorMap = jsonDecode(response.body);
         throw Exception('Erro: ${response.statusCode} - ${errorMap['error']}');
      }
    } catch (e) {
      debugPrint('Erro na IA: $e');
      rethrow;
    }
  }
}