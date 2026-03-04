import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data Source
import 'package:quiz_domain/quiz_domain.dart';

import 'package:quiz_features/quiz_features.dart';

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});

// UseCases
final getMyChallengesProvider = Provider<GetMyChallenges>((ref) {
  return GetMyChallenges(ref.read(challengeRepositoryProvider));
});

// Presentation Logic
final myChallengesProvider =
    AsyncNotifierProvider<MyChallengesNotifier, List<ChallengeEntity>>(
        MyChallengesNotifier.new);

class MyChallengesNotifier extends AsyncNotifier<List<ChallengeEntity>> {
  @override
  Future<List<ChallengeEntity>> build() async {
    return _fetchChallenges();
  }

  Future<List<ChallengeEntity>> _fetchChallenges() async {
    final getMyChallenges = ref.read(getMyChallengesProvider);
    final result = await getMyChallenges(NoParams());
    return result.fold(
      (failure) => throw Exception(failure.message),
      (challenges) => challenges,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchChallenges());
  }
}
