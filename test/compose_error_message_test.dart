import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/network_error.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';

class MockUtxos extends Mock implements UtxoRepository {}

class MockBalances extends Mock implements BalanceRepository {}

class MockErrors extends Mock implements ErrorService {}

void main() {
  test('composition errors stringify their message, not their runtime type',
      () {
    final error = ComposeTransactionException(
        'No UTXOs available for transaction',
        StackTrace.fromString('internal stack'));
    expect(error.toString(), 'No UTXOs available for transaction');
    expect(error.toString(), isNot(contains('internal stack')));
    expect(NetworkError.fromError(error).message,
        'An unexpected error occurred: No UTXOs available for transaction');
  });

  test('callT preserves the reason for a failed send composition', () async {
    final utxos = MockUtxos();
    final config = HttpConfig.mainnet();
    when(() =>
            utxos.getUnspentForAddress('source', config, excludeCached: true))
        .thenAnswer((_) async => (<Utxo>[], <UtxoID>[]));
    final useCase = ComposeTransactionUseCase(
        utxoRepository: utxos,
        balanceRepository: MockBalances(),
        errorService: MockErrors());
    var composed = false;
    final result = await useCase
        .callT<ComposeSendParams, ComposeSendResponse>(
          feeRate: 1,
          source: 'source',
          params: ComposeSendParams(
              source: 'source',
              destination: 'destination',
              asset: 'BTC',
              quantity: 1),
          composeFn: (fee, inputs, params, config) async {
            composed = true;
            throw StateError('Should not compose without inputs');
          },
          httpConfig: config,
        )
        .run();
    expect(result.isLeft(), isTrue);
    result.fold((message) {
      expect(message, contains('No UTXOs available for transaction'));
      expect(message, isNot(contains('Instance of')));
      expect(message, isNot(contains('minified')));
    }, (_) => fail('Expected a composition failure'));
    expect(composed, isFalse);
  });
}
