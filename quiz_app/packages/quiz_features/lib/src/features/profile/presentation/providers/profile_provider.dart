import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quiz_domain/quiz_domain.dart';

import 'package:quiz_features/quiz_features.dart';



final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileEntity?>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});

class ProfileNotifier extends StateNotifier<AsyncValue<ProfileEntity?>> {
  final ProfileRepository repository;

  ProfileNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> fetchProfile(String userId) async {
    state = const AsyncValue.loading();
    try {
      final profile = await repository.getProfile(userId);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile(ProfileEntity profile) async {
    try {
      await repository.updateProfile(profile);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createProfile(ProfileEntity profile) async {
    try {
      await repository.createProfile(profile);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
