import 'package:dartz/dartz.dart';
import '../../../../core_domain/error/failures.dart';
import '../../../../core_domain/usecases/usecase.dart';
import '../repositories/quiz_repository.dart';

class DeleteQuiz implements UseCase<void, String> {
  final QuizRepository repository;

  DeleteQuiz(this.repository);

  @override
  Future<Either<Failure, void>> call(String quizId) async {
    return repository.deleteQuiz(quizId);
  }
}
