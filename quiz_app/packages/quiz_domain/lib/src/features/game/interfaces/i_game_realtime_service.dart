abstract class IGameRealtimeService {
  Stream<List<Map<String, dynamic>>> get playersStream;
  Stream<Map<String, dynamic>> get eventsStream;
  String? get gamePin;

  Future<void> joinRoom({required String gamePin, required String nickname, bool isHost = false});
  Future<void> broadcastEvent(String event, Map<String, dynamic> data);
  Future<void> leaveRoom();
  void dispose();
}
