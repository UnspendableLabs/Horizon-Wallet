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
    test('replays every read under its real base, never compose or a write',
        () {
      // Paths as the clients request them, resolved against the configured
      // bases: Counterparty under /v2 (testnet4 adds a trailing slash), Esplora
      // at the root, mempool.space as a full URL.
      const counterparty = 'https://testnet4.counterparty.io:44000/v2/';
      const esplora = 'https://api.unspendablelabs.com:3000';
      RequestOptions get(String base, String path) =>
          RequestOptions(baseUrl: base, path: path);

      for (final request in [
        get(counterparty, '/addresses/public/balances?verbose=true'),
        get(counterparty, '/addresses/events?limit=1000'),
        get(counterparty, '/addresses/public/dispensers'),
        get(counterparty, '/addresses/public/orders?verbose=true'),
        get(counterparty, '/addresses/public/transactions'),
        get(counterparty, '/transactions/info?verbose=true'),
        get(counterparty, '/transactions/unpack?verbose=true'),
        get(counterparty, '/bitcoin/transactions/decode'),
        get(counterparty, '/blocks/last'),
        get(counterparty, '/'),
        get(counterparty, '/addresses/public/compose/dividend/estimatexcpfees'),
        get(esplora, '/address/public'),
        get(esplora, '/address/public/txs/chain/last'),
        get(esplora, '/blocks/tip/height'),
        get(esplora, 'https://mempool.space/api/v1/fees/recommended'),
      ]) {
        expect(isRetryableNetworkRead(request), isTrue,
            reason: request.uri.toString());
      }

      for (final request in [
        get(counterparty, '/addresses/public/compose/send?verbose=true'),
        get(counterparty, '/addresses/public/compose/attach?verbose=true'),
        get(counterparty, '/utxos/outpoint/compose/detach?verbose=true'),
        RequestOptions(
          baseUrl: counterparty,
          path: '/bitcoin/transactions',
          method: 'POST',
        ),
      ]) {
        expect(isRetryableNetworkRead(request), isFalse,
            reason: request.uri.toString());
      }
    });

    test('retries transient transport failures', () {
      final request = RequestOptions(path: '/blocks/tip/height');
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

    for (final status in [429, 502, 503, 504]) {
      test('recovers a read after HTTP $status', () async {
        final adapter = FailingAdapter(1, statusCode: status);
        dio.httpClientAdapter = adapter;
        expect((await dio.get<String>('/v2/addresses/events')).data, 'ok');
        expect(adapter.requests, hasLength(2));
        verifyNothingReported();
      });
    }

    test('exhausted 503 reads report once within the retry limit', () async {
      final adapter = FailingAdapter(alwaysFails, statusCode: 503);
      dio.httpClientAdapter = adapter;
      await expectLater(
          dio.get('/address/public/utxo'), throwsA(isA<DioException>()));
      expect(adapter.requests, hasLength(3));
      expect(reportedContexts(), hasLength(1));
    });

    for (final status in [400, 401, 403, 404, 500]) {
      test('does not retry permanent/unclassified HTTP $status', () async {
        final adapter = FailingAdapter(alwaysFails, statusCode: status);
        dio.httpClientAdapter = adapter;
        await expectLater(
            dio.get('/addresses/events'), throwsA(isA<DioException>()));
        expect(adapter.requests, hasLength(1));
      });
    }

    test('never replays compose or a POST', () async {
      var adapter = FailingAdapter(alwaysFails);
      dio.httpClientAdapter = adapter;
      await expectLater(dio.get('/v2/addresses/public/compose/send'),
          throwsA(isA<DioException>()));
      expect(adapter.requests, hasLength(1));

      adapter = FailingAdapter(alwaysFails);
      dio.httpClientAdapter = adapter;
      await expectLater(
          dio.post('/v2/bitcoin/transactions'), throwsA(isA<DioException>()));
      expect(adapter.requests, hasLength(1));
    });

    test('explicit retry opt-out also applies to eligible 503 reads', () async {
      final adapter = FailingAdapter(alwaysFails, statusCode: 503);
      dio.httpClientAdapter = adapter;
      await expectLater(
          dio.get('/addresses/events', options: Options()..disableRetry = true),
          throwsA(isA<DioException>()));
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

      final pending = dio.get('/addresses/events', cancelToken: token);
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

    test('does not alert on a 404, the expected answer for an unknown asset',
        () async {
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

    test(
        'still alerts when a request that opted out of retries cannot reach '
        'the server', () async {
      final adapter = FailingAdapter(alwaysFails);
      dio.httpClientAdapter = adapter;

      await expectLater(
        dio.get('/assets/XCP', options: Options()..disableRetry = true),
        throwsA(isA<DioException>()),
      );

      expect(adapter.requests, hasLength(1));
      final contexts = reportedContexts();
      expect(contexts, hasLength(1));
      expect(contexts.single['errorType'], 'connectionError');
      expect(contexts.single['retryCount'], 0);
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
