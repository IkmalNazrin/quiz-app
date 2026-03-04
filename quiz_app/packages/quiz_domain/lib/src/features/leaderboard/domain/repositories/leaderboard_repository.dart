import '../entities/leaderboard_entry.dart';

abstract class LeaderboardRepository {
  Future<List<LeaderboardEntry>> fetchLeaderboard(String quizId,
      {required bool isTeam});
  Future<void> submitScore(
      {required String quizId,
      required int score,
      String? teamName,
      List<Map<String, dynamic>>? members});
}
