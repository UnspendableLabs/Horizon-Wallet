import 'package:dio/dio.dart';

/// Proxy HTML, text and list responses are not the API's JSON error envelope.
String? apiErrorMessage(dynamic data) {
  if (data is! Map) return null;
  return data['error']?.toString();
}

String configuredTimeoutLabel(DioException error) {
  final duration = switch (error.type) {
    DioExceptionType.connectionTimeout => error.requestOptions.connectTimeout,
    DioExceptionType.receiveTimeout => error.requestOptions.receiveTimeout,
    DioExceptionType.sendTimeout => error.requestOptions.sendTimeout,
    _ => null,
  };
  if (duration == null || duration.inMilliseconds <= 0) return 'Timeout';
  final seconds = duration.inMilliseconds % 1000 == 0
      ? duration.inSeconds.toString()
      : (duration.inMilliseconds / 1000).toString();
  return 'Timeout (${seconds}s)';
}
