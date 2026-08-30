import 'package:dio/dio.dart';
import 'package:horizon/core/logging/sentry_sanitizer.dart';
import 'package:horizon/domain/services/error_service.dart';

const _sentryReportedKey = 'horizon.sentry.network_error_reported';

class NetworkRequestException implements Exception {
  final String message;

  const NetworkRequestException(this.message);

  @override
  String toString() => 'NetworkRequestException: $message';
}

void reportDioErrorOnce({
  required DioException error,
  required int retryCount,
  required String appVersion,
  required ErrorService errorService,
}) {
  final request = error.requestOptions;
  if (request.extra[_sentryReportedKey] == true) {
    return;
  }
  request.extra[_sentryReportedKey] = true;

  final statusCode = error.response?.statusCode;
  final safeUri = sanitizeTelemetryText(request.uri.toString());
  final status = statusCode?.toString() ?? 'connection_failed';
  final exception = NetworkRequestException(
    '${error.type.name}: ${request.method} $safeUri ($status)',
  );

  errorService.captureException(
    exception,
    stackTrace: error.stackTrace,
    message: exception.toString(),
    context: {
      'errorType': error.type.name,
      'statusCode': status,
      'method': request.method,
      'url': safeUri,
      'retryCount': retryCount,
      'appVersion': appVersion,
    },
  );
}
