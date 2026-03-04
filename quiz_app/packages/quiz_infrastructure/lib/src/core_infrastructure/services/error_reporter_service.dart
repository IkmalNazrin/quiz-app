import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/logger_service.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';

/// A centralized service for reporting errors throughout the application.
class ErrorReporterService {
  static SupabaseClient? _supabase;

  static void initialize(SupabaseClient supabase) {
    _supabase = supabase;

    // 1. Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleError(details.exception, details.stack, 'Flutter Framework');
    };

    // 2. Catch asynchronous platform-level errors
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      _handleError(error, stack, 'Platform Async');
      return true;
    };

    AppLogger.i('ErrorReporterService: Global error observers initialized.');
  }

  static void report(dynamic error, [StackTrace? stack, String? tag]) {
    _handleError(error, stack, tag ?? 'Manual Report');
  }

  static void _handleError(Object error, [StackTrace? stack, String? context]) {
    AppLogger.e('Unhandled Error [$context]: $error',
        error: error, stackTrace: stack);

    _syncErrorToRemote(error, stack, context);
  }

  static Future<void> _syncErrorToRemote(Object error,
      [StackTrace? stack, String? context]) async {
    try {
      if (_supabase == null) return;

      await _supabase!.from('server_errors').insert({
        'user_id': _supabase!.auth.currentUser?.id,
        'error_message': error.toString(),
        'stack_trace': stack?.toString(),
        'context': context,
        'metadata': {
          'app_version': '1.0.0', // Could use package_info_plus in real app
          'platform': defaultTargetPlatform.name,
          'is_release': kReleaseMode,
        },
      });
    } catch (e) {
      debugPrint('Failed to sync error to remote: $e');
    }
  }
}
