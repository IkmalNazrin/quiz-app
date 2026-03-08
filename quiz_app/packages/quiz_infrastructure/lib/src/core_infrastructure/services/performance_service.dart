import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../logger_impl.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';

/// A simple utility to trace performance and identify bottlenecks.
class PerformanceService {
  static SupabaseClient? _supabase;
  static final Map<String, Stopwatch> _activeTraces = {};

  static void initialize(SupabaseClient supabase) {
    _supabase = supabase;
  }

  /// Starts a performance trace with the given name.
  static void startTrace(String name) {
    _activeTraces[name] = Stopwatch()..start();
    AppLogger.d('PerformanceService: Starting trace "$name"');
  }

  /// Stops a performance trace and logs the duration.
  static Duration stopTrace(String name) {
    final stopwatch = _activeTraces.remove(name);
    if (stopwatch == null) {
      AppLogger.w(
          'PerformanceService: Attempted to stop non-existent trace "$name"');
      return Duration.zero;
    }

    stopwatch.stop();
    final duration = stopwatch.elapsed;

    if (duration.inMilliseconds > 500) {
      AppLogger.w(
          'PerformanceService: Trace "$name" took ${duration.inMilliseconds}ms (POTENTIAL BOTTLENECK)');
    } else {
      AppLogger.i(
          'PerformanceService: Trace "$name" completed in ${duration.inMilliseconds}ms');
    }

    _syncTraceToRemote(name, duration);

    return duration;
  }

  /// Wraps an asynchronous operation with a performance trace.
  static Future<T> trace<T>(String name, Future<T> Function() operation) async {
    startTrace(name);
    try {
      return await operation();
    } finally {
      stopTrace(name);
    }
  }

  static Future<void> _syncTraceToRemote(String name, Duration duration) async {
    try {
      if (_supabase == null) return;

      await _supabase!.from('app_performance').insert({
        'user_id': _supabase!.auth.currentUser?.id,
        'trace_name': name,
        'duration_ms': duration.inMilliseconds,
        'metadata': {
          'platform': defaultTargetPlatform.name,
          'is_release': kReleaseMode,
        },
      });
    } catch (e) {
      debugPrint('Failed to sync performance trace to remote: $e');
    }
  }
}
