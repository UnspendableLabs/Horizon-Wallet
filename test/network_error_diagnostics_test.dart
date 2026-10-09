import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/core/logging/network_error_diagnostics.dart';

void main() {
  test('uses the configured timeout for the phase that failed', () {
    final request = RequestOptions(path: '/balance',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      sendTimeout: const Duration(milliseconds: 1500));
    expect(configuredTimeoutLabel(DioException(requestOptions: request,
      type: DioExceptionType.connectionTimeout)), 'Timeout (5s)');
    expect(configuredTimeoutLabel(DioException(requestOptions: request,
      type: DioExceptionType.receiveTimeout)), 'Timeout (3s)');
    expect(configuredTimeoutLabel(DioException(requestOptions: request,
      type: DioExceptionType.sendTimeout)), 'Timeout (1.5s)');
  });
  test('does not invent a duration when the timeout is unspecified', () {
    expect(configuredTimeoutLabel(DioException(
      requestOptions: RequestOptions(path: '/balance'),
      type: DioExceptionType.receiveTimeout)), 'Timeout');
  });
  test('non-JSON outage responses do not crash error reporting', () {
    for (final data in [null, '<html>503 unavailable</html>', ['error'], 503]) {
      expect(apiErrorMessage(data), isNull);
    }
  });
  test('retains API error messages', () {
    expect(apiErrorMessage({'error': 'Insufficient funds'}), 'Insufficient funds');
    expect(apiErrorMessage({'result': null}), isNull);
  });
}
