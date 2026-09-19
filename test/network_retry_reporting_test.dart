import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/core/logging/dio_error_reporter.dart';
import 'package:horizon/domain/services/error_service.dart';

class Recorder implements ErrorService {
  final List<Map<String, dynamic>> reports = [];
  @override
  Future<void> initialize() async {}
  @override
  void addBreadcrumb(
      {required String type,
      required String category,
      required String message,
      Map<String, dynamic>? data}) {}
  @override
  void captureException(dynamic exception,
      {StackTrace? stackTrace,
      String? message,
      Map<String, dynamic>? context}) {
    reports.add(context ?? {});
  }
}

class FailingAdapter implements HttpClientAdapter {
  final int failures;
  final DioExceptionType type;
  final List<RequestOptions> requests = [];
  FailingAdapter(this.failures, {this.type = DioExceptionType.connectionError});
  @override
  void close({bool force = false}) {}
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
      Future<void>? cancelFuture) async {
    requests.add(options);
    if (requests.length <= failures) {
      throw DioException(requestOptions: options, type: type);
    }
    return ResponseBody.fromString('ok', 200);
  }
}

void main() {
  late Dio dio;
  late Recorder recorder;
  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://esplora.example.test'));
    recorder = Recorder();
    dio.interceptors.addAll(networkRetryInterceptors(
        dio: dio,
        retries: 2,
        retryDelays: const [Duration.zero],
        appVersion: 'test',
        errorService: () => recorder));
  });
  tearDown(() => dio.close(force: true));

  test('does not alert when a retry recovers', () async {
    final adapter = FailingAdapter(1);
    dio.httpClientAdapter = adapter;
    expect((await dio.get<String>('/blocks/tip/height')).data, 'ok');
    expect(adapter.requests, hasLength(2));
    expect(recorder.reports, isEmpty);
  });
  test('reports only once after all retries fail', () async {
    final adapter = FailingAdapter(100);
    dio.httpClientAdapter = adapter;
    await expectLater(
        dio.get('/blocks/tip/height'), throwsA(isA<DioException>()));
    expect(adapter.requests, hasLength(3));
    expect(recorder.reports, hasLength(1));
    expect(recorder.reports.single['retryCount'], 2);
    expect(recorder.reports.single['failureStage'], 'final');
  });
  test('reports a non-retryable failure without retrying', () async {
    final adapter = FailingAdapter(100, type: DioExceptionType.badCertificate);
    dio.httpClientAdapter = adapter;
    await expectLater(dio.get('/'), throwsA(isA<DioException>()));
    expect(adapter.requests, hasLength(1));
    expect(recorder.reports, hasLength(1));
    expect(recorder.reports.single['retryCount'], 0);
  });
  test('does not alert on cancellation', () async {
    dio.httpClientAdapter = FailingAdapter(100, type: DioExceptionType.cancel);
    await expectLater(dio.get('/'), throwsA(isA<DioException>()));
    expect(recorder.reports, isEmpty);
  });
  test('retries stay on the supplied client and retain its interceptors',
      () async {
    final adapter = FailingAdapter(1);
    dio.httpClientAdapter = adapter;
    var ownInterceptorCalls = 0;
    dio.interceptors.insert(0,
        InterceptorsWrapper(onRequest: (options, handler) {
      ownInterceptorCalls++;
      handler.next(options);
    }));
    await dio.get('/blocks/tip/height');
    expect(ownInterceptorCalls, 2);
    expect(adapter.requests.every((r) => r.uri.host == 'esplora.example.test'),
        isTrue);
    expect(
        adapter.requests.every((r) => !r.headers.containsKey('Authorization')),
        isTrue);
  });
}
