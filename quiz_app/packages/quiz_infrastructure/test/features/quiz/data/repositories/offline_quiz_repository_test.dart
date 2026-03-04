import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';

void main() {
  late AppDatabase database;
  late OfflineQuizRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = OfflineQuizRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('OfflineQuizRepository', () {
    final tQuestion = QuestionEntity(
      question: 'Test Q',
      options: ['A', 'B', 'C', 'D'],
      correctAnswerIndex: 0,
      difficulty: 'easy',
      timer: 30,
      type: 'multiple_choice',
      points: 1000,
    );
    
    final tQuiz = QuizEntity(
      id: 'quiz_1',
      title: 'Local Quiz',
      description: 'Desc',
      category: 'General',
      isPublic: true,
      creatorName: 'User',
      questions: [tQuestion],
    );

    test('saveQuiz and getQuizById works correctly', () async {
      await repository.saveQuiz(tQuiz);
      final result = await repository.getQuizById('quiz_1');
      expect(result?.title, 'Local Quiz');
      expect(result?.questions.length, 1);
      expect(result?.questions[0].question, 'Test Q');
    });

    test('getCachedQuizzes returns all saved quizzes', () async {
      await repository.saveQuiz(tQuiz);
      final list = await repository.getCachedQuizzes();
      expect(list.length, 1);
      expect(list.first.id, 'quiz_1');
    });

    test('clearCache removes all quizzes', () async {
      await repository.saveQuiz(tQuiz);
      await repository.clearCache();
      final list = await repository.getCachedQuizzes();
      expect(list.isEmpty, true);
    });
  });
}
