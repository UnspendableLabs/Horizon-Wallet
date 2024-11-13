import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/presentation/common/usecase/sign_transaction_usecase.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';
import 'package:horizon/domain/entities/utxo.dart';

// Create mock classes for dependencies
class MockTransactionService extends Mock implements TransactionService {}

// Register fallback values for custom types
class FakeUtxo extends Fake implements Utxo {}

class FakeDecodedTx extends Fake implements DecodedTx {}

void main() {
  group('SignChainedTransactionUseCase', () {
    late SignChainedTransactionUseCase signChainedTransactionUseCase;
    late MockTransactionService mockTransactionService;

    setUpAll(() {
      // Register fallback values
      registerFallbackValue(FakeUtxo());
      registerFallbackValue(<String, Utxo>{});
    });

    setUp(() {
      mockTransactionService = MockTransactionService();
      signChainedTransactionUseCase = SignChainedTransactionUseCase(
        transactionService: mockTransactionService,
      );
    });

    test('should sign transaction successfully', () async {
      // Arrange
      const password = 'testPassword';
      const source = 'testSourceAddress';
      const rawtransaction = 'rawTransactionData';
      const addressPrivKey = 'addressPrivateKey';
      const signedTransaction = 'signedTransactionData';

      const prevDecodedTransaction = DecodedTx(
        version: 1,
        txid: 'prevTxId',
        hash: 'prevTxHash',
        size: 1,
        vsize: 1,
        weight: 1,
        locktime: 0,
        vin: [],
        vout: [
          Vout(
            n: 0,
            value: 0.001,
            scriptPubKey: ScriptPubKey(
              address: source,
              asm: 'asm',
              desc: 'desc',
              hex: 'hex',
              type: 'type',
            ),
          ),
        ],
      );

      final vout = prevDecodedTransaction.vout.first;

      final expectedUtxo = Utxo(
          txid: prevDecodedTransaction.txid,
          vout: vout.n,
          height: null,
          value: (vout.value * 100000000).toInt(),
          address: vout.scriptPubKey.address!);

      final utxoMap = {expectedUtxo.txid: expectedUtxo};

      when(() => mockTransactionService.signTransaction(
            rawtransaction,
            addressPrivKey,
            source,
            any(),
          )).thenAnswer((_) async => signedTransaction);

      // Act
      final result = await signChainedTransactionUseCase.call(
        password: password,
        source: source,
        rawtransaction: rawtransaction,
        prevDecodedTransaction: prevDecodedTransaction,
        addressPrivKey: addressPrivKey,
      );

      // Assert
      expect(result, signedTransaction);
      verify(() => mockTransactionService.signTransaction(
            rawtransaction,
            addressPrivKey,
            source,
            any(),
          )).called(1);
    });

    test('should throw exception when source address not found in vout',
        () async {
      // Arrange
      const password = 'testPassword';
      const source = 'testSourceAddress';
      const rawtransaction = 'rawTransactionData';
      const addressPrivKey = 'addressPrivateKey';

      const prevDecodedTransaction = DecodedTx(
        version: 1,
        txid: 'prevTxId',
        hash: 'prevTxHash',
        size: 1,
        vsize: 1,
        weight: 1,
        locktime: 0,
        vin: [],
        vout: [
          Vout(
            n: 0,
            value: 0.001,
            scriptPubKey: ScriptPubKey(
              address: 'otherAddress',
              asm: 'asm',
              desc: 'desc',
              hex: 'hex',
              type: 'type',
            ),
          ),
        ],
      );

      // Act & Assert
      expect(
        () async => await signChainedTransactionUseCase.call(
          password: password,
          source: source,
          rawtransaction: rawtransaction,
          prevDecodedTransaction: prevDecodedTransaction,
          addressPrivKey: addressPrivKey,
        ),
        throwsA(isA<SignTransactionException>()),
      );
    });

    test(
        'should throw exception when transactionService.signTransaction throws',
        () async {
      // Arrange
      const password = 'testPassword';
      const source = 'testSourceAddress';
      const rawtransaction = 'rawTransactionData';
      const addressPrivKey = 'addressPrivateKey';

      const prevDecodedTransaction = DecodedTx(
        version: 1,
        txid: 'prevTxId',
        hash: 'prevTxHash',
        size: 1,
        vsize: 1,
        weight: 1,
        locktime: 0,
        vin: [],
        vout: [
          Vout(
            n: 0,
            value: 0.001,
            scriptPubKey: ScriptPubKey(
              address: source,
              asm: 'asm',
              desc: 'desc',
              hex: 'hex',
              type: 'type',
            ),
          ),
        ],
      );

      final expectedVout = prevDecodedTransaction.vout.first;

      final expectedUtxo = Utxo(
        txid: prevDecodedTransaction.txid,
        vout: expectedVout.n,
        height: null,
        value: (expectedVout.value * 100000000).toInt(),
        address: expectedVout.scriptPubKey.address!,
      );

      final utxoMap = {expectedUtxo.txid: expectedUtxo};

      when(() => mockTransactionService.signTransaction(
            rawtransaction,
            addressPrivKey,
            source,
            utxoMap,
          )).thenThrow(Exception('Signing error'));

      // Act & Assert
      expect(
        () async => await signChainedTransactionUseCase.call(
          password: password,
          source: source,
          rawtransaction: rawtransaction,
          prevDecodedTransaction: prevDecodedTransaction,
          addressPrivKey: addressPrivKey,
        ),
        throwsA(isA<SignTransactionException>()),
      );
    });

    test('should handle multiple vouts and find correct source', () async {
      // Arrange
      const password = 'testPassword';
      const source = 'correctSourceAddress';
      const rawtransaction = 'rawTransactionData';
      const addressPrivKey = 'addressPrivateKey';
      const signedTransaction = 'signedTransactionData';

      const prevDecodedTransaction = DecodedTx(
        version: 1,
        txid: 'prevTxId',
        hash: 'prevTxHash',
        size: 1,
        vsize: 1,
        weight: 1,
        locktime: 0,
        vin: [],
        vout: [
          Vout(
            n: 0,
            value: 0.001,
            scriptPubKey: ScriptPubKey(
              address: 'otherAddress1',
              asm: 'asm',
              desc: 'desc',
              hex: 'hex',
              type: 'type',
            ),
          ),
          Vout(
            n: 1,
            value: 0.002,
            scriptPubKey: ScriptPubKey(
              address: source,
              asm: 'asm',
              desc: 'desc',
              hex: 'hex',
              type: 'type',
            ),
          ),
          Vout(
            n: 2,
            value: 0.003,
            scriptPubKey: ScriptPubKey(
              address: 'otherAddress2',
              asm: 'asm',
              desc: 'desc',
              hex: 'hex',
              type: 'type',
            ),
          ),
        ],
      );

      final expectedVout = prevDecodedTransaction.vout[1];

      final expectedUtxo = Utxo(
        txid: prevDecodedTransaction.txid,
        vout: expectedVout.n,
        height: null,
        value: (expectedVout.value * 100000000).toInt(),
        address: expectedVout.scriptPubKey.address!,
      );

      final utxoMap = {expectedUtxo.txid: expectedUtxo};

      when(() => mockTransactionService.signTransaction(
            rawtransaction,
            addressPrivKey,
            source,
            any(),
          )).thenAnswer((_) async => signedTransaction);

      // Act
      final result = await signChainedTransactionUseCase.call(
        password: password,
        source: source,
        rawtransaction: rawtransaction,
        prevDecodedTransaction: prevDecodedTransaction,
        addressPrivKey: addressPrivKey,
      );

      // Assert
      expect(result, signedTransaction);
      verify(() => mockTransactionService.signTransaction(
            rawtransaction,
            addressPrivKey,
            source,
            any(),
          )).called(1);
    });

    test('should handle empty vout list gracefully', () async {
      // Arrange
      const password = 'testPassword';
      const source = 'sourceAddress';
      const rawtransaction = 'rawTransactionData';
      const addressPrivKey = 'addressPrivateKey';

      const prevDecodedTransaction = DecodedTx(
        version: 1,
        txid: 'prevTxId',
        hash: 'prevTxHash',
        size: 1,
        vsize: 1,
        weight: 1,
        locktime: 0,
        vin: [],
        vout: [],
      );

      // Act & Assert
      expect(
        () async => await signChainedTransactionUseCase.call(
          password: password,
          source: source,
          rawtransaction: rawtransaction,
          prevDecodedTransaction: prevDecodedTransaction,
          addressPrivKey: addressPrivKey,
        ),
        throwsA(isA<SignTransactionException>()),
      );
    });
  });
}
