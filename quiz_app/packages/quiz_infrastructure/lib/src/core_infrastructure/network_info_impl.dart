import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'logger_impl.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';

class NetworkInfoImpl implements NetworkInfoInterface {
  final Connectivity _connectivity = Connectivity();
  final _statusController = StreamController<bool>.broadcast();
  final LoggerInterface _logger;

  NetworkInfoImpl({LoggerInterface? logger})
      : _logger = logger ?? AppLogger.instance {
    _init();
  }

  @override
  Stream<bool> get onConnectivityChanged => _statusController.stream;

  @override
  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return _isResultOnline(result);
  }

  void _init() {
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final online = _isResultOnline(results);
      _logger.d('Connectivity changed: ${online ? 'ONLINE' : 'OFFLINE'}',
          category: LogCategory.network);
      _statusController.add(online);
    });
  }

  bool _isResultOnline(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((result) => result != ConnectivityResult.none);
  }

  void dispose() {
    _statusController.close();
  }
}
