enum LogLevel { debug, info, warning, error }

enum LogCategory { auth, game, network, ui, system, security }

abstract class LoggerInterface {
  void d(String message, {LogCategory category = LogCategory.system});
  void i(String message, {LogCategory category = LogCategory.system});
  void w(String message, {LogCategory category = LogCategory.system});
  void e(String message,
      {LogCategory category = LogCategory.system,
      Object? error,
      StackTrace? stackTrace});
}
