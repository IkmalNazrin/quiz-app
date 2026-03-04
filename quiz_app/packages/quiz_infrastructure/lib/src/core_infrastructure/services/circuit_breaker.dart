import 'dart:async';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';

enum CircuitState { closed, open, halfOpen }

/// Implementation of the Circuit Breaker pattern.
///
/// Protects the application from cascading failures when a
/// downstream service (like AI Genesis or Supabase Edge) is
/// experiencing issues.
class CircuitBreaker {
  final String serviceName;
  final int failureThreshold;
  final Duration resetTimeout;

  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  DateTime? _lastFailureTime;

  // Removed instance _logger

  CircuitBreaker({
    required this.serviceName,
    this.failureThreshold = 3,
    this.resetTimeout = const Duration(minutes: 5),
  });

  CircuitState get state => _state;

  /// Executes the provided [action] if the circuit is closed or half-open.
  Future<T> execute<T>(Future<T> Function() action) async {
    if (_state == CircuitState.open) {
      if (DateTime.now().difference(_lastFailureTime!) > resetTimeout) {
        AppLogger.i(
            'CircuitBreaker: Circuit for [$serviceName] moving to HALF-OPEN (testing recovery)');
        _state = CircuitState.halfOpen;
      } else {
        AppLogger.w(
            'CircuitBreaker: Circuit for [$serviceName] is OPEN. Fast-failing request.');
        throw Exception(
            'Service [$serviceName] is temporarily unavailable (Circuit Open)');
      }
    }

    try {
      final result = await action();
      _onSuccess();
      return result;
    } catch (e) {
      _onFailure(e);
      rethrow;
    }
  }

  void _onSuccess() {
    if (_state != CircuitState.closed) {
      AppLogger.i(
          'CircuitBreaker: Circuit for [$serviceName] closed successfully.');
    }
    _state = CircuitState.closed;
    _failureCount = 0;
  }

  void _onFailure(Object e) {
    _failureCount++;
    _lastFailureTime = DateTime.now();
    AppLogger.e(
        'CircuitBreaker: Failure in service [$serviceName] ($_failureCount/$failureThreshold)');

    if (_failureCount >= failureThreshold) {
      AppLogger.e(
          'CircuitBreaker: Circuit for [$serviceName] tripped! Moving to OPEN state.');
      _state = CircuitState.open;
    }
  }
}
