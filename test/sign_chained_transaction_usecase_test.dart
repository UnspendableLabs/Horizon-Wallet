import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/usecase/sign_chained_transaction_usecase.dart';
import 'package:mocktail/mocktail.dart';

// Create mock classes for dependencies
class MockTransactionService extends Mock implements TransactionService {}

class FakeDecodedTx extends Mock implements DecodedTx {
  @override
  final version = 1;
  @override
  final txid;
  @override
  final hash = 'prevTxHash';
  @override
  final size = 1;
  @override
  final vsize = 1;
  @override
  final weight = 1;
  @override
  final locktime = 0;
  @override
  final List<Vin> vin = [];
  @override
  final List<Vout> vout;

  FakeDecodedTx({required this.vout, required this.txid});
}

class FakeVout extends Mock implements Vout {
  @override
  final int n;
  @override
  final double value;
  @override
  final ScriptPubKey scriptPubKey;

  FakeVout({
    required this.n,
    required this.value,
    required this.scriptPubKey,
  });
}

class FakeScriptPubKey extends Mock implements ScriptPubKey {
  @override
  final String? address;
  @override
  final String asm;
  @override
  final String desc;
  @override
  final String hex;
  @override
  final String type;

  FakeScriptPubKey({
    this.address,
    this.asm = 'asm',
    this.desc = 'desc',
    this.hex = 'hex',
    this.type = 'type',
  });
}

void main() {
  group('SignChainedTransactionUseCase', () {
    late SignChainedTransactionUseCase signChainedTransactionUseCase;
    late MockTransactionService mockTransactionService;

    setUpAll(() {
      // Register fallback values
      registerFallbackValue(
          Utxo(txid: '', vout: 0, height: 0, value: 0, address: ''));
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

      final scriptPubKey = FakeScriptPubKey(address: source);
      final vout = FakeVout(n: 0, value: 0.001, scriptPubKey: scriptPubKey);
      final prevDecodedTransaction =
          FakeDecodedTx(vout: [vout], txid: 'prevTxId');

      // Capture the actual map being passed
      Map<String, Utxo>? capturedMap;

      when(() => mockTransactionService.signTransaction(
            rawtransaction,
            addressPrivKey,
            source,
            any(),
          )).thenAnswer((invocation) {
        capturedMap = invocation.positionalArguments[3] as Map<String, Utxo>;
        return Future.value(signedTransaction);
      });

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
            capturedMap!,
          )).called(1);

      expect(capturedMap!.length, 1);
      final mapKey = "${prevDecodedTransaction.txid}:${vout.n}";
      expect(capturedMap!.containsKey(mapKey), true);

      final capturedUtxo = capturedMap![mapKey]!;
      expect(capturedUtxo.txid, prevDecodedTransaction.txid);
      expect(capturedUtxo.vout, vout.n);
      expect(capturedUtxo.height, null);
      expect(capturedUtxo.value, (vout.value * 100000000).toInt());
      expect(capturedUtxo.address, source);
    });

    test('should throw exception when source address not found in vout',
        () async {
      // Arrange
      const password = 'testPassword';
      const source = 'testSourceAddress';
      const rawtransaction = 'rawTransactionData';
      const addressPrivKey = 'addressPrivateKey';

      final scriptPubKey = FakeScriptPubKey(address: 'otherAddress');
      final vout = FakeVout(n: 0, value: 0.001, scriptPubKey: scriptPubKey);
      final prevDecodedTransaction =
          FakeDecodedTx(vout: [vout], txid: 'prevTxId');

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

      final scriptPubKey = FakeScriptPubKey(address: source);
      final vout = FakeVout(n: 0, value: 0.001, scriptPubKey: scriptPubKey);
      final prevDecodedTransaction =
          FakeDecodedTx(vout: [vout], txid: 'prevTxId');

      // Capture the actual map being passed
      Map<String, Utxo>? capturedMap;

      when(() => mockTransactionService.signTransaction(
            rawtransaction,
            addressPrivKey,
            source,
            any(),
          )).thenAnswer((invocation) {
        capturedMap = invocation.positionalArguments[3] as Map<String, Utxo>;
        throw Exception('Signing error');
      });

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
      verify(() => mockTransactionService.signTransaction(
            rawtransaction,
            addressPrivKey,
            source,
            capturedMap!,
          )).called(1);
      expect(capturedMap!.length, 1);
      final mapKey = "${prevDecodedTransaction.txid}:${vout.n}";
      expect(capturedMap!.containsKey(mapKey), true);

      final capturedUtxo = capturedMap![mapKey]!;
      expect(capturedUtxo.txid, prevDecodedTransaction.txid);
      expect(capturedUtxo.vout, vout.n);
      expect(capturedUtxo.height, null);
      expect(capturedUtxo.value, (vout.value * 100000000).toInt());
      expect(capturedUtxo.address, source);
    });

    test('should handle multiple vouts and find correct source', () async {
      // Arrange
      const password = 'testPassword';
      const source = 'correctSourceAddress';
      const rawtransaction = 'rawTransactionData';
      const addressPrivKey = 'addressPrivateKey';
      const signedTransaction = 'signedTransactionData';

      final scriptPubKey1 = FakeScriptPubKey(address: 'otherAddress1');
      final vout1 = FakeVout(n: 0, value: 0.001, scriptPubKey: scriptPubKey1);
      final scriptPubKey2 = FakeScriptPubKey(address: source);
      final vout2 = FakeVout(n: 1, value: 0.002, scriptPubKey: scriptPubKey2);
      final scriptPubKey3 = FakeScriptPubKey(address: 'otherAddress2');
      final vout3 = FakeVout(n: 2, value: 0.003, scriptPubKey: scriptPubKey3);
      final prevDecodedTransaction =
          FakeDecodedTx(vout: [vout1, vout2, vout3], txid: 'prevTxId');

      // Capture the actual map being passed
      Map<String, Utxo>? capturedMap;

      when(() => mockTransactionService.signTransaction(
            rawtransaction,
            addressPrivKey,
            source,
            any(),
          )).thenAnswer((invocation) {
        capturedMap = invocation.positionalArguments[3] as Map<String, Utxo>;
        return Future.value(signedTransaction);
      });

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
            capturedMap!,
          )).called(1);
      expect(capturedMap!.length, 1);
      final mapKey = "${prevDecodedTransaction.txid}:${vout2.n}";
      expect(capturedMap!.containsKey(mapKey), true);

      final capturedUtxo = capturedMap![mapKey]!;
      expect(capturedUtxo.txid, prevDecodedTransaction.txid);
      expect(capturedUtxo.vout, vout2.n);
      expect(capturedUtxo.height, null);
      expect(capturedUtxo.value, (vout2.value * 100000000).toInt());
      expect(capturedUtxo.address, source);
    });

    test('should handle empty vout list gracefully', () async {
      // Arrange
      const password = 'testPassword';
      const source = 'sourceAddress';
      const rawtransaction = 'rawTransactionData';
      const addressPrivKey = 'addressPrivateKey';

      final prevDecodedTransaction = FakeDecodedTx(vout: [], txid: 'prevTxId');

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
