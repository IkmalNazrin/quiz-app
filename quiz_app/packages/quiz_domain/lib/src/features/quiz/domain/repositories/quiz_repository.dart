import 'package:dartz/dartz.dart';
import '../../../../core_domain/error/failures.dart';
import '../entities/quiz_entity.dart';

abstract class QuizRepository {
  Future<Either<Failure, List<QuizEntity>>> getMyQuizzes();
  Future<Either<Failure, List<QuizEntity>>> getPublicQuizzes();
  Future<Either<Failure, QuizEntity>> getQuizDetails(String id);
  Future<Either<Failure, void>> createQuiz(QuizEntity quiz);
  Future<Either<Failure, void>> updateQuiz(QuizEntity quiz);
  Future<Either<Failure, void>> deleteQuiz(String quizId);
  Future<Either<Failure, void>> rateQuiz(String quizId, double rating);
}
