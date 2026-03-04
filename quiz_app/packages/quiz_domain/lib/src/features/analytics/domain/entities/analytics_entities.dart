import 'package:equatable/equatable.dart';

class SessionAnalytics extends Equatable {
  final String sessionId;
  final String hostId;
  final String gamePin;
  final int totalPlayers;
  final int topScore;
  final double averageScore;
  final int totalAnswers;
  final DateTime createdAt;
  final String status;
  final double? accuracyRate;

  const SessionAnalytics({
    required this.sessionId,
    required this.hostId,
    required this.gamePin,
    required this.totalPlayers,
    required this.topScore,
    required this.averageScore,
    required this.totalAnswers,
    required this.createdAt,
    required this.status,
    this.accuracyRate,
  });

  factory SessionAnalytics.fromMap(Map<String, dynamic> map) {
    return SessionAnalytics(
      sessionId: map['session_id'] as String,
      hostId: map['host_id'] as String,
      gamePin: map['game_pin'] as String,
      totalPlayers: map['total_players'] as int? ?? 0,
      topScore: map['top_score'] as int? ?? 0,
      averageScore: (map['average_score'] as num?)?.toDouble() ?? 0.0,
      totalAnswers: map['total_answers_submitted'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      status: map['status'] as String,
      accuracyRate: (map['accuracy_rate'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        sessionId,
        hostId,
        gamePin,
        totalPlayers,
        topScore,
        averageScore,
        totalAnswers,
        createdAt,
        status,
        accuracyRate,
      ];
}

class QuestionAnalytics extends Equatable {
  final int questionIndex;
  final int totalResponses;
  final int correctCount;
  final double avgResponseTime;
  final double accuracyRate;

  const QuestionAnalytics({
    required this.questionIndex,
    required this.totalResponses,
    required this.correctCount,
    required this.avgResponseTime,
    required this.accuracyRate,
  });

  factory QuestionAnalytics.fromMap(Map<String, dynamic> map) {
    return QuestionAnalytics(
      questionIndex: map['question_index'] as int,
      totalResponses: map['total_responses'] as int,
      correctCount: map['correct_count'] as int,
      avgResponseTime:
          (map['avg_response_time_seconds'] as num?)?.toDouble() ?? 0.0,
      accuracyRate: (map['accuracy_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
        questionIndex,
        totalResponses,
        correctCount,
        avgResponseTime,
        accuracyRate,
      ];
}

class HostMetrics extends Equatable {
  final int sessionsHosted;
  final int lifetimePlayers;
  final double globalAvgScore;
  final int peakPlayerCount;

  const HostMetrics({
    required this.sessionsHosted,
    required this.lifetimePlayers,
    required this.globalAvgScore,
    required this.peakPlayerCount,
  });

  factory HostMetrics.fromMap(Map<String, dynamic> map) {
    return HostMetrics(
      sessionsHosted: map['sessions_hosted'] as int? ?? 0,
      lifetimePlayers: map['lifetime_players'] as int? ?? 0,
      globalAvgScore: (map['global_avg_score'] as num?)?.toDouble() ?? 0.0,
      peakPlayerCount: map['peak_player_count'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        sessionsHosted,
        lifetimePlayers,
        globalAvgScore,
        peakPlayerCount,
      ];
}
