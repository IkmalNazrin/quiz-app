import 'package:dartz/dartz.dart';
import '../../../../core_domain/error/failures.dart';
import '../entities/quiz_stats.dart';
import '../repositories/analytics_repository.dart';

class GetQuizAnalyticsUseCase {
  final AnalyticsRepository repository;

  GetQuizAnalyticsUseCase(this.repository);

  Future<Either<Failure, QuizStats>> call(String quizId) async {
    try {
      final data = await repository.getQuizStats(quizId);
      return Right(QuizStats.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
