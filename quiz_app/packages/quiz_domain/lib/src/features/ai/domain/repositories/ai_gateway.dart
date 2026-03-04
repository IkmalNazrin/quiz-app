import 'package:quiz_domain/quiz_domain.dart';

abstract class IAIGateway {
  /// Generates a list of questions based on the request.
  Future<List<QuestionEntity>> generateQuestions(AIGenerationRequest request);

  /// Analyzes a prompt and returns an importance score or feedback.
  Future<String> analyzeContent(String content);

  /// Returns true if the gateway supports offline inference.
  bool get supportsOffline;

  /// The name of the AI provider (e.g., "Gemini", "Local-Gemma")
  String get providerName;
}
