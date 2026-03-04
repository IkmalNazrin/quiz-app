import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_domain/quiz_domain.dart';

final secureStorageServiceProvider = Provider<LocalStorageInterface>((ref) {
  return LocalStorageImpl();
});

class LocalStorageImpl implements LocalStorageInterface {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  @override
  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

class SupabaseSecureStorage extends LocalStorage {
  final LocalStorageInterface _service;

  SupabaseSecureStorage(this._service);

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async {
    final token = await accessToken();
    return token != null;
  }

  @override
  Future<String?> accessToken() async {
    return _service.read(supabasePersistSessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _service.save(supabasePersistSessionKey, persistSessionString);
  }

  @override
  Future<void> removePersistedSession() async {
    await _service.delete(supabasePersistSessionKey);
  }
}

const supabasePersistSessionKey = 'SUPABASE_PERSIST_SESSION_KEY';
