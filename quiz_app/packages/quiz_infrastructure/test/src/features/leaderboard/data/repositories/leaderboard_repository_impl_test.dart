import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_infrastructure/src/features/leaderboard/data/datasources/leaderboard_remote_data_source.dart';
import 'package:quiz_infrastructure/src/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';

class MockLeaderboardRemoteDataSource extends Mock implements LeaderboardRemoteDataSource {}

void main() {
  late LeaderboardRepositoryImpl repository;
  late MockLeaderboardRemoteDataSource mockRemoteDataSource;

  const tLeaderboardEntry = LeaderboardEntry(
    score: 100,
    userId: 'user123',
    username: 'player1',
  );

  final List<LeaderboardEntry> tLeaderboardList = [tLeaderboardEntry];

  setUp(() {
    mockRemoteDataSource = MockLeaderboardRemoteDataSource();
    repository = LeaderboardRepositoryImpl(mockRemoteDataSource);
  });

  group('fetchLeaderboard', () {
    test('should return list of LeaderboardEntry from remote data source when isTeam is false', () async {
      when(() => mockRemoteDataSource.fetchLeaderboard(any(), isTeam: any(named: 'isTeam')))
          .thenAnswer((_) async => tLeaderboardList);

      final result = await repository.fetchLeaderboard('test_quiz', isTeam: false);

      verify(() => mockRemoteDataSource.fetchLeaderboard('test_quiz', isTeam: false)).called(1);
      expect(result, equals(tLeaderboardList));
    });

    test('should propagate exceptions from remote data source', () async {
      when(() => mockRemoteDataSource.fetchLeaderboard(any(), isTeam: any(named: 'isTeam')))
          .thenThrow(Exception('Server error'));

      expect(() => repository.fetchLeaderboard('test_quiz', isTeam: false), throwsA(isA<Exception>()));
    });
  });

  group('submitScore', () {
    test('should call submitScore on remote data source', () async {
      when(() => mockRemoteDataSource.submitScore(
            quizId: any(named: 'quizId'),
            score: any(named: 'score'),
            teamName: any(named: 'teamName'),
            members: any(named: 'members'),
          )).thenAnswer((_) async => Future<void>.value());

      await repository.submitScore(quizId: 'test_quiz', score: 100, teamName: 'winners', members: [{'id': 'user1'}]);

      verify(() => mockRemoteDataSource.submitScore(
            quizId: 'test_quiz',
            score: 100,
            teamName: 'winners',
            members: [{'id': 'user1'}],
          )).called(1);
    });

    test('should propagate exceptions on failure', () async {
      when(() => mockRemoteDataSource.submitScore(
            quizId: any(named: 'quizId'),
            score: any(named: 'score'),
            teamName: any(named: 'teamName'),
            members: any(named: 'members'),
          )).thenThrow(Exception('Server error'));

      expect(() => repository.submitScore(quizId: 'test_quiz', score: 100), throwsA(isA<Exception>()));
    });
  });
}
