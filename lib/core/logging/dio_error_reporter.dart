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

/// Reports a failed request to Sentry at most once per request, no matter how
/// many interceptors observe the same [DioException] on its way out.
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
  final safeUri = sanitizeTelemetryText(_endpointOf(request.uri));
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

/// [uri] with its query cut down to the parameter names. Query values carry
/// signed transactions, PSBTs, UTXO sets and address lists; dropping all of
/// them cannot miss a new one the way a list of sensitive names can.
String _endpointOf(Uri uri) {
  final names = uri.queryParametersAll.keys;
  return Uri(
    scheme: uri.scheme,
    host: uri.hasAuthority ? uri.host : null,
    port: uri.hasPort ? uri.port : null,
    path: uri.path,
    query: names.isEmpty ? null : names.join('&'),
  ).toString();
}
