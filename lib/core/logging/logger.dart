abstract class Logger {
  void info(String message);
  void warn(String message);
  void error(String message, [Error? error, StackTrace? stackTrace]);
  void debug(String message);
  void fatal(String message, [Error? error, StackTrace? stackTrace]);
  void trace(String message);
}

