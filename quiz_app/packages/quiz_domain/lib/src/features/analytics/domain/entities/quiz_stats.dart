import 'package:equatable/equatable.dart';

class QuizStats extends Equatable {
  final String quizId;
  final int playCount;
  final double avgScore;
  final double completionRate;

  const QuizStats({
    required this.quizId,
    required this.playCount,
    required this.avgScore,
    this.completionRate = 0.0,
  });

  factory QuizStats.fromJson(Map<String, dynamic> json) {
    return QuizStats(
      quizId: json['quiz_id'] as String? ?? '',
      playCount: json['play_count'] as int? ?? 0,
      avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0.0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [quizId, playCount, avgScore, completionRate];
}
