import 'package:equatable/equatable.dart';

class HostStats extends Equatable {
  final int totalQuizzes;
  final int totalPlays;
  final int totalPlayers;
  final double avgRating;

  const HostStats({
    required this.totalQuizzes,
    required this.totalPlays,
    required this.totalPlayers,
    required this.avgRating,
  });

  factory HostStats.fromJson(Map<String, dynamic> json) {
    return HostStats(
      totalQuizzes: json['total_quizzes'] as int? ?? 0,
      totalPlays: json['total_plays'] as int? ?? 0,
      totalPlayers: json['total_players'] as int? ?? 0,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props =>
      [totalQuizzes, totalPlays, totalPlayers, avgRating];
}
