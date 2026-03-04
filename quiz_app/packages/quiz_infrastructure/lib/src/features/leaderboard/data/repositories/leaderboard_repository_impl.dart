import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';
import '../datasources/leaderboard_remote_data_source.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource remoteDataSource;

  LeaderboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<LeaderboardEntry>> fetchLeaderboard(String quizId,
      {required bool isTeam}) async {
    try {
      return await remoteDataSource.fetchLeaderboard(quizId, isTeam: isTeam);
    } catch (e) {
      // In a real app, map exceptions to failures.
      // For now, rethrowing or returning empty list on failure might be desired,
      // but let's just let the provider handle exceptions or return empty.
      // Ideally returning Either<Failure, List>
      rethrow;
    }
  }

  @override
  Future<void> submitScore(
      {required String quizId,
      required int score,
      String? teamName,
      List<Map<String, dynamic>>? members}) async {
    try {
      await remoteDataSource.submitScore(
          quizId: quizId, score: score, teamName: teamName, members: members);
    } catch (e) {
      rethrow;
    }
  }
}
