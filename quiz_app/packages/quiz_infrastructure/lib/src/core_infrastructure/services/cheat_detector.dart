import 'dart:math';

/// A service that monitors user answer timing for anomalies.
///
/// In a production environment, this helps identify bots or scripts that
/// respond with inhuman consistency (e.g., exactly 500ms every time).
class CheatDetectorService {
  final List<double> _responseTimes = [];
  static const int _minSamples = 5;
  static const double _stdDevThreshold = 0.05; // 50ms consistency is suspicious

  /// Logs a response time for the current session.
  void recordResponse(Duration duration) {
    _responseTimes.add(duration.inMilliseconds / 1000.0);
  }

  /// Reset the detector for a new game session.
  void reset() {
    _responseTimes.clear();
  }

  /// Calculates the standard deviation of response times.
  /// Low standard deviation indicates suspicious consistency.
  bool isSuspicious() {
    if (_responseTimes.length < _minSamples) return false;

    final mean = _responseTimes.reduce((a, b) => a + b) / _responseTimes.length;
    final variance =
        _responseTimes.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) /
            _responseTimes.length;
    final stdDev = sqrt(variance);

    // If the variation is extremely low (e.g., answering within 10ms of the same time 5 times), mark as suspicious.
    return stdDev < _stdDevThreshold;
  }

  double get averageResponseTime {
    if (_responseTimes.isEmpty) return 0.0;
    return _responseTimes.reduce((a, b) => a + b) / _responseTimes.length;
  }
}
