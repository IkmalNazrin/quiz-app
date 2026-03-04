import 'package:equatable/equatable.dart';

class QuizPerformance extends Equatable {
  final String id;
  final String title;
  final String category;
  final int playCount;
  final double avgRating;

  const QuizPerformance({
    required this.id,
    required this.title,
    required this.category,
    required this.playCount,
    required this.avgRating,
  });

  factory QuizPerformance.fromJson(Map<String, dynamic> json) {
    return QuizPerformance(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String? ?? 'General',
      playCount: int.tryParse(json['play_count']?.toString() ?? '0') ?? 0,
      avgRating: double.tryParse(json['avg_rating']?.toString() ?? '0') ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [id, title, category, playCount, avgRating];
}
