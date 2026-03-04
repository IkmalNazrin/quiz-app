class ScoreCalculatorService {
  /// Calculates the score for a correct answer based on time left.
  ///
  /// [timeLeft]: The time remaining in seconds when the answer was submitted.
  /// [totalTime]: The total time allowed for the question in seconds.
  /// [maxPoints]: The maximum points awarded for an instant correct answer (default: 1000).
  static int calculateScore({
    required int timeLeft,
    required int totalTime,
    int maxPoints = 1000,
  }) {
    if (totalTime <= 0) return 0;

    // Ensure timeLeft doesn't exceed totalTime (defensive)
    final actualTimeLeft = timeLeft > totalTime ? totalTime : timeLeft;

    // Formula: (TimeLeft / TotalTime) * MaxPoints
    final double percentage = actualTimeLeft / totalTime;
    final int score = (percentage * maxPoints).round();

    // Ensure strictly positive point for correct answer even at last second?
    // Let's say minimum 10 points if timeLeft > 0
    if (actualTimeLeft > 0 && score < 10) {
      return 10;
    }

    return score;
  }
}
