import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';
import '../models/profile_model.dart';
import 'package:flutter/foundation.dart';
import 'package:quiz_domain/quiz_domain.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String userId);
  Future<void> updateProfile(ProfileModel profile);
  Future<void> createProfile(ProfileModel profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProfileRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<ProfileModel> getProfile(String userId) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', userId)
            .single();

        return ProfileModel.fromJson(response);
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          AppLogger.e(
              'ProfileRemoteDataSource.getProfile error after retries: $e', category: LogCategory.system);
          throw ServerFailure(e.toString());
        }
        await Future.delayed(Duration(milliseconds: 500 * retryCount));
      }
    }
    throw const ServerFailure('Failed to load profile after multiple retries');
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      await supabaseClient
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id);
    } catch (e) {
      AppLogger.e('ProfileRemoteDataSource.updateProfile error: $e', category: LogCategory.system);
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> createProfile(ProfileModel profile) async {
    try {
      await supabaseClient.from('profiles').insert(profile.toJson());
    } catch (e) {
      AppLogger.e('ProfileRemoteDataSource.createProfile error: $e', category: LogCategory.system);
      throw ServerFailure(e.toString());
    }
  }
}
