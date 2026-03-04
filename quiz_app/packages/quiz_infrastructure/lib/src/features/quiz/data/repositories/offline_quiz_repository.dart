import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_infrastructure/src/core_infrastructure/database/app_database.dart';

/// Abstract interface for offline quiz storage.
abstract class IOfflineQuizRepository {
  Future<void> saveQuiz(QuizEntity quiz);
  Future<List<QuizEntity>> getCachedQuizzes();
  Future<QuizEntity?> getQuizById(String id);
  Future<void> clearCache();
}

/// Implementation of IOfflineQuizRepository using a local-first strategy.
///
/// In a production environment, this would use `drift` (Moor) or `sqflite`.
/// Here we implement the logic for caching and retrieval.
class OfflineQuizRepository implements IOfflineQuizRepository {
  final AppDatabase _db;

  OfflineQuizRepository(this._db);

  @override
  Future<void> saveQuiz(QuizEntity quiz) async {
    await _db.transaction(() async {
      await _db.into(_db.localQuizzes).insertOnConflictUpdate(
        LocalQuiz(
          id: quiz.id,
          title: quiz.title,
          description: quiz.description,
          category: quiz.category,
          isPublic: quiz.isPublic,
          ownerId: 'local',
          creatorName: quiz.creatorName,
          createdAt: DateTime.now(),
        ),
      );

      for (int i = 0; i < quiz.questions.length; i++) {
        final q = quiz.questions[i];
        final qId = '${quiz.id}_q$i';
        await _db.into(_db.localQuestions).insertOnConflictUpdate(
          LocalQuestion(
            id: qId,
            quizId: quiz.id,
            content: q.question,
            optionsJson: jsonEncode(q.options),
            correctIndex: q.correctAnswerIndex,
            difficulty: q.difficulty,
            timerSeconds: q.timer,
          ),
        );
      }
    });
  }

  @override
  Future<List<QuizEntity>> getCachedQuizzes() async {
    final quizzes = await _db.select(_db.localQuizzes).get();
    final result = <QuizEntity>[];
    for (final q in quizzes) {
      final quizEntity = await getQuizById(q.id);
      if (quizEntity != null) result.add(quizEntity);
    }
    return result;
  }

  @override
  Future<QuizEntity?> getQuizById(String id) async {
    final quizRow = await (_db.select(_db.localQuizzes)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (quizRow == null) return null;

    final questionRows = await (_db.select(_db.localQuestions)..where((tbl) => tbl.quizId.equals(id))).get();
    
    final questions = questionRows.map((q) => QuestionEntity(
      question: q.content,
      options: List<String>.from(jsonDecode(q.optionsJson)),
      correctAnswerIndex: q.correctIndex,
      difficulty: q.difficulty ?? 'medium',
      timer: q.timerSeconds,
    )).toList();

    return QuizEntity(
      id: quizRow.id,
      title: quizRow.title,
      description: quizRow.description ?? '',
      category: quizRow.category ?? '',
      isPublic: quizRow.isPublic,
      creatorName: quizRow.creatorName ?? 'Unknown',
      questions: questions,
    );
  }

  @override
  Future<void> clearCache() async {
    await _db.delete(_db.localQuestions).go();
    await _db.delete(_db.localQuizzes).go();
  }
}

final offlineQuizRepositoryProvider = Provider<IOfflineQuizRepository>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});
