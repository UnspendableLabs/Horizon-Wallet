import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:horizon/core/logging/dio_error_reporter.dart';
import 'package:horizon/domain/services/error_service.dart';

/// Only known read endpoints may be replayed. Counterparty compose uses GET
/// too, so the HTTP method alone is not a sufficient safety boundary.
bool isRetryableNetworkRead(RequestOptions request) {
  if (request.method.toUpperCase() != 'GET') return false;
  final path = request.uri.path.replaceFirst(RegExp(r'^/v2(?=/|$)'), '');
  return path == '/blocks/tip/height' ||
      path == '/fee-estimates' ||
      path == '/api/v1/fees/recommended' ||
      path == '/bitcoin/estimatesmartfee' ||
      RegExp(r'^/address/[^/]+(?:/utxo|/txs(?:/mempool|/chain(?:/[^/]+)?)?)?$')
          .hasMatch(path) ||
      RegExp(r'^/tx/[^/]+(?:/hex)?$').hasMatch(path) ||
      RegExp(r'^/addresses/(?:balances|events|mempool|transactions)$')
          .hasMatch(path) ||
      RegExp(r'^/addresses/[^/]+/(?:balances(?:/[^/]+)?|fairminters|assets/owned)$')
          .hasMatch(path) ||
      RegExp(r'^/assets/[^/]+$').hasMatch(path) ||
      RegExp(r'^/utxos/[^/]+/balances$').hasMatch(path) ||
      RegExp(r'^/bitcoin/addresses(?:/[^/]+)?/utxos$').hasMatch(path);
}

/// Caller cancellation, TLS failures, validation/auth errors and unknown GET
/// endpoints are terminal. Temporary service responses share the existing
/// bounded retry count/delays; no new client or fallback host is introduced.
bool isTransientNetworkFailure(DioException error) =>
    isRetryableNetworkRead(error.requestOptions) &&
    (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.type == DioExceptionType.badResponse &&
            const {429, 502, 503, 504}.contains(error.response?.statusCode)));

/// A 404 is an expected answer (asset lookups on user-typed names fail by
/// design) and cancelled requests were abandoned by the user, so neither is
/// alerted on. Opting out of retries does not opt out of reporting: a request
/// that skips retries still fails for real when the server is unreachable.
/// Dio delivers a cancellation to every remaining error interceptor as a
/// cancel-typed error, even one that arrives during the retry back-off.
bool isReportableNetworkFailure(DioException error) =>
    error.type != DioExceptionType.cancel && error.response?.statusCode != 404;

/// Retries [dio] requests on transient failures and reports the ones that still
/// fail afterwards. Retries go through [dio] itself so each client keeps its own
/// interceptors: Esplora must not pick up the Counterparty authentication.
///
/// Errors flow through interceptors in order, so the reporter is placed after
/// [RetryInterceptor] and only ever sees the error the retries settled on.
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
        retryEvaluator: (error, _) => isTransientNetworkFailure(error),
      ),
      InterceptorsWrapper(onError: (error, handler) {
        if (isReportableNetworkFailure(error)) {
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
