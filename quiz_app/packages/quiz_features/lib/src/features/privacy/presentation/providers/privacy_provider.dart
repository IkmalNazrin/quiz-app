import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quiz_domain/quiz_domain.dart';

import 'package:quiz_features/quiz_features.dart';

final privacyRepositoryProvider = Provider<PrivacyRepository>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});

final privacyStateProvider =
    StateNotifierProvider<PrivacyNotifier, AsyncValue<void>>((ref) {
  return PrivacyNotifier(ref.read(privacyRepositoryProvider));
});

class PrivacyNotifier extends StateNotifier<AsyncValue<void>> {
  final PrivacyRepository _repository;

  PrivacyNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>?> exportData() async {
    state = const AsyncValue.loading();
    final result = await _repository.exportUserData();
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return null;
      },
      (data) {
        state = const AsyncValue.data(null);
        return data;
      },
    );
  }

  Future<void> deleteAccount() async {
    state = const AsyncValue.loading();
    final result = await _repository.anonymizeAccount();
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }
}
