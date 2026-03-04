import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle(
      String idToken, String accessToken) async {
    try {
      final user =
          await remoteDataSource.signInWithGoogle(idToken, accessToken);
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('canceled') || errorStr.contains('cancelled')) {
        return const Left(CanceledFailure());
      }
      return Left(ServerFailure(errorStr));
    }
  }

  @override
  Future<Either<Failure, void>> signInWithGoogleNative() async {
    try {
      await remoteDataSource.signInWithOAuth();
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('canceled') || errorStr.contains('cancelled')) {
        return const Left(CanceledFailure());
      }
      return Left(ServerFailure(errorStr));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInAnonymously() async {
    try {
      final user = await remoteDataSource.signInAnonymously();
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('canceled') || errorStr.contains('cancelled')) {
        return const Left(CanceledFailure());
      }
      return Left(ServerFailure(errorStr));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('canceled') || errorStr.contains('cancelled')) {
        return const Left(CanceledFailure());
      }
      return Left(ServerFailure(errorStr));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') return Left(NotFoundFailure(e.message));
      return Left(ServerFailure(e.message));
    } on SocketException catch (_) {
      return Left(const NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return remoteDataSource.currentSession != null;
  }

  @override
  Future<Either<Failure, void>> signInWithSSO(String emailOrSlug) async {
    try {
      await remoteDataSource.signInWithSSO(emailOrSlug);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') return Left(NotFoundFailure(e.message));
      return Left(ServerFailure(e.message));
    } on SocketException catch (_) {
      return Left(const NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') return Left(NotFoundFailure(e.message));
      return Left(ServerFailure(e.message));
    } on SocketException catch (_) {
      return Left(const NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges;
  }
}
