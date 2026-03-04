import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_domain/quiz_domain.dart';

class SupabaseStorageService implements IStorageService {
  final SupabaseClient _client;

  SupabaseStorageService(this._client);

  @override
  Future<String> uploadImage(String bucket, String path, Uint8List bytes) async {
    try {
      await _client.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );
      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      // In a real app we might use ErrorReporterService here
      rethrow;
    }
  }

  @override
  Future<void> deleteImage(String bucket, String path) async {
    try {
      await _client.storage.from(bucket).remove([path]);
    } catch (e) {
      rethrow;
    }
  }
}
