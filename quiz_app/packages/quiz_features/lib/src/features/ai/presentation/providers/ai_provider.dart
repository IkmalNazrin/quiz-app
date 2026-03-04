import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quiz_domain/quiz_domain.dart';

/// Provider for the abstract AI Gateway.
/// Defaults to Gemini, but can be overridden for Local/Mock tests.
final aiGatewayProvider = Provider<IAIGateway>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});

/// Generator provider that handles the actual creation of questions.
final aiGenerationProvider =
    FutureProvider.family<List<QuestionEntity>, AIGenerationRequest>(
        (ref, request) {
  final gateway = ref.watch(aiGatewayProvider);
  return gateway.generateQuestions(request);
});
