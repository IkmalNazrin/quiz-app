import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_domain/src/features/profile/domain/logic/level_calculator.dart';

void main() {
  group('LevelCalculator', () {
    test('getLevel returns 1 for XP below base requirement', () {
      expect(LevelCalculator.getLevel(0), 1);
      expect(LevelCalculator.getLevel(99), 1);
    });

    test('getLevel returns correct level for given XP', () {
      expect(LevelCalculator.getLevel(100), 1);
      // Level 2 requires 100 * 1.5 = 150
      expect(LevelCalculator.getLevel(150), 2);
      // Level 3 requires 100 * (1.5)^2 = 225
      expect(LevelCalculator.getLevel(225), 3);
    });

    test('getXPForLevel returns correct thresholds', () {
      expect(LevelCalculator.getXPForLevel(1), 0);
      expect(LevelCalculator.getXPForLevel(2), 150);
      expect(LevelCalculator.getXPForLevel(3), 225);
    });

    test('getLevelProgress calculates correct percentage', () {
      // At 150 XP (start of Level 2), next level (3) is at 225 XP.
      // 150 to 225 is a 75 XP gap. 
      // If XP is 187.5 (midway), progress should be 0.5.
      final progress = LevelCalculator.getLevelProgress(187); // floor 187 is ~49%
      expect(progress, closeTo(0.493, 0.01));
    });

    test('getRankTitle returns expected ranks', () {
      expect(LevelCalculator.getRankTitle(1), 'Novice');
      expect(LevelCalculator.getRankTitle(6), 'Scholar');
      expect(LevelCalculator.getRankTitle(15), 'Expert');
      expect(LevelCalculator.getRankTitle(80), 'Cosmic Oracle');
    });
  });
}
