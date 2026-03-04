import 'package:dartz/dartz.dart';
import '../../../../core_domain/error/failures.dart';
// Depending on Supabase types in Domain is debatable, strictly should be pure, but for pragmatic reasons we might pass AuthResponse or wrap it.
// Ideally, we should return Domain Entities, not Supabase types.
// Let's stick to Clean Architecture STRICT mode and return UserEntity.

import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithGoogle(
      String idToken, String accessToken);
  Future<Either<Failure, void>> signInWithGoogleNative();
  Future<Either<Failure, UserEntity>> signInAnonymously();
  Future<Either<Failure, void>> signInWithSSO(String emailOrSlug);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<bool> isLoggedIn();
  Stream<UserEntity?> get authStateChanges;
}
