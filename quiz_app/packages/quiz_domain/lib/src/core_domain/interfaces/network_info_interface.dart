abstract class NetworkInfoInterface {
  Stream<bool> get onConnectivityChanged;
  Future<bool> get isOnline;
}
