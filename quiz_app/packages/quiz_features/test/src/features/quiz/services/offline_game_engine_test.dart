import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_features/src/features/quiz/services/offline_game_engine.dart';
import 'package:quiz_domain/quiz_domain.dart';

class MockOfflineSyncRepository implements IOfflineSyncRepository {
  List<Map<String, dynamic>> cachedMutations = [];

  @override
  Future<void> cacheMutation({
    required String mutationType,
    required Map<String, dynamic> payload,
  }) async {
    cachedMutations.add({
      'mutationType': mutationType,
      'payload': payload,
    });
  }
}

void main() {
  group('OfflineGameEngine', () {
    late OfflineGameEngine engine;
    late MockOfflineSyncRepository mockRepo;

    final mockQuestions = [
      {
        'question': 'What is 2+2?',
        'options': ['3', '4', '5'],
        'correct_index': 1,
        'timer': 2,
      },
      {
        'question': 'Is the earth flat?',
        'options': ['Yes', 'No'],
        'correct_index': 1,
        'timer': 2,
      }
    ];

    setUp(() {
      mockRepo = MockOfflineSyncRepository();
      engine = OfflineGameEngine(
        questions: mockQuestions,
        quizId: 'test-quiz-123',
        username: 'TestUser',
        offlineSyncRepository: mockRepo,
      );
    });

    tearDown(() {
      engine.dispose();
    });

    test('Engine starts and emits playing state', () async {
      final events = <Map<String, dynamic>>[];
      final sub = engine.eventStream.listen(events.add);

      engine.start();

      await Future.delayed(
          const Duration(milliseconds: 100)); // allow microtasks

      expect(events.isNotEmpty, true);
      expect(events.first['event'], 'status');
      expect(events.first['data']['status'], 'playing');

      sub.cancel();
    });

    test('Engine transitions on correct answer', () async {
      final events = <Map<String, dynamic>>[];
      engine.eventStream.listen(events.add);

      engine.start();

      await Future.delayed(const Duration(milliseconds: 100));

      engine.submitAnswer(1); // Correct

      await Future.delayed(
          const Duration(milliseconds: 1500)); // Wait for answer delay

      final roundOverEvent = events.firstWhere(
        (e) => e['event'] == 'status' && e['data']['status'] == 'round_over',
        orElse: () => {},
      );

      expect(roundOverEvent.isNotEmpty, true);
      final playData = roundOverEvent['data']['sessionData']['players'][0];
      expect(playData['isCorrect'], true);
      expect(playData['score'], greaterThan(0));

      // Wait for next question
      await Future.delayed(const Duration(seconds: 4));

      final nextQuestionEvent = events.lastWhere(
        (e) => e['event'] == 'status' && e['data']['status'] == 'playing',
        orElse: () => {},
      );

      expect(nextQuestionEvent.isNotEmpty, true);
    });

    test('Engine completes game and caches mutation', () async {
      engine.start();

      engine.submitAnswer(1); // Q1 Correct
      await Future.delayed(const Duration(seconds: 6)); // wait for transition

      engine.submitAnswer(0); // Q2 Incorrect
      await Future.delayed(const Duration(seconds: 6)); // wait for finish

      expect(mockRepo.cachedMutations.length, 1);
      final mutation = mockRepo.cachedMutations.first;
      expect(mutation['mutationType'], 'offline_game_result');
      expect(mutation['payload']['quiz_id'], 'test-quiz-123');
      expect(mutation['payload']['questions_played'], 2);
    });
  });
}
