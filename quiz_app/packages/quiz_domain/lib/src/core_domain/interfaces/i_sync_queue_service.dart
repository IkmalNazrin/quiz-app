abstract class ISyncQueueService {
  Stream<bool> get isSyncingStream;
  Future<void> processQueue(String gamePin);
  Future<void> queueAction({
    required String action,
    required String gamePin,
    required Map<String, dynamic> payload,
  });
  void dispose();
}
