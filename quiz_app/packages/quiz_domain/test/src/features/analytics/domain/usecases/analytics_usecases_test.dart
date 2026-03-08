import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:quiz_domain/src/core_domain/error/failures.dart';
import 'package:quiz_domain/src/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:quiz_domain/src/features/analytics/domain/usecases/get_host_analytics_usecase.dart';
import 'package:quiz_domain/src/features/analytics/domain/usecases/get_quiz_analytics_usecase.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  late MockAnalyticsRepository mockRepository;
  late GetHostAnalyticsUseCase getHostAnalyticsUseCase;
  late GetQuizAnalyticsUseCase getQuizAnalyticsUseCase;

  setUp(() {
    mockRepository = MockAnalyticsRepository();
    getHostAnalyticsUseCase = GetHostAnalyticsUseCase(mockRepository);
    getQuizAnalyticsUseCase = GetQuizAnalyticsUseCase(mockRepository);
  });

  group('GetHostAnalyticsUseCase', () {
    const tHostId = 'host_123';
    final tHostStatsJson = {
      'total_quizzes': 5,
      'total_plays': 20,
      'total_players': 150,
      'avg_rating': 4.5,
    };

    test('should return right with HostStats when repository call is successful', () async {
      when(() => mockRepository.getHostStats(tHostId))
          .thenAnswer((_) async => tHostStatsJson);

      final result = await getHostAnalyticsUseCase(tHostId);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (stats) {
          expect(stats.totalQuizzes, 5);
          expect(stats.totalPlays, 20);
          expect(stats.totalPlayers, 150);
          expect(stats.avgRating, 4.5);
        },
      );
      verify(() => mockRepository.getHostStats(tHostId)).called(1);
    });

    test('should return left with ServerFailure when repository throws Exception', () async {
      when(() => mockRepository.getHostStats(any()))
          .thenThrow(Exception('Server error'));

      final result = await getHostAnalyticsUseCase(tHostId);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Server error'));
        },
        (stats) => fail('Should not return stats'),
      );
      verify(() => mockRepository.getHostStats(tHostId)).called(1);
    });
  });

  group('GetQuizAnalyticsUseCase', () {
    const tQuizId = 'quiz_123';
    final tQuizStatsJson = {
      'quiz_id': tQuizId,
      'play_count': 50,
      'avg_score': 85.5,
      'completion_rate': 0.92,
    };

    test('should return right with QuizStats when repository call is successful', () async {
      when(() => mockRepository.getQuizStats(tQuizId))
          .thenAnswer((_) async => tQuizStatsJson);

      final result = await getQuizAnalyticsUseCase(tQuizId);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (stats) {
          expect(stats.quizId, tQuizId);
          expect(stats.playCount, 50);
          expect(stats.avgScore, 85.5);
          expect(stats.completionRate, 0.92);
        },
      );
      verify(() => mockRepository.getQuizStats(tQuizId)).called(1);
    });

    test('should return left with ServerFailure when repository throws Exception', () async {
      when(() => mockRepository.getQuizStats(any()))
          .thenThrow(Exception('Database error'));

      final result = await getQuizAnalyticsUseCase(tQuizId);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Database error'));
        },
        (stats) => fail('Should not return stats'),
      );
      verify(() => mockRepository.getQuizStats(tQuizId)).called(1);
    });
  });
}
