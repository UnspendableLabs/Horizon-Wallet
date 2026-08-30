import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/core/logging/dio_error_reporter.dart';
import 'package:horizon/core/logging/sentry_sanitizer.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:mocktail/mocktail.dart';

class MockErrorService extends Mock implements ErrorService {}

void main() {
  test('captures one sanitized event across all retries', () {
    final errorService = MockErrorService();
    final request = RequestOptions(
      method: 'GET',
      path:
          'https://api.example.test/address/1BoatSLRHtKNngkdXEeobR76b53LETtpyT/txs',
    );
    final error = DioException.connectionTimeout(
      timeout: const Duration(seconds: 3),
      requestOptions: request,
    );

    reportDioErrorOnce(
      error: error,
      retryCount: 0,
      appVersion: '2.3.1',
      errorService: errorService,
    );
    reportDioErrorOnce(
      error: error,
      retryCount: 1,
      appVersion: '2.3.1',
      errorService: errorService,
    );

    final captured = verify(
      () => errorService.captureException(
        captureAny(),
        stackTrace: any(named: 'stackTrace'),
        message: captureAny(named: 'message'),
        context: captureAny(named: 'context'),
      ),
    ).captured;
    expect(captured[0], isA<NetworkRequestException>());
    expect(captured[1], isNot(contains('1BoatSLRHtKNngkdXEeobR76b53LETtpyT')));
    expect(captured[1], contains(redactedWalletAddress));
    expect(
      (captured[2] as Map)['url'],
      isNot(contains('1BoatSLRHtKNngkdXEeobR76b53LETtpyT')),
    );
  });
}
