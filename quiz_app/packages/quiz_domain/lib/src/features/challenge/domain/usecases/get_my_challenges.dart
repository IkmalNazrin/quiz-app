import 'package:dartz/dartz.dart';
import '../../../../core_domain/error/failures.dart';
import '../../../../core_domain/usecases/usecase.dart';
import '../entities/challenge_entity.dart';
import '../repositories/challenge_repository.dart';

class GetMyChallenges implements UseCase<List<ChallengeEntity>, NoParams> {
  final ChallengeRepository repository;

  GetMyChallenges(this.repository);

  @override
  Future<Either<Failure, List<ChallengeEntity>>> call(NoParams params) async {
    return repository.getMyChallenges();
  }
}
