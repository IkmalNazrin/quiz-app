import 'package:equatable/equatable.dart';

class GameHistoryItem extends Equatable {
  final String quizTitle;
  final int score;
  final DateTime playedAt;
  final String quizId;
  final String sessionId;

  const GameHistoryItem({
    required this.quizTitle,
    required this.score,
    required this.playedAt,
    required this.quizId,
    required this.sessionId,
  });

  @override
  List<Object?> get props => [quizTitle, score, playedAt, quizId, sessionId];
}
