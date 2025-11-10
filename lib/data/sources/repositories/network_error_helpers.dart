import 'dart:math';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/network_error.dart';

/// Helper to wrap network calls with automatic retry logic
///
/// Only retries on transient failures (timeouts, connection errors, 5xx errors)
///
/// Individual retry attempts are logged via debugPrint.
/// The [onError] callback is called on the final attempt after all retries are exhausted.
///
/// Parameters:
/// - [call] - The async function to execute
/// - [maxRetries] - Number of retry attempts (default: 3)
/// - [retryDelay] - Base delay between retries (default: 1 second, uses exponential backoff)
/// - [onError] - Custom error handler called on final failure. Return null to use default NetworkError
///
TaskEither<NetworkError, T> handleNetworkCall<T>(
  Future<T> Function() call, {
  int maxRetries = 3,
  Duration retryDelay = const Duration(seconds: 1),
  NetworkError? Function(NetworkError error)? onError,
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

            // Log final error message
            final errorMessage = networkError.toErrorString();
            debugPrint('Network Error (Final): $errorMessage');

            rethrow;
          }

          // Wait before retry with exponential backoff
          // Formula: retryDelay * 2^(attempt-1)
          // e.g., with 1s base: 1s, 2s, 4s, 8s...
          final backoffDelay = retryDelay * pow(2, attempt - 1);
          await Future.delayed(backoffDelay);
        }
      }

      // Should never reach here, but just in case
      throw lastError ?? Exception('Max retries reached');
    },
    (error, stackTrace) {
      final networkError = NetworkError.fromError(error, stackTrace);

      // Try custom error handler first
      if (onError != null) {
        final customError = onError(networkError);
        return customError ?? networkError;
      }

      return networkError;
    },
  );
}
