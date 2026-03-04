import 'dart:async';

/// A simple Rate Limiter using the Token Bucket algorithm.
class RateLimiter {
  final int maxTokens;
  final Duration refillInterval;

  int _currentTokens;
  DateTime _lastRefill;

  RateLimiter({
    required this.maxTokens,
    required this.refillInterval,
  })  : _currentTokens = maxTokens,
        _lastRefill = DateTime.now();

  /// Attempts to consume a token. Returns true if successful, false otherwise.
  bool consume() {
    _refill();
    if (_currentTokens > 0) {
      _currentTokens--;
      return true;
    }
    return false;
  }

  void _refill() {
    final now = DateTime.now();
    final timePassed = now.difference(_lastRefill);

    if (timePassed >= refillInterval) {
      final tokensToAdd =
          timePassed.inMilliseconds ~/ refillInterval.inMilliseconds;
      if (tokensToAdd > 0) {
        _currentTokens = (_currentTokens + tokensToAdd).clamp(0, maxTokens);
        _lastRefill = now;
      }
    }
  }

  /// Returns a helper that ignores calls if they occur too frequently.
  static Function(T) throttle<T>(Function(T) action,
      {Duration duration = const Duration(seconds: 1)}) {
    Timer? throttleTimer;
    return (T arg) {
      if (throttleTimer?.isActive ?? false) return;
      action(arg);
      throttleTimer = Timer(duration, () => throttleTimer = null);
    };
  }
}
