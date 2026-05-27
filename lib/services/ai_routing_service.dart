import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:calorize/data/models/ai_provider.dart';
import 'package:calorize/services/database_service.dart';

class AiRoutingService {
  static final AiRoutingService _instance = AiRoutingService._internal();
  factory AiRoutingService() => _instance;
  AiRoutingService._internal();

  int _currentIndex = 0;
  bool _roundRobin = false;

  Future<void> loadSettings() async {
    final profile = await DatabaseService().getUserProfile();
    _roundRobin = profile?.aiRoutingMode == 'round_robin';
    // Do not reset _currentIndex here so round robin persists across image requests
  }

  AIProvider? getNextProvider(List<AIProvider> providers, {int attempt = 0}) {
    final enabled = providers.where((p) => p.isEnabled == true).toList();
    if (enabled.isEmpty) return null;

    if (_roundRobin) {
      return enabled[(_currentIndex + attempt) % enabled.length];
    } else {
      return enabled[attempt % enabled.length];
    }
  }

  void advanceRoundRobin(int attemptsMade, int totalEnabled) {
    if (_roundRobin && totalEnabled > 0) {
      _currentIndex = (_currentIndex + attemptsMade) % totalEnabled;
    }
  }

  Future<String> sendImageRequest(
    AIProvider provider,
    String prompt,
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    switch (provider.apiType) {
      case 'google':
        return _callGemini(provider, prompt, imageBytes, mimeType: mimeType);
      case 'openai':
        return _callOpenAI(provider, prompt, imageBytes, mimeType: mimeType);
      case 'anthropic':
        return _callAnthropic(provider, prompt, imageBytes, mimeType: mimeType);
      default:
        return _callCustom(provider, prompt, imageBytes, mimeType: mimeType);
    }
  }

  Future<String> _callGemini(
    AIProvider provider,
    String prompt,
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    final base64Image = base64Encode(imageBytes);
    final url =
        '${provider.baseUrl}/models/${provider.modelId}:generateContent?key=${provider.apiKey}';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {
                  'mime_type': mimeType,
                  'data': base64Image
                }
              }
            ]
          }
        ],
        'tools': [
          {'google_search': {}}
        ]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error: ${response.statusCode}');
    }

    final jsonResponse = jsonDecode(response.body);
    final candidates = jsonResponse['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini: no candidates in response');
    }
    final parts = candidates[0]['content']?['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      throw Exception('Gemini: no parts in response');
    }
    return parts[0]['text'] as String;
  }

  Future<String> _callOpenAI(
    AIProvider provider,
    String prompt,
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    final base64Image = base64Encode(imageBytes);
    final url = '${provider.baseUrl}/chat/completions';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${provider.apiKey}',
      },
      body: jsonEncode({
        'model': provider.modelId,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:$mimeType;base64,$base64Image'
                }
              }
            ]
          }
        ],
        'max_tokens': 1000,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('OpenAI API error: ${response.statusCode}');
    }

    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['choices']?[0]?['message']?['content'] as String? ??
        '';
  }

  Future<String> _callAnthropic(
    AIProvider provider,
    String prompt,
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    final base64Image = base64Encode(imageBytes);
    final url = '${provider.baseUrl}/messages';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': '${provider.apiKey}',
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': provider.modelId,
        'max_tokens': 1000,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': mimeType,
                  'data': base64Image,
                }
              },
              {'type': 'text', 'text': prompt}
            ]
          }
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Anthropic API error: ${response.statusCode}');
    }

    final jsonResponse = jsonDecode(response.body);
    final content = jsonResponse['content'] as List?;
    if (content == null || content.isEmpty) {
      throw Exception('Anthropic: no content in response');
    }
    return content[0]['text'] as String? ?? '';
  }

  Future<String> _callCustom(
    AIProvider provider,
    String prompt,
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    final base64Image = base64Encode(imageBytes);
    final url = '${provider.baseUrl}/chat/completions';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${provider.apiKey}',
      },
      body: jsonEncode({
        'model': provider.modelId,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:$mimeType;base64,$base64Image'
                }
              }
            ]
          }
        ],
        'max_tokens': 1000,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Custom API error: ${response.statusCode}');
    }

    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['choices'] != null) {
      return jsonResponse['choices']?[0]?['message']?['content'] as String? ??
          '';
    }
    if (jsonResponse['content'] != null) {
      final content = jsonResponse['content'] as List?;
      if (content != null && content.isNotEmpty) {
        return content[0]['text'] as String? ?? '';
      }
    }
    throw Exception('Custom API: unrecognized response format');
  }
}
