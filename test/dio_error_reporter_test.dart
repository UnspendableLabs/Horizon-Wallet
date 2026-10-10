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
      appVersion: '1.7.11',
      errorService: errorService,
    );
    reportDioErrorOnce(
      error: error,
      retryCount: 1,
      appVersion: '1.7.11',
      errorService: errorService,
    );

    final verification = verify(
      () => errorService.captureException(
        captureAny(),
        stackTrace: any(named: 'stackTrace'),
        message: captureAny(named: 'message'),
        context: captureAny(named: 'context'),
      ),
    );
    // The retry must not produce a second event.
    verification.called(1);

    final captured = verification.captured;
    expect(captured[0], isA<NetworkRequestException>());
    expect(captured[1], isNot(contains('1BoatSLRHtKNngkdXEeobR76b53LETtpyT')));
    expect(captured[1], contains(redactedWalletAddress));
    expect(
      (captured[2] as Map)['url'],
      isNot(contains('1BoatSLRHtKNngkdXEeobR76b53LETtpyT')),
    );
  });

  test('reports query parameter names without their values', () {
    final errorService = MockErrorService();
    final request = RequestOptions(
      method: 'POST',
      baseUrl: 'https://api.example.test:4000/v2',
      path: '/bitcoin/transactions',
      queryParameters: {
        'signedhex': '0200000001aabbccdd',
        'inputs_set': 'aabb:0,ccdd:1',
        'verbose': true,
      },
    );
    final error = DioException.badResponse(
      statusCode: 500,
      requestOptions: request,
      response: Response(requestOptions: request, statusCode: 500),
    );

    reportDioErrorOnce(
      error: error,
      retryCount: 0,
      appVersion: '1.7.11',
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
    const endpoint = 'https://api.example.test:4000/v2/bitcoin/transactions'
        '?signedhex&inputs_set&verbose';
    expect(
      captured[1],
      'NetworkRequestException: badResponse: POST $endpoint (500)',
    );
    expect((captured[2] as Map)['url'], endpoint);
  });
}
