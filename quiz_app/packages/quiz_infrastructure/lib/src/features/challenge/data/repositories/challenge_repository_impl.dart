import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';
import '../datasources/challenge_remote_data_source.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class ChallengeRepositoryImpl implements ChallengeRepository {
  final ChallengeRemoteDataSource remoteDataSource;
  final SupabaseClient supabaseClient;

  ChallengeRepositoryImpl(this.remoteDataSource, this.supabaseClient);

  @override
  Future<Either<Failure, ChallengeEntity>> getChallengeById(String id) async {
    try {
      final challenge = await remoteDataSource.getChallengeById(id);
      return Right(challenge);
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
  Future<Either<Failure, List<ChallengeEntity>>> getMyChallenges() async {
    try {
      final challenges = await remoteDataSource.getMyChallenges();
      return Right(challenges);
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
  Future<Either<Failure, void>> createChallenge(
      ChallengeEntity challenge) async {
    try {
      await remoteDataSource.createChallenge(challenge);
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
  Future<Either<Failure, void>> completeChallenge(
      String challengeId, int score) async {
    try {
      await remoteDataSource.completeChallenge(challengeId, score);
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
  Future<Either<Failure, void>> sendChallenge(
      {required String quizId,
      required String opponentUsername,
      required int challengerScore}) async {
    try {
      final challengerUsername =
          supabaseClient.auth.currentUser?.userMetadata?['username'] ?? 'User';
      final challengerId = supabaseClient.auth.currentUser?.id;
      if (challengerId == null) throw const AuthFailure('Not authenticated');

      final challenge = ChallengeEntity(
        id: '', // Supabase will generate this or we ignore it on insert
        quizTitle:
            quizId, // The entity uses quizTitle to hold title or ID sometimes, but repository API says quizId.
        // Actually, looking at remote_data_source, it expects quiz_id and quiz_title.
        // I will let the data source handle the mapping if I were to pass an entity,
        // but here I can call a specific data source method if it exists.

        status: 'pending',
        challengeType: '1v1',
        challengerId: challengerId,
        challengerUsername: challengerUsername,
        challengerScore: challengerScore,
        opponentUsername: opponentUsername,
        opponentScore: 0,
        createdAt: DateTime.now(),
      );

      await remoteDataSource.createChallenge(challenge);
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
}
