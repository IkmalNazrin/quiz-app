class QuizEntity {
  final String id;
  final String title;
  final String? description;
  final bool isPublic;
  final List<QuestionEntity> questions;
  final String category;
  final String? creatorName;
  final String? imageUrl;
  final int playCount;
  final String powerUpMode;
  final String? organizationId;

  const QuizEntity({
    required this.id,
    required this.title,
    this.description,
    required this.isPublic,
    required this.questions,
    required this.category,
    this.creatorName,
    this.imageUrl,
    this.playCount = 0,
    this.powerUpMode = 'balanced',
    this.organizationId,
  });
}

class QuestionEntity {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String difficulty;
  final int timer;
  final String? imageUrl;
  final String type; // 'multiple_choice', 'true_false', etc.
  final int points;

  const QuestionEntity({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.difficulty,
    required this.timer,
    this.imageUrl,
    this.type = 'multiple_choice',
    this.points = 1000,
  });
}
