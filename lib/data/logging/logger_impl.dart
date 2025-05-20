import 'package:logger/logger.dart' as logger;
import 'package:horizon/core/logging/logger.dart';

class LoggerImpl implements Logger {
  final logger.Logger _logger;

  LoggerImpl(this._logger);

  @override
  void trace(String message) {
    _logger.t(message); // Trace level
  }

  @override
  void debug(String message) {
    _logger.d(message); // Debug level
  }

  @override
  void info(String message) {
    _logger.i(message); // Info level
  }

  @override
  void warn(String message) {
    _logger.w(message); // Warning level
  }

  @override
  void error(String message, [Error? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace); // Error level
  }

  @override
  void fatal(String message, [Error? error, StackTrace? stackTrace]) {
    _logger.f(
      message,
      error: message,
      stackTrace: stackTrace,
    ); // Fatal level
  }
}

class LoggerSilent implements Logger {
  final logger.Logger _logger;

  LoggerSilent(this._logger);

  @override
  void trace(String message) {}

  @override
  void debug(String message) {}

  @override
  void info(String message) {}

  @override
  void warn(String message) {}

  @override
  void error(String message, [Error? error, StackTrace? stackTrace]) {}

  @override
  void fatal(String message, [Error? error, StackTrace? stackTrace]) {}
}
