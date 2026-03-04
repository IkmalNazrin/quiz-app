abstract class IOfflineSyncRepository {
  /// Caches a game result payload to be synced with the server later when online.
  Future<void> cacheMutation({
    required String mutationType,
    required Map<String, dynamic> payload,
  });
}
