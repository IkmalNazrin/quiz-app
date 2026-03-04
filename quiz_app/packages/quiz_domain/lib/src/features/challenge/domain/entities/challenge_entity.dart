class ChallengeEntity {
  final String id;
  final String quizTitle;
  final String status; // 'pending', 'completed'
  final String challengeType; // '1v1', 'team'

  // Participants
  final String challengerId;
  final String challengerUsername;
  final int challengerScore;

  final String? opponentId;
  final String? opponentUsername;
  final int opponentScore;

  final DateTime createdAt;
  final DateTime? completedAt;

  const ChallengeEntity({
    required this.id,
    required this.quizTitle,
    required this.status,
    required this.challengeType,
    required this.challengerId,
    required this.challengerUsername,
    required this.challengerScore,
    this.opponentId,
    this.opponentUsername,
    required this.opponentScore,
    required this.createdAt,
    this.completedAt,
  });
}
