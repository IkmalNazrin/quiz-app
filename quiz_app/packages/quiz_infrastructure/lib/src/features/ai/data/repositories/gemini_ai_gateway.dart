import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';

class GeminiAIGateway implements IAIGateway {
  final VaultService _vaultService;
  GenerativeModel? _model;

  GeminiAIGateway(this._vaultService);

  Future<GenerativeModel> _getModel() async {
    if (_model != null) return _model!;
    final apiKey = await _vaultService.getAiOrchestratorKey() ?? dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
    return _model!;
  }

  @override
  String get providerName => 'Gemini 1.5 Flash';

  @override
  bool get supportsOffline => false;

  final _circuitBreaker = CircuitBreaker(serviceName: 'GeminiAI');

  @override
  Future<List<QuestionEntity>> generateQuestions(
      AIGenerationRequest request) async {
    return _circuitBreaker.execute(() async {
      final prompt = _buildGenerationPrompt(request);
      final model = await _getModel();

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      final jsonText = response.text;
      if (jsonText == null) throw Exception('AI provided an empty response');

      final List<dynamic> data = jsonDecode(jsonText);
      return data.map((q) => _mapToEntity(q)).toList();
    });
  }

  @override
  Future<String> analyzeContent(String content) async {
    final prompt =
        'Analyze the following content and provide a brief summary of how suitable it is for a quiz: $content';
    final model = await _getModel();
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? 'No analysis available';
  }

  String _buildGenerationPrompt(AIGenerationRequest request) {
    return '''
Generate exactly ${request.questionCount} multiple choice questions about: "${request.content}".
Theme: ${request.category ?? 'General Knowledge'}
Difficulty: ${request.difficulty}

Return the data as a JSON array of objects with the following schema:
{
  "question": "string",
  "options": ["string", "string", "string", "string"],
  "correctAnswerIndex": number (0-3),
  "difficulty": "easy" | "medium" | "hard",
  "timer": number (seconds),
  "type": "multiple_choice",
  "points": number (default 1000)
}

Ensure the questions are engaging and appropriate for ${request.difficulty} level.
''';
  }

  QuestionEntity _mapToEntity(Map<String, dynamic> json) {
    return QuestionEntity(
      question: json['question'] ?? 'Unknown Question',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctAnswerIndex'] ?? 0,
      difficulty: json['difficulty'] ?? 'medium',
      timer: json['timer'] ?? 30,
      type: json['type'] ?? 'multiple_choice',
      points: json['points'] ?? 1000,
    );
  }
}
