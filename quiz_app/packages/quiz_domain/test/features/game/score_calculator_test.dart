import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_domain/src/features/game/domain/services/score_calculator_service.dart';

void main() {
  group('ScoreCalculatorService', () {
    test('returns max points when answered instantly', () {
      final score = ScoreCalculatorService.calculateScore(
        timeLeft: 15,
        totalTime: 15,
        maxPoints: 1000,
      );
      expect(score, 1000);
    });

    test('returns 50% points when answered at half time', () {
      final score = ScoreCalculatorService.calculateScore(
        timeLeft: 10,
        totalTime: 20,
        maxPoints: 1000,
      );
      expect(score, 500);
    });

    test('returns 0 points when time is up', () {
      final score = ScoreCalculatorService.calculateScore(
        timeLeft: 0,
        totalTime: 15,
      );
      expect(score, 0);
    });

    test('returns minimum 10 points for correct answer at very last second', () {
      final score = ScoreCalculatorService.calculateScore(
        timeLeft: 1,
        totalTime: 1000, // 0.1% -> 1 point
        maxPoints: 1000,
      );
      expect(score, 10);
    });

    test('handles negative total time defensively', () {
      final score = ScoreCalculatorService.calculateScore(
        timeLeft: 10,
        totalTime: 0,
      );
      expect(score, 0);
    });
  });
}
