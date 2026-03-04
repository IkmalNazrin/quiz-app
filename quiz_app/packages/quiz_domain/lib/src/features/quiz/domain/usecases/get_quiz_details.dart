import 'package:dartz/dartz.dart';
import '../../../../core_domain/error/failures.dart';
import '../../../../core_domain/usecases/usecase.dart';
import '../entities/quiz_entity.dart';
import '../repositories/quiz_repository.dart';

class GetQuizDetails implements UseCase<QuizEntity, String> {
  final QuizRepository repository;

  GetQuizDetails(this.repository);

  @override
  Future<Either<Failure, QuizEntity>> call(String id) async {
    return repository.getQuizDetails(id);
  }
}
