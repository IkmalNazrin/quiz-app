import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'rate_limiter.dart';

/// A wrapper around SupabaseClient that enforces client-side rate limiting
/// using a Token Bucket algorithm.
class RateLimitedApiClient {
  final SupabaseClient _client;
  final RateLimiter _limiter;

  RateLimitedApiClient(this._client, this._limiter);

  SupabaseClient get rawClient => _client;

  /// Throws Domain Failure if rate limit is exceeded.
  void _checkLimit() {
    if (!_limiter.consume()) {
      throw const ServerFailure('Too many requests. Please slow down.');
    }
  }

  /// Executes an RPC call within rate limits
  Future<dynamic> rpc(String fn, {Map<String, dynamic>? params}) async {
    _checkLimit();
    return await _client.rpc(fn, params: params);
  }

  /// Exposes the postgrest query builder with limits enforced per termination method
  /// (In a full implementation, this could return a proxied builder, but for this
  /// scope we expect repositories to call _checkLimit() directly before queries if using rawClient,
  /// or we add explicit helper methods for common operations).
  
  /// Helper for direct table selection
  SupabaseQueryBuilder from(String table) {
     return _client.from(table);
  }

  /// Helper enforcing limit
  void consumeToken() {
    _checkLimit();
  }
}
