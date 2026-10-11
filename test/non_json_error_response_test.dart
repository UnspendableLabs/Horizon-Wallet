import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/data/sources/network/horizon_explorer_client.dart';
import 'package:horizon/domain/entities/compose_fn.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockUtxoRepository extends Mock implements UtxoRepository {}

class _MockBalanceRepository extends Mock implements BalanceRepository {}

class _MockErrorService extends Mock implements ErrorService {}

class _MockComposeParams extends Mock implements ComposeParams {}

/// Answers every request with the same canned response.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.statusCode, this.body, this.contentType);

  final int statusCode;
  final String body;
  final String contentType;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromString(body, statusCode, headers: {
        Headers.contentTypeHeader: [contentType],
      });

  @override
  void close({bool force = false}) {}
}

const _proxyOutage = '<html><body>502 Bad Gateway</body></html>';

Matcher _throwsBadGateway() => throwsA(isA<DioException>()
    .having((e) => e.response?.statusCode, 'statusCode', 502));

Matcher _throwsApiError(String message) => throwsA(isA<Exception>()
    .having((e) => e.toString(), 'message', 'Exception: $message'));

DioException _badResponse(dynamic data) {
  final request = RequestOptions(path: '/compose');
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: request, statusCode: 502, data: data),
  );
}

HorizonExplorerApi _explorer(int statusCode, String body, String contentType) {
  final dio = Dio(BaseOptions(baseUrl: 'https://horizon.test/api'))
    ..httpClientAdapter = _StubAdapter(statusCode, body, contentType);
  return HorizonExplorerApi(dio);
}

Future<Object> _createAtomicSwap(HorizonExplorerApi api) =>
    api.createAtomicSwap(
      psbtHex: '70736274ff',
      sellerAddress: 'bc1qseller',
      assetUtxoId: 'aa:0',
      assetUtxoValue: 546,
      assetName: 'ASSET',
      assetQuantity: 1,
      price: 1000,
      expiresAt: null,
      feePaymentId: 'fee',
      feePaymentPsbtHex: '70736274ff',
      divisible: true,
    );

Future<Object> _atomicSwapMultiBuy(HorizonExplorerApi api) =>
    api.atomicSwapMultiBuy(
        ids: const ['swap'], buyerAddress: 'bc1qbuyer', psbtHex: '70736274ff');

void main() {
  group('ComposeTransactionUseCase', () {
    late _MockUtxoRepository utxoRepository;
    late ComposeTransactionUseCase useCase;
    final httpConfig = HttpConfig.mainnet();
    final params = _MockComposeParams();

    setUp(() {
      utxoRepository = _MockUtxoRepository();
      useCase = ComposeTransactionUseCase(
        utxoRepository: utxoRepository,
        balanceRepository: _MockBalanceRepository(),
        errorService: _MockErrorService(),
      );
      when(() => utxoRepository
              .getUnspentForAddress('source', httpConfig, excludeCached: true))
          .thenAnswer((_) async => (
                [
                  Utxo(
                      vout: 0,
                      value: 10000,
                      txid: 'aa',
                      address: 'source',
                      confirmed: true)
                ],
                <UtxoID>[]
              ));
    });

    Future<ComposeResponse> compose(DioException error) =>
        useCase.call<ComposeParams, ComposeResponse>(
          feeRate: 1,
          source: 'source',
          params: params,
          composeFn: (_, __, ___, ____) => throw error,
          httpConfig: httpConfig,
        );

    test('rethrows the network failure when the body is not JSON', () {
      expect(compose(_badResponse(_proxyOutage)), _throwsBadGateway());
    });

    test('surfaces the API error message from a JSON body', () {
      expect(compose(_badResponse({'error': 'Insufficient funds'})),
          _throwsApiError('Insufficient funds'));
    });
  });

  group('HorizonExplorerApi', () {
    test('createAtomicSwap rethrows a proxy outage page', () {
      expect(_createAtomicSwap(_explorer(502, _proxyOutage, 'text/html')),
          _throwsBadGateway());
    });

    test('createAtomicSwap surfaces the API error message', () {
      expect(
          _createAtomicSwap(_explorer(
              400, '{"error":"Swap already listed"}', 'application/json')),
          _throwsApiError('Swap already listed'));
    });

    test('atomicSwapMultiBuy rethrows a proxy outage page', () {
      expect(_atomicSwapMultiBuy(_explorer(502, _proxyOutage, 'text/html')),
          _throwsBadGateway());
    });

    test('atomicSwapMultiBuy surfaces the API error message', () {
      expect(
          _atomicSwapMultiBuy(_explorer(
              400, '{"error":"Swap already sold"}', 'application/json')),
          _throwsApiError('Swap already sold'));
    });
  });
}
