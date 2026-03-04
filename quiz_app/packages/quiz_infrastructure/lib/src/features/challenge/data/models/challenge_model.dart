import 'package:quiz_domain/quiz_domain.dart';

class ChallengeModel extends ChallengeEntity {
  const ChallengeModel({
    required super.id,
    required super.quizTitle,
    required super.status,
    required super.challengeType,
    required super.challengerId,
    required super.challengerUsername,
    required super.challengerScore,
    super.opponentId,
    super.opponentUsername,
    required super.opponentScore,
    required super.createdAt,
    super.completedAt,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    // Handling different potential structures for 1v1 vs Team
    final isTeam = json['challengeType'] == 'team';

    String challengerId;
    String challengerName;
    int challengerScore;

    String? opponentId;
    String? opponentName;
    int opponentScore;

    if (isTeam) {
      // Mapping team structure to flat entity
      final challengerTeam = json['challengerTeam'] ?? json['challenger_team'];
      final opponentTeam = json['opponentTeam'] ?? json['opponent_team'];

      challengerId =
          (challengerTeam?['_id'] ?? challengerTeam?['id'] ?? '').toString();
      challengerName = challengerTeam?['teamName'] ??
          challengerTeam?['team_name'] ??
          'Unknown Team';
      challengerScore = (challengerTeam?['score'] as num?)?.toInt() ?? 0;

      opponentId = opponentTeam?['_id'] ?? opponentTeam?['id'];
      opponentName = opponentTeam?['teamName'] ??
          opponentTeam?['team_name'] ??
          'Unknown Team';
      opponentScore = (opponentTeam?['score'] as num?)?.toInt() ?? 0;
    } else {
      challengerId =
          (json['challengerId'] ?? json['challenger_id'] ?? '').toString();
      challengerName = json['challengerUsername'] ??
          json['challenger_username'] ??
          'Unknown User';
      challengerScore =
          (json['challengerScore'] ?? json['challenger_score'] as num?)
                  ?.toInt() ??
              0;

      opponentId = (json['opponentId'] ?? json['opponent_id'])?.toString();
      opponentName = json['opponentUsername'] ??
          json['opponent_username'] ??
          'Unknown User';
      opponentScore =
          (json['opponentScore'] ?? json['opponent_score'] as num?)?.toInt() ??
              0;
    }

    return ChallengeModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      quizTitle: json['quizTitle'] ?? json['quiz_title'] ?? 'Untitled Quiz',
      status: json['status'] ?? 'pending',
      challengeType: json['challengeType'] ?? json['challenge_type'] ?? '1v1',
      challengerId: challengerId,
      challengerUsername: challengerName,
      challengerScore: challengerScore,
      opponentId: opponentId,
      opponentUsername: opponentName,
      opponentScore: opponentScore,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now()),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : (json['completed_at'] != null
              ? DateTime.parse(json['completed_at'])
              : null),
    );
  }
}
