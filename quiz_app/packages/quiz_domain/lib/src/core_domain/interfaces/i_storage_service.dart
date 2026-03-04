import 'dart:typed_data';

abstract class IStorageService {
  Future<String> uploadImage(String bucket, String path, Uint8List bytes);
  Future<void> deleteImage(String bucket, String path);
}
