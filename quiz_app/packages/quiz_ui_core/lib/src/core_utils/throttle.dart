import 'dart:async';

class Throttler {
  final Duration delay;
  Timer? _timer;

  Throttler({this.delay = const Duration(seconds: 2)});

  void run(void Function() action) {
    if (_timer?.isActive ?? false) return;
    action();
    _timer = Timer(delay, () => _timer = null);
  }

  bool get isActive => _timer?.isActive ?? false;
}
