import 'package:dartz/dartz.dart';
import '../../../../core_domain/error/failures.dart';
import '../../../../core_domain/usecases/usecase.dart';
import '../entities/quiz_entity.dart';
import '../repositories/quiz_repository.dart';

class UpdateQuiz implements UseCase<void, QuizEntity> {
  final QuizRepository repository;

  UpdateQuiz(this.repository);

  @override
  Future<Either<Failure, void>> call(QuizEntity quiz) async {
    return repository.updateQuiz(quiz);
  }
}
