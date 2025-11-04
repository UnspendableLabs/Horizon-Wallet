import 'package:fpdart/fpdart.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/network_error.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Helper to wrap network calls in TaskEither with proper error handling
///
/// Parameters:
/// - [call] - The async function to execute
/// - [operationName] - Name for logging/Sentry reporting
/// - [customErrorMessage] - Fallback error message
/// - [onError] - Custom error handler. Return null to use default message
TaskEither<String, T> handleNetworkCall<T>(
  Future<T> Function() call, {
  String? operationName,
  String? customErrorMessage,
  String? Function(NetworkError error)? onError,
}) {
  return TaskEither.tryCatch(
    call,
    (error, stackTrace) {
      // Parse error into user-friendly message
      final networkError = NetworkError.fromError(error, stackTrace);

      // Try custom error handler first
      String errorMessage;
      if (onError != null) {
        final customMessage = onError(networkError);
        errorMessage =
            customMessage ?? customErrorMessage ?? networkError.toErrorString();
      } else {
        errorMessage = customErrorMessage ?? networkError.toErrorString();
      }

      Sentry.captureEvent(
        SentryEvent(
          message: SentryMessage(errorMessage),
          level: SentryLevel.error,
          breadcrumbs: [
            Breadcrumb.http(
                url: Uri.parse(networkError.fullUrl ?? 'unknown'),
                method: networkError.type.name)
          ],
        ),
        stackTrace: null,
        hint: Hint.withMap({
          'operation': operationName ?? networkError.endpoint ?? 'unknown',
          'endpoint': networkError.endpoint ?? 'unknown',
          'full_url': networkError.fullUrl ?? 'unknown',
          'error_type': networkError.type.name,
          'status_code': networkError.statusCode?.toString() ?? 'none',
        }),
      );

      return errorMessage;
    },
  );
}

/// Helper to wrap network calls with automatic retry logic
///
/// Only retries on transient failures (timeouts, connection errors, 5xx errors)
///
/// **Sentry Reporting:** Reports to Sentry ONLY ONCE after all retries are exhausted.
/// Individual retry attempts are logged via debugPrint but not sent to Sentry to avoid
/// flooding the error tracking system with duplicate reports.
///
/// Parameters:
/// - [call] - The async function to execute
/// - [maxRetries] - Number of retry attempts (default: 3)
/// - [retryDelay] - Base delay between retries (default: 1 second, uses exponential backoff)
/// - [operationName] - Name for logging/Sentry reporting
/// - [customErrorMessage] - Fallback error message
/// - [onError] - Custom error handler. Return null to use default message
///
TaskEither<String, T> handleNetworkCallWithRetry<T>(
  Future<T> Function() call, {
  int maxRetries = 3,
  Duration retryDelay = const Duration(seconds: 1),
  String? operationName,
  String? customErrorMessage,
  String? Function(NetworkError error)? onError,
}) {
  return TaskEither.tryCatch(
    () async {
      Object? lastError;

      for (int attempt = 1; attempt <= maxRetries + 1; attempt++) {
        try {
          return await call();
        } catch (error, stackTrace) {
          lastError = error;

          // Check if error is retryable
          final networkError = NetworkError.fromError(error, stackTrace);

          if (!networkError.isRetryable || attempt == maxRetries + 1) {
            // Final failure after all retries exhausted

            // IMPORTANT: Only report to Sentry once after all retries are exhausted
            // This prevents flooding Sentry with duplicate error reports
            Sentry.captureEvent(
                SentryEvent(
                    message: SentryMessage(networkError.toErrorString()),
                    level: SentryLevel.error,
                    breadcrumbs: [
                      Breadcrumb.http(
                          url: Uri.parse(networkError.fullUrl ?? 'unknown'),
                          method: networkError.type.name)
                    ]),
                stackTrace: null,
                hint: Hint.withMap(
                  {
                    'operation':
                        operationName ?? networkError.endpoint ?? 'unknown',
                    'endpoint': networkError.endpoint ?? 'unknown',
                    'full_url': networkError.fullUrl ?? 'unknown',
                    'error_type': networkError.type.name,
                    'status_code':
                        networkError.statusCode?.toString() ?? 'none',
                    'retry_attempts': attempt.toString(),
                    'max_attempts': (maxRetries + 1).toString(),
                    'retryable': networkError.isRetryable.toString(),
                  },
                ));
            rethrow;
          }

          // Retryable error - will retry, don't report to Sentry yet
          final retryMsg = operationName != null
              ? '$operationName: Retrying (attempt $attempt/${maxRetries + 1}) - ${networkError.endpoint ?? "unknown endpoint"}'
              : 'Retrying (attempt $attempt/${maxRetries + 1}) - ${networkError.endpoint ?? "unknown endpoint"}';

          debugPrint('Network Error (Retrying): $retryMsg');

          // Wait before retry with exponential backoff
          await Future.delayed(retryDelay * attempt);
        }
      }

      // Should never reach here, but just in case
      throw lastError ?? Exception('Max retries reached');
    },
    (error, stackTrace) {
      final networkError = NetworkError.fromError(error, stackTrace);

      // Try custom error handler first
      String errorMessage;
      if (onError != null) {
        final customMessage = onError(networkError);
        errorMessage =
            customMessage ?? customErrorMessage ?? networkError.toErrorString();
      } else {
        errorMessage = customErrorMessage ?? networkError.toErrorString();
      }

      return errorMessage;
    },
  );
}
