import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';

/// A service that interfaces with Supabase Vault for secure secret management.
///
/// Instead of storing sensitive orchestration keys in `.env` files (which can be
/// leaked or hardcoded in client bundles), this service fetches them
/// dynamically from the database vault using a secure RPC.
class VaultService {
  final SupabaseClient _supabase;

  VaultService(this._supabase);

  /// Fetches a decrypted secret from the Supabase Vault.
  ///
  /// Requires a custom RPC: `select get_vault_secret('secret_name')`
  /// which should be restricted by RLS/Permissions.
  Future<String?> getSecret(String name) async {
    try {
      final response = await _supabase.rpc(
        'fn_get_decrypted_secret',
        params: {'p_secret_name': name},
      );

      return response as String?;
    } catch (e) {
      AppLogger.e('VaultService.getSecret("$name") failed: $e');
      return null;
    }
  }

  /// Example usage: Fetching an AI orchestration key for the Genesis engine.
  Future<String?> getAiOrchestratorKey() async {
    return getSecret('AI_GENESIS_INTERNAL_KEY');
  }
}
