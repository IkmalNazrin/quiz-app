import 'package:dartz/dartz.dart';
import '../../../../core_domain/error/failures.dart';
import '../entities/challenge_entity.dart';

abstract class ChallengeRepository {
  Future<Either<Failure, List<ChallengeEntity>>> getMyChallenges();
  Future<Either<Failure, void>> createChallenge(ChallengeEntity challenge);
  Future<Either<Failure, void>> completeChallenge(
      String challengeId, int score);
  Future<Either<Failure, ChallengeEntity>> getChallengeById(String id);
  Future<Either<Failure, void>> sendChallenge(
      {required String quizId,
      required String opponentUsername,
      required int challengerScore});
}
