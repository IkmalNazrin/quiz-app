import 'package:dartz/dartz.dart';
import '../../../../core_domain/error/failures.dart';
import '../../../../core_domain/usecases/usecase.dart';
import '../entities/quiz_entity.dart';
import '../repositories/quiz_repository.dart';

class GetPublicQuizzes implements UseCase<List<QuizEntity>, NoParams> {
  final QuizRepository repository;

  GetPublicQuizzes(this.repository);

  @override
  Future<Either<Failure, List<QuizEntity>>> call(NoParams params) async {
    return repository.getPublicQuizzes();
  }
}
