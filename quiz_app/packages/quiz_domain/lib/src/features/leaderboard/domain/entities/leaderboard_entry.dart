class LeaderboardEntry {
  final int score;
  final String? userId; // For individual scores
  final String? username;
  final String? picture;
  final String? teamName; // For team scores
  final List<LeaderboardMember>? members; // For team scores

  const LeaderboardEntry({
    required this.score,
    this.userId,
    this.username,
    this.picture,
    this.teamName,
    this.members,
  });

  // Adding Equatable behavior manually if needed, or just keeping it simple
}

class LeaderboardMember {
  final String userId;
  final String username;
  final String? picture;

  const LeaderboardMember({
    required this.userId,
    required this.username,
    this.picture,
  });
}
