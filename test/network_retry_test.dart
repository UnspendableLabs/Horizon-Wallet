import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/core/logging/dio_error_reporter.dart';
import 'package:horizon/data/sources/network/network_retry.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:mocktail/mocktail.dart';

class MockErrorService extends Mock implements ErrorService {}

/// Fails the first [failures] requests with [type], then answers 200 "ok".
class FailingAdapter implements HttpClientAdapter {
  final int failures;
  final DioExceptionType type;
  final int? statusCode;
  final List<RequestOptions> requests = [];

  FailingAdapter(
    this.failures, {
    this.type = DioExceptionType.connectionError,
    this.statusCode,
  });

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (requests.length > failures) {
      return ResponseBody.fromString('ok', 200);
    }
    if (statusCode != null) {
      return ResponseBody.fromString('error', statusCode!);
    }
    throw DioException(requestOptions: options, type: type);
  }
}

void main() {
  const alwaysFails = 1 << 30;
  late Dio dio;
  late MockErrorService errorService;

  List<Map<String, dynamic>> reportedContexts() => verify(
        () => errorService.captureException(
          any(),
          stackTrace: any(named: 'stackTrace'),
          message: any(named: 'message'),
          context: captureAny(named: 'context'),
        ),
      ).captured.cast<Map<String, dynamic>>();

  void verifyNothingReported() => verifyNever(
        () => errorService.captureException(
          any(),
          stackTrace: any(named: 'stackTrace'),
          message: any(named: 'message'),
          context: any(named: 'context'),
        ),
      );

  Dio buildDio({List<Duration> retryDelays = const [Duration.zero]}) {
    final client = Dio(BaseOptions(baseUrl: 'https://esplora.example.test'));
    client.interceptors.addAll(networkRetryInterceptors(
      dio: client,
      retries: 2,
      retryDelays: retryDelays,
      appVersion: 'test',
      errorService: () => errorService,
    ));
    return client;
  }

  setUpAll(() {
    registerFallbackValue(StackTrace.empty);
  });

  setUp(() {
    errorService = MockErrorService();
    dio = buildDio();
  });

  tearDown(() => dio.close(force: true));

  group('retry policy', () {
    test('retries transient transport failures', () {
      final request = RequestOptions(path: '/');
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      ]) {
        expect(
          isTransientNetworkFailure(
              DioException(requestOptions: request, type: type)),
          isTrue,
          reason: type.name,
        );
      }
    });

    test('does not retry HTTP responses, including 400', () async {
      final adapter = FailingAdapter(
        alwaysFails,
        type: DioExceptionType.badResponse,
        statusCode: 400,
      );
      dio.httpClientAdapter = adapter;

      await expectLater(dio.get('/'), throwsA(isA<DioException>()));

      expect(adapter.requests, hasLength(1));
    });
  });

  group('reporting', () {
    test('does not alert when a retry recovers', () async {
      final adapter = FailingAdapter(1);
      dio.httpClientAdapter = adapter;

      final response = await dio.get<String>('/blocks/tip/height');

      expect(response.data, 'ok');
      expect(adapter.requests, hasLength(2));
      verifyNothingReported();
    });

    test('reports once after all retries fail', () async {
      final adapter = FailingAdapter(alwaysFails);
      dio.httpClientAdapter = adapter;

      await expectLater(
          dio.get('/blocks/tip/height'), throwsA(isA<DioException>()));

      expect(adapter.requests, hasLength(3));
      final contexts = reportedContexts();
      expect(contexts, hasLength(1));
      expect(contexts.single['retryCount'], 2);
      expect(contexts.single['errorType'], 'connectionError');
    });

    test('reports a non-retryable failure without retrying', () async {
      final adapter =
          FailingAdapter(alwaysFails, type: DioExceptionType.badCertificate);
      dio.httpClientAdapter = adapter;

      await expectLater(dio.get('/'), throwsA(isA<DioException>()));

      expect(adapter.requests, hasLength(1));
      final contexts = reportedContexts();
      expect(contexts, hasLength(1));
      expect(contexts.single['retryCount'], 0);
    });

    test('captures a NetworkRequestException', () async {
      dio.httpClientAdapter = FailingAdapter(alwaysFails);

      await expectLater(dio.get('/'), throwsA(isA<DioException>()));

      final captured = verify(
        () => errorService.captureException(
          captureAny(),
          stackTrace: any(named: 'stackTrace'),
          message: any(named: 'message'),
          context: any(named: 'context'),
        ),
      ).captured;
      expect(captured.single, isA<NetworkRequestException>());
    });

    test('does not alert on a cancelled request', () async {
      dio.httpClientAdapter =
          FailingAdapter(alwaysFails, type: DioExceptionType.cancel);

      await expectLater(dio.get('/'), throwsA(isA<DioException>()));

      verifyNothingReported();
    });

    test('does not alert when the request is cancelled during the back-off',
        () async {
      dio.close(force: true);
      dio = buildDio(retryDelays: const [Duration(milliseconds: 200)]);
      final adapter = FailingAdapter(alwaysFails);
      dio.httpClientAdapter = adapter;
      final token = CancelToken();

      final pending = dio.get('/', cancelToken: token);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      token.cancel();

      // Dio races every interceptor step against the token, so the pending
      // back-off is abandoned and the cancellation reaches the reporter as a
      // cancel-typed error. Waiting past the back-off proves nothing surfaces
      // later either.
      await expectLater(
        pending,
        throwsA(isA<DioException>()
            .having((e) => e.type, 'type', DioExceptionType.cancel)),
      );
      await Future<void>.delayed(const Duration(milliseconds: 400));

      expect(adapter.requests, hasLength(1));
      verifyNothingReported();
    });

    test('does not alert on requests that opted out of retries', () async {
      final adapter = FailingAdapter(
        alwaysFails,
        type: DioExceptionType.badResponse,
        statusCode: 404,
      );
      dio.httpClientAdapter = adapter;

      await expectLater(
        dio.get('/assets/NOPE', options: Options()..disableRetry = true),
        throwsA(isA<DioException>()),
      );

      expect(adapter.requests, hasLength(1));
      verifyNothingReported();
    });
  });

  group('client isolation', () {
    test('retries stay on the supplied client and retain its interceptors',
        () async {
      final adapter = FailingAdapter(1);
      dio.httpClientAdapter = adapter;
      var ownInterceptorCalls = 0;
      dio.interceptors.insert(
        0,
        InterceptorsWrapper(onRequest: (options, handler) {
          ownInterceptorCalls++;
          handler.next(options);
        }),
      );

      await dio.get('/blocks/tip/height');

      expect(ownInterceptorCalls, 2);
      expect(
        adapter.requests.every((r) => r.uri.host == 'esplora.example.test'),
        isTrue,
      );
      expect(
        adapter.requests.every((r) => !r.headers.containsKey('Authorization')),
        isTrue,
      );
    });
  });
}
