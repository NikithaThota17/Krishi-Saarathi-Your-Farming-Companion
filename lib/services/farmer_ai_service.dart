import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/ai_local_config.dart';

class FarmerAiMessage {
  const FarmerAiMessage({
    required this.role,
    required this.text,
  });

  final String role;
  final String text;
}

class FarmerAiService {
  static const String _envApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _envModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-2.5-flash',
  );
  static const String _prefsApiKey = 'gemini_api_key';
  static const String _prefsModel = 'gemini_model';

  Future<bool> get isConfigured async => (await _resolveApiKey()).isNotEmpty;

  Future<String> _resolveApiKey() async {
    if (AiLocalConfig.geminiApiKey.trim().isNotEmpty) {
      return AiLocalConfig.geminiApiKey.trim();
    }
    if (_envApiKey.trim().isNotEmpty) {
      return _envApiKey.trim();
    }

    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_prefsApiKey) ?? '').trim();
  }

  Future<String> _resolveModel() async {
    if (AiLocalConfig.geminiModel.trim().isNotEmpty) {
      return AiLocalConfig.geminiModel.trim();
    }
    final prefs = await SharedPreferences.getInstance();
    final savedModel = (prefs.getString(_prefsModel) ?? '').trim();
    if (savedModel.isNotEmpty) {
      return savedModel;
    }
    return _envModel;
  }

  Future<String?> answer({
    required String question,
    required bool isTelugu,
    List<FarmerAiMessage> history = const [],
  }) async {
    final apiKey = await _resolveApiKey();
    if (apiKey.isEmpty || question.trim().isEmpty) {
      return null;
    }
    final model = await _resolveModel();

    final prompt = isTelugu
        ? 'You are a helpful agricultural assistant for Indian farmers. Answer in simple Telugu. Give direct practical guidance, explain naturally, and add up to 3 short bullet suggestions only when useful.'
        : 'You are a helpful agricultural assistant for Indian farmers. Answer in simple English. Give direct practical guidance, explain naturally, and add up to 3 short bullet suggestions only when useful.';

    final contents = <Map<String, dynamic>>[
      ...history
          .where((message) => message.text.trim().isNotEmpty)
          .map(
            (message) => {
              'role': message.role == 'assistant' ? 'model' : 'user',
              'parts': [
                {'text': message.text}
              ]
            },
          ),
      {
        'role': 'user',
        'parts': [
          {'text': question}
        ]
      },
    ];

    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
      ),
      headers: {
        'x-goog-api-key': apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': prompt}
          ]
        },
        'contents': contents,
        'generationConfig': {
          'temperature': 0.4,
        },
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = body['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;
    final first = candidates.first;
    if (first is! Map<String, dynamic>) return null;
    final content = first['content'];
    if (content is! Map<String, dynamic>) return null;
    final parts = content['parts'];
    if (parts is! List) return null;
    for (final part in parts) {
      if (part is! Map<String, dynamic>) continue;
      final text = part['text'];
      if (text is String && text.trim().isNotEmpty) {
        return text.trim();
      }
    }

    return null;
  }
}
