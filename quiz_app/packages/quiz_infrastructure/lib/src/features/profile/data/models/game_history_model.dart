import 'package:quiz_domain/quiz_domain.dart';

class GameHistoryModel extends GameHistoryItem {
  const GameHistoryModel({
    required super.quizTitle,
    required super.score,
    required super.playedAt,
    required super.quizId,
    required super.sessionId,
  });

  factory GameHistoryModel.fromJson(Map<String, dynamic> json) {
    // Note: The structure depends on the Supabase query.
    // Expecting join structure:
    // {
    //   "score": 123,
    //   "joined_at": "...",
    //   "session_id": "...",
    //   "game_sessions": {
    //     "quiz_id": "...",
    //     "quizzes": { "title": "..." }
    //   }
    // }

    final session = json['game_sessions'] as Map<String, dynamic>? ?? {};
    final quiz = session['quizzes'] as Map<String, dynamic>? ?? {};

    return GameHistoryModel(
      quizTitle: quiz['title'] as String? ?? 'Unknown Quiz',
      score: json['score'] as int? ?? 0,
      playedAt: DateTime.tryParse(json['joined_at'] as String? ?? '') ??
          DateTime.now(),
      quizId: session['quiz_id'] as String? ?? '',
      sessionId: json['session_id'] as String? ?? '',
    );
  }
}
