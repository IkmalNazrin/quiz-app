import 'package:flutter_riverpod/flutter_riverpod.dart';


// DataSource Provider
import 'package:quiz_domain/quiz_domain.dart';


// Repository Provider
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});

// State (Family Future Provider)
// Used to fetch leaderboard data based on quizId and type (team vs individual)
final leaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, LeaderboardParams>(
        (ref, params) async {
  final repository = ref.watch(leaderboardRepositoryProvider);
  return repository.fetchLeaderboard(params.quizId, isTeam: params.isTeam);
});

class LeaderboardParams {
  final String quizId;
  final bool isTeam;

  LeaderboardParams({required this.quizId, required this.isTeam});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderboardParams &&
          runtimeType == other.runtimeType &&
          quizId == other.quizId &&
          isTeam == other.isTeam;

  @override
  int get hashCode => quizId.hashCode ^ isTeam.hashCode;
}
