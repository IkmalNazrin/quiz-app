import 'dart:typed_data';

enum AIGeneratorType { cloud, local, hybrid }

enum AISourceType { topic, document, webUrl }

class AIGenerationRequest {
  final String content; // Topic name, transcript, or raw text
  final AISourceType source;
  final int questionCount;
  final String difficulty;
  final String? category;
  final Uint8List? fileData; // For PDFs/Images
  final AIGeneratorType generator;

  const AIGenerationRequest({
    required this.content,
    required this.source,
    this.questionCount = 10,
    this.difficulty = 'medium',
    this.category,
    this.fileData,
    this.generator = AIGeneratorType.hybrid,
  });
}
