import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:horizon/core/logging/sentry_sanitizer.dart';
import 'package:horizon/domain/services/error_service.dart';

const _sentryReportedKey = 'horizon.sentry.network_error_reported';

/// Keep reporting after retries: a recovered request is not a final failure.
/// Bind retries to their own client so Esplora does not use Counterparty
/// interceptors (including its authentication) on subsequent attempts.
List<Interceptor> networkRetryInterceptors({
  required Dio dio,
  required int retries,
  required List<Duration> retryDelays,
  required String appVersion,
  required ErrorService Function() errorService,
}) =>
    [
      RetryInterceptor(
        dio: dio,
        retries: retries,
        retryDelays: retryDelays,
        retryEvaluator: (error, _) =>
            error.response?.statusCode == 400 ||
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionError,
      ),
      InterceptorsWrapper(onError: (error, handler) {
        if (error.type != DioExceptionType.cancel) {
          reportDioErrorOnce(
            error: error,
            retryCount: error.requestOptions.attempt,
            appVersion: appVersion,
            errorService: errorService(),
          );
        }
        handler.next(error);
      }),
    ];

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
      'failureStage': 'final',
      'appVersion': appVersion,
    },
  );
}
