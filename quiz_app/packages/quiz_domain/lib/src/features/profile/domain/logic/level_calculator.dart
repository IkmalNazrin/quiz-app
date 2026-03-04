import 'dart:math' as math;

class LevelCalculator {
  // Base XP for level 1
  static const int baseXP = 100;
  // Multiplier for subsequent levels (growing requirement)
  static const double multiplier = 1.5;

  /// Calculates the level based on total XP using an exponential curve.
  /// XP for level N = baseXP * (multiplier^(N-1))
  /// Logarithmically: Level = floor(log_multiplier(XP / baseXP)) + 1
  static int getLevel(int xp) {
    if (xp < baseXP) return 1;
    return (math.log(xp / baseXP) / math.log(multiplier)).floor() + 1;
  }

  /// Calculates the XP required for a specific level.
  static int getXPForLevel(int level) {
    if (level <= 1) return 0;
    return (baseXP * math.pow(multiplier, level - 1)).round();
  }

  /// Calculates the progress to the next level (0.0 to 1.0).
  static double getLevelProgress(int xp) {
    final currentLevel = getLevel(xp);
    final xpThisLevelStart = getXPForLevel(currentLevel);
    final xpNextLevelStart = getXPForLevel(currentLevel + 1);

    final xpInCurrentLevel = xp - xpThisLevelStart;
    final totalXpNeededForNextLevel = xpNextLevelStart - xpThisLevelStart;

    return (xpInCurrentLevel / totalXpNeededForNextLevel).clamp(0.0, 1.0);
  }

  /// Returns a descriptive rank title based on the level.
  static String getRankTitle(int level) {
    if (level < 5) return 'Novice';
    if (level < 10) return 'Scholar';
    if (level < 20) return 'Expert';
    if (level < 35) return 'Master';
    if (level < 50) return 'Grandmaster';
    if (level < 75) return 'Legend';
    return 'Cosmic Oracle';
  }

  /// Returns a color associated with the rank.
  static List<String> getRankColors(int level) {
    if (level < 5) return ['#9E9E9E', '#757575']; // Grey
    if (level < 10) return ['#4CAF50', '#2E7D32']; // Green
    if (level < 20) return ['#2196F3', '#1565C0']; // Blue
    if (level < 35) return ['#9C27B0', '#6A1B9A']; // Purple
    if (level < 50) return ['#FF9800', '#F57C00']; // Orange
    if (level < 75) return ['#F44336', '#C62828']; // Red
    return ['#E91E63', '#880E4F']; // Pink/Vibrant
  }
}
