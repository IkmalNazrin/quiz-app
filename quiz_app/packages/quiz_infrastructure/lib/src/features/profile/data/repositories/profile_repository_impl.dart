import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ProfileEntity> getProfile(String userId) async {
    return remoteDataSource.getProfile(userId);
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    await remoteDataSource.updateProfile(ProfileModel.fromEntity(profile));
  }

  @override
  Future<void> createProfile(ProfileEntity profile) async {
    await remoteDataSource.createProfile(ProfileModel.fromEntity(profile));
  }
}
