import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiApiService {
  // Puxa a chave de forma segura do ficheiro .env
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? ''; 
  
  // Endpoint atualizado para utilizar o modelo de imagem mais recente
  static const String _endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-image-preview:generateContent';

  // Modificadores invisíveis para otimizar o papel térmico (58mm)
  static const String _thermalModifiers = 
      ", pure black and white line art, 1-bit pixel art style, high contrast stencil, solid white background, no shading, no grayscale";

  static Future<Uint8List> generateImage(String userPrompt) async {
    final String finalPrompt = userPrompt + _thermalModifiers;

    // Estrutura atualizada exigida pelo endpoint generateContent
    final Map<String, dynamic> body = {
      "contents": [
        {
          "parts": [
            {"text": finalPrompt}
          ]
        }
      ],
      "generationConfig": {
        "responseModalities": ["IMAGE"] // Força o retorno exclusivo de imagem
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
        
        // O novo formato JSON devolve a imagem em base64 dentro de 'inlineData'
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final parts = data['candidates'][0]['content']['parts'] as List;
          
          for (var part in parts) {
            if (part.containsKey('inlineData')) {
              final String base64Image = part['inlineData']['data'];
              return base64Decode(base64Image);
            }
          }
        }
        throw Exception('A API não retornou os dados da imagem.');
      } else {
        throw Exception('Erro na API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro no GeminiApiService: $e');
      rethrow;
    }
  }
}