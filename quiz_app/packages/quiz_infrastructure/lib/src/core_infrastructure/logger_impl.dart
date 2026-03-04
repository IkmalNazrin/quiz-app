import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';

class LoggerImpl implements LoggerInterface {
  final SupabaseClient? _supabase;

  LoggerImpl([this._supabase]);

  @override
  void d(String message, {LogCategory category = LogCategory.system}) =>
      _log(LogLevel.debug, category, message);

  @override
  void i(String message, {LogCategory category = LogCategory.system}) =>
      _log(LogLevel.info, category, message);

  @override
  void w(String message, {LogCategory category = LogCategory.system}) =>
      _log(LogLevel.warning, category, message);

  @override
  void e(String message,
          {LogCategory category = LogCategory.system,
          Object? error,
          StackTrace? stackTrace}) =>
      _log(LogLevel.error, category, message, error, stackTrace);

  void _log(LogLevel level, LogCategory category, String message,
      [Object? error, StackTrace? stackTrace]) {
    if (kReleaseMode && level == LogLevel.debug) return;

    final String time =
        DateTime.now().toIso8601String().split('T').last.substring(0, 8);
    final String label = level.name.toUpperCase();
    final String catLabel = category.name.toUpperCase();

    dev.log(
      '[$time] [$label] [$catLabel] $message',
      name: 'QuizApp',
      error: error,
      stackTrace: stackTrace,
      level: _getDevLevel(level),
    );

    if (level != LogLevel.debug) {
      _syncToRemote(level, category, message, error, stackTrace);
    }

    if (kDebugMode) {
      // ignore: avoid_print
      print('[$time] [$label] [$catLabel] $message');
      if (error != null) print('Error: $error');
    }
  }

  Future<void> _syncToRemote(
      LogLevel level, LogCategory category, String message,
      [Object? error, StackTrace? stackTrace]) async {
    try {
      if (_supabase == null) return;

      await _supabase!.from('app_logs').insert({
        'user_id': _supabase!.auth.currentUser?.id,
        'level': level.name,
        'category': category.name,
        'message': message,
        'details': {
          'error': error?.toString(),
          'stackTrace': stackTrace?.toString(),
          'device': kIsWeb ? 'web' : defaultTargetPlatform.name,
        },
      });
    } catch (e) {
      debugPrint('Failed to sync log to remote: $e');
    }
  }

  int _getDevLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}

// Singleton pattern for easy migration of existing AppLogger calls.
class AppLogger {
  static LoggerInterface? _instance;

  static void initialize(SupabaseClient supabase) {
    _instance = LoggerImpl(supabase);
  }

  static LoggerInterface get instance => _instance ?? LoggerImpl();

  static void d(String message, {LogCategory category = LogCategory.system}) =>
      instance.d(message, category: category);
  static void i(String message, {LogCategory category = LogCategory.system}) =>
      instance.i(message, category: category);
  static void w(String message, {LogCategory category = LogCategory.system}) =>
      instance.w(message, category: category);
  static void e(String message,
          {LogCategory category = LogCategory.system,
          Object? error,
          StackTrace? stackTrace}) =>
      instance.e(message,
          category: category, error: error, stackTrace: stackTrace);
}
