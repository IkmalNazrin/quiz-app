import 'package:quiz_domain/quiz_domain.dart';

class QuizModel extends QuizEntity {
  const QuizModel({
    required super.id,
    required super.title,
    super.description,
    required super.isPublic,
    required List<QuestionModel> super.questions,
    required super.category,
    super.creatorName,
    super.imageUrl,
    super.playCount = 0,
    super.powerUpMode = 'balanced',
    super.organizationId,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    // Extract username from joined profiles if available
    String? creator;
    if (json['profiles'] != null && json['profiles'] is Map) {
      creator = json['profiles']['username'];
    }

    return QuizModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? 'Untitled Quiz',
      description: json['description'],
      isPublic: json['isPublic'] ?? json['is_public'] ?? false,
      category: json['category'] ?? 'General',
      creatorName: creator,
      imageUrl: json['imageUrl'] ?? json['image_url'],
      playCount: json['playCount'] ?? json['play_count'] ?? 0,
      powerUpMode: json['powerUpMode'] ?? json['power_up_mode'] ?? 'balanced',
      organizationId: json['organization_id'],
      questions: (json['questions'] as List?)
              ?.map((q) => QuestionModel.fromJson(q))
              .toList() ??
          [],
    );
  }

  factory QuizModel.fromSupabase(Map<String, dynamic> map) =>
      QuizModel.fromJson(map);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isPublic': isPublic,
        'category': category,
        'imageUrl': imageUrl,
        'play_count': playCount,
        'power_up_mode': powerUpMode,
        'organization_id': organizationId,
        'questions': questions.map((q) {
          if (q is QuestionModel) return q.toJson();
          return QuestionModel(
            question: q.question,
            options: q.options,
            correctAnswerIndex: q.correctAnswerIndex,
            difficulty: q.difficulty,
            timer: q.timer,
            imageUrl: q.imageUrl,
            type: q.type,
            points: q.points,
          ).toJson();
        }).toList(),
      };
}

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.question,
    required super.options,
    required super.correctAnswerIndex,
    required super.difficulty,
    required super.timer,
    super.imageUrl,
    super.type = 'multiple_choice',
    super.points = 1000,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      question: json['question'] ?? json['content'],
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex:
          json['correctAnswerIndex'] ?? json['correct_index'] ?? 0,
      difficulty: json['difficulty'] ?? 'Easy',
      timer: json['timer'] ?? json['timer_seconds'] ?? 10,
      imageUrl: json['imageUrl'] ?? json['image_url'],
      type: json['type'] ?? 'multiple_choice',
      points: json['points'] ?? 1000,
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctAnswerIndex': correctAnswerIndex,
        'difficulty': difficulty,
        'timer': timer,
        'imageUrl': imageUrl,
        'type': type,
        'points': points,
      };
}
