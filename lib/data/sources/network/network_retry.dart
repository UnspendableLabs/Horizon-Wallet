import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:horizon/core/logging/dio_error_reporter.dart';
import 'package:horizon/domain/services/error_service.dart';

/// Only transport-level failures are worth retrying. HTTP responses, including
/// 400s, are deterministic answers from the server and would not change.
bool isTransientNetworkFailure(DioException error) =>
    error.type == DioExceptionType.connectionTimeout ||
    error.type == DioExceptionType.receiveTimeout ||
    error.type == DioExceptionType.connectionError;

/// Requests that opted out of retries expect to fail (asset lookups on user
/// input) and cancelled requests were abandoned by the user, so neither is
/// alerted on. Dio delivers a cancellation to every remaining error interceptor
/// as a cancel-typed error, even one that arrives during the retry back-off.
bool isReportableNetworkFailure(DioException error) =>
    !error.requestOptions.disableRetry && error.type != DioExceptionType.cancel;

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
