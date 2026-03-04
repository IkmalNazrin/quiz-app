import 'package:quiz_domain/quiz_domain.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/logger_service.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';

/// Service for explicit security audit logging.
///
/// This service wraps the `fn_log_security_event` RPC to ensure
/// high-integrity logging of administrative and security events.
/// Most organizational changes are audited automatically at the database level,
/// but this service is used for application-level security events
/// like SSO login attempts, sensitive setting changes, etc.
class AuditService {
  final SupabaseClient _supabase;

  AuditService(this._supabase);

  /// Logs a security event to the immutable audit trail.
  Future<void> logEvent(String eventType,
      [Map<String, dynamic>? details]) async {
    try {
      await _supabase.rpc('fn_log_security_event', params: {
        'p_event_type': eventType,
        'p_details': details ?? {},
      });
      AppLogger.i('Security event logged: $eventType',
          category: LogCategory.auth);
    } catch (e) {
      // We log to the general app logs if the security audit fail,
      // but we shouldn't crash.
      AppLogger.e('Failed to log security event: $eventType',
          error: e, category: LogCategory.system);
    }
  }

  /// Specialized method for login events
  Future<void> logLogin(String method,
      {bool success = true, String? error}) async {
    await logEvent(
      success ? 'LOGIN_SUCCESS' : 'LOGIN_FAILURE',
      {
        'method': method,
        if (error != null) 'error': error,
      },
    );
  }
}
