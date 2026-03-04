import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository Provider
import 'package:quiz_domain/quiz_domain.dart';

import 'package:quiz_features/quiz_features.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});

// UseCase Provider
final getUserHistoryUseCaseProvider = Provider<GetUserHistoryUseCase>((ref) {
  final repository = ref.watch(historyRepositoryProvider);
  return GetUserHistoryUseCase(repository);
});

// State Provider (AsyncValue for easy UI handling)
final userHistoryProvider =
    FutureProvider.family<List<GameHistoryItem>, String>((ref, userId) async {
  final useCase = ref.watch(getUserHistoryUseCaseProvider);
  final result = await useCase(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (history) => history,
  );
});
