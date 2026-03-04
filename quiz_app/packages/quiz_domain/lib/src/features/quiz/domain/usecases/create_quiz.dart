import 'package:dartz/dartz.dart';
import '../../../../core_domain/error/failures.dart';
import '../../../../core_domain/usecases/usecase.dart';
import '../entities/quiz_entity.dart';
import '../repositories/quiz_repository.dart';

class CreateQuiz implements UseCase<void, QuizEntity> {
  final QuizRepository repository;

  CreateQuiz(this.repository);

  @override
  Future<Either<Failure, void>> call(QuizEntity quiz) async {
    return repository.createQuiz(quiz);
  }
}
