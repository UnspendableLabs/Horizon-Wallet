import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_fn.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:mocktail/mocktail.dart';

// Define mock classes
class MockUtxoRepository extends Mock implements UtxoRepository {}

class MockComposeParams extends Mock implements ComposeParams {}

class MockComposeResponse extends Mock implements ComposeResponse {
  @override
  SignedTxEstimatedSize get signedTxEstimatedSize => SignedTxEstimatedSize(
      virtualSize: 120, adjustedVirtualSize: 155, sigopsCount: 1);
}

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockComposeFunction extends Mock {
  Future<MockComposeResponse> call(
    int fee,
    List<Utxo> inputsSet,
    ComposeParams params,
  );
}

class MockUtxo extends Mock implements Utxo {}

class MockBalance extends Mock implements Balance {}

class MockCacheProvider extends Mock implements CacheProvider {}

class MockErrorService extends Mock implements ErrorService {}

void main() {
  late MockUtxoRepository mockUtxoRepository;
  late MockComposeFunction mockComposeFunction;
  late MockComposeParams mockComposeParams;
  late MockBalanceRepository mockBalanceRepository;
  late MockCacheProvider mockCacheProvider;
  late MockErrorService mockErrorService;
  setUp(() {
    mockUtxoRepository = MockUtxoRepository();
    mockComposeFunction = MockComposeFunction();
    mockComposeParams = MockComposeParams();
    mockBalanceRepository = MockBalanceRepository();
    mockCacheProvider = MockCacheProvider();
    mockErrorService = MockErrorService();
    GetIt.I.registerSingleton<CacheProvider>(mockCacheProvider);
    GetIt.I.registerSingleton<ErrorService>(mockErrorService);
    registerFallbackValue(mockComposeParams);
  });

  tearDown(() {
    GetIt.I.unregister<CacheProvider>();
    GetIt.I.unregister<ErrorService>();
  });

  group('ComposeTransactionUseCase', () {
    test('should successfully compose a transaction', () async {
      final composeTransactionUseCase = ComposeTransactionUseCase(
        utxoRepository: mockUtxoRepository,
        balanceRepository: mockBalanceRepository,
        errorService: mockErrorService,
      );

      // Arrange
      const source = 'test_source_address';
      const feeRate = 10;
      final mockUtxos = [MockUtxo(), MockUtxo()];
      const List<String> mockCachedTxHashes = [];
      when(() => mockUtxos[0].txid).thenReturn('mockTxId1');
      when(() => mockUtxos[0].vout).thenReturn(0);
      when(() => mockUtxos[1].txid).thenReturn('mockTxId2');
      when(() => mockUtxos[1].vout).thenReturn(1);

      final mockComposeResponse = MockComposeResponse();

      when(() => mockUtxoRepository.getUnspentForAddress(source,
              excludeCached: true))
          .thenAnswer((_) async => (mockUtxos, mockCachedTxHashes));

      when(() => mockComposeFunction(feeRate, mockUtxos, mockComposeParams))
          .thenAnswer((_) async => mockComposeResponse);

      // Act
      final txResponse = await composeTransactionUseCase.call(
        feeRate: feeRate,
        source: source,
        params: mockComposeParams,
        composeFn: mockComposeFunction.call,
      );

      // Assert
      expect(txResponse, mockComposeResponse);
      expect(txResponse.signedTxEstimatedSize.virtualSize, equals(120));
      expect(txResponse.signedTxEstimatedSize.adjustedVirtualSize, equals(155));
      verify(() => mockUtxoRepository.getUnspentForAddress(source,
          excludeCached: true)).called(1);
      verify(() => mockComposeFunction(feeRate, mockUtxos, mockComposeParams))
          .called(1);
    });

    test('should throw ComposeTransactionException if fetching UTXOs fails',
        () async {
      final composeTransactionUseCase = ComposeTransactionUseCase(
        utxoRepository: mockUtxoRepository,
        balanceRepository: mockBalanceRepository,
        errorService: mockErrorService,
      );

      // Arrange
      const source = 'test_source_address';
      const feeRate = 10;

      when(() => mockUtxoRepository.getUnspentForAddress(source,
          excludeCached: true)).thenThrow(Exception('Failed to fetch UTXOs'));

      // Act & Assert
      expect(
        () => composeTransactionUseCase.call(
          feeRate: feeRate,
          source: source,
          params: mockComposeParams,
          composeFn: mockComposeFunction.call,
        ),
        throwsA(isA<ComposeTransactionException>()),
      );
    });

    test(
        'should throw ComposeTransactionException if composing transaction fails',
        () async {
      final composeTransactionUseCase = ComposeTransactionUseCase(
        utxoRepository: mockUtxoRepository,
        balanceRepository: mockBalanceRepository,
        errorService: mockErrorService,
      );

      // Arrange
      const source = 'test_source_address';
      const feeRate = 10;
      final mockUtxos = [MockUtxo(), MockUtxo()];
      const List<String> mockCachedTxHashes = [];

      when(() => mockUtxoRepository.getUnspentForAddress(source,
              excludeCached: true))
          .thenAnswer((_) async => (mockUtxos, mockCachedTxHashes));

      when(() => mockComposeFunction(feeRate, mockUtxos, mockComposeParams))
          .thenThrow(Exception('Failed to compose transaction'));

      // Act & Assert
      expect(
        () => composeTransactionUseCase.call(
          params: mockComposeParams,
          feeRate: feeRate,
          source: source,
          composeFn: mockComposeFunction.call,
        ),
        throwsA(isA<ComposeTransactionException>()),
      );
    });

    test('should handle more than 20 UTXOs by invoking _getLargeInputsSet',
        () async {
      final composeTransactionUseCase = ComposeTransactionUseCase(
        utxoRepository: mockUtxoRepository,
        balanceRepository: mockBalanceRepository,
        errorService: mockErrorService,
      );

      // Arrange
      const source = 'test_source_address';
      const feeRate = 10;
      const List<String> mockCachedTxHashes = ['mock_tx_id'];
      final mockUtxos = List.generate(25, (_) => MockUtxo());

      for (var i = 0; i < mockUtxos.length; i++) {
        when(() => mockUtxos[i].txid).thenReturn('mockTxId$i');
        when(() => mockUtxos[i].vout).thenReturn(i);
        when(() => mockUtxos[i].value).thenReturn(1000 - i);
      }

      final mockComposeResponse = MockComposeResponse();

      when(() => mockUtxoRepository.getUnspentForAddress(source,
              excludeCached: true))
          .thenAnswer((_) async => (mockUtxos, mockCachedTxHashes));

      when(() => mockBalanceRepository.getBalancesForUTXO(any()))
          .thenAnswer((_) async => []);

      mockUtxos.sort((a, b) => b.value.compareTo(a.value));
      final sortedUtxos = mockUtxos.take(20).toList();

      when(() => mockComposeFunction(feeRate, sortedUtxos, mockComposeParams))
          .thenAnswer((_) async => mockComposeResponse);

      // Act
      final txResponse = await composeTransactionUseCase.call(
        feeRate: feeRate,
        source: source,
        params: mockComposeParams,
        composeFn: mockComposeFunction.call,
      );

      // Assert
      expect(txResponse, mockComposeResponse);
      expect(txResponse.signedTxEstimatedSize.virtualSize, equals(120));
      expect(txResponse.signedTxEstimatedSize.adjustedVirtualSize, equals(155));
      verify(() => mockUtxoRepository.getUnspentForAddress(source,
          excludeCached: true)).called(1);
      verify(() => mockBalanceRepository.getBalancesForUTXO(any())).called(20);

      final capturedInputs =
          verify(() => mockComposeFunction(any(), captureAny(), any()))
              .captured
              .single as List<Utxo>;
      expect(capturedInputs.length, equals(20));
      expect(capturedInputs, containsAllInOrder(sortedUtxos));
    });

    test('should exclude top 2 UTXOs with balances from the final inputs',
        () async {
      final composeTransactionUseCase = ComposeTransactionUseCase(
        utxoRepository: mockUtxoRepository,
        balanceRepository: mockBalanceRepository,
        errorService: mockErrorService,
      );

      // Arrange
      const source = 'test_source_address';
      const feeRate = 10;
      const List<String> mockCachedTxHashes = [];
      final mockUtxos = List.generate(25, (_) => MockUtxo());

      for (var i = 0; i < mockUtxos.length; i++) {
        when(() => mockUtxos[i].txid).thenReturn('mockTxId$i');
        when(() => mockUtxos[i].vout).thenReturn(i);
        when(() => mockUtxos[i].value).thenReturn(1000 - i);
      }

      final mockComposeResponse = MockComposeResponse();

      when(() => mockUtxoRepository.getUnspentForAddress(source,
              excludeCached: true))
          .thenAnswer((_) async => (mockUtxos, mockCachedTxHashes));

      when(() => mockBalanceRepository.getBalancesForUTXO('mockTxId0:0'))
          .thenAnswer((_) async => [MockBalance()]);
      when(() => mockBalanceRepository.getBalancesForUTXO('mockTxId1:1'))
          .thenAnswer((_) async => [MockBalance()]);

      for (var i = 2; i < mockUtxos.length; i++) {
        when(() => mockBalanceRepository.getBalancesForUTXO('mockTxId$i:$i'))
            .thenAnswer((_) async => []);
      }

      mockUtxos.sort((a, b) => b.value.compareTo(a.value));
      final sortedUtxos = mockUtxos.skip(2).take(20).toList();

      when(() => mockComposeFunction(feeRate, sortedUtxos, mockComposeParams))
          .thenAnswer((_) async => mockComposeResponse);

      // Act
      final txResponse = await composeTransactionUseCase.call(
        feeRate: feeRate,
        source: source,
        params: mockComposeParams,
        composeFn: mockComposeFunction.call,
      );

      // Assert
      expect(txResponse, mockComposeResponse);
      expect(txResponse.signedTxEstimatedSize.virtualSize, equals(120));
      expect(txResponse.signedTxEstimatedSize.adjustedVirtualSize, equals(155));
      verify(() => mockUtxoRepository.getUnspentForAddress(source,
          excludeCached: true)).called(1);
      verify(() => mockBalanceRepository.getBalancesForUTXO(any())).called(22);

      final capturedInputs =
          verify(() => mockComposeFunction(any(), captureAny(), any()))
              .captured
              .single as List<Utxo>;
      expect(capturedInputs.length, equals(20));
      expect(capturedInputs, containsAllInOrder(sortedUtxos));
    });

    test('should throw ComposeTransactionException when no UTXOs are found',
        () async {
      final composeTransactionUseCase = ComposeTransactionUseCase(
        utxoRepository: mockUtxoRepository,
        balanceRepository: mockBalanceRepository,
        errorService: mockErrorService,
      );

      // Arrange
      const source = 'test_source_address';
      const feeRate = 10;

      when(() => mockUtxoRepository.getUnspentForAddress(source,
          excludeCached: true)).thenAnswer((_) async => (<Utxo>[], <String>[]));

      // Act & Assert
      expect(
        () => composeTransactionUseCase.call(
          feeRate: feeRate,
          source: source,
          params: mockComposeParams,
          composeFn: mockComposeFunction.call,
        ),
        throwsA(isA<ComposeTransactionException>().having((e) => e.message,
            'message', 'Exception: No UTXOs available for transaction')),
      );
    });

    test(
        'should throw ComposeTransactionException when no UTXOs without balance are found in large inputs set',
        () async {
      final composeTransactionUseCase = ComposeTransactionUseCase(
        utxoRepository: mockUtxoRepository,
        balanceRepository: mockBalanceRepository,
        errorService: mockErrorService,
      );

      // Arrange
      const source = 'test_source_address';
      const feeRate = 10;
      const List<String> mockCachedTxHashes = ['mock_tx_id'];
      final mockUtxos = List.generate(25, (_) => MockUtxo());

      // Setup UTXOs
      for (var i = 0; i < mockUtxos.length; i++) {
        when(() => mockUtxos[i].txid).thenReturn('mockTxId$i');
        when(() => mockUtxos[i].vout).thenReturn(i);
        when(() => mockUtxos[i].value).thenReturn(1000 - i);
      }

      when(() => mockUtxoRepository.getUnspentForAddress(source,
              excludeCached: true))
          .thenAnswer((_) async => (mockUtxos, mockCachedTxHashes));

      // Make all UTXOs have balances
      for (var i = 0; i < mockUtxos.length; i++) {
        when(() => mockBalanceRepository.getBalancesForUTXO('mockTxId$i:$i'))
            .thenAnswer((_) async => [MockBalance()]);
      }

      // Act & Assert
      expect(
        () => composeTransactionUseCase.call(
          feeRate: feeRate,
          source: source,
          params: mockComposeParams,
          composeFn: mockComposeFunction.call,
        ),
        throwsA(isA<ComposeTransactionException>().having((e) => e.message,
            'message', 'Exception: No unattached UTXOs in input set')),
      );
    });

    test('should handle cached tx hashes when fetching UTXOs', () async {
      final composeTransactionUseCase = ComposeTransactionUseCase(
        utxoRepository: mockUtxoRepository,
        balanceRepository: mockBalanceRepository,
        errorService: mockErrorService,
      );

      // Arrange
      const source = 'test_source_address';
      const feeRate = 10;
      final mockUtxos = [MockUtxo(), MockUtxo(), MockUtxo()];
      final mockCachedTxHashes = ['mockTxId1', 'mockTxId3'];

      // Setup UTXOs
      when(() => mockUtxos[0].txid).thenReturn('mockTxId1');
      when(() => mockUtxos[0].vout).thenReturn(0);
      when(() => mockUtxos[1].txid).thenReturn('mockTxId2');
      when(() => mockUtxos[1].vout).thenReturn(0);
      when(() => mockUtxos[2].txid).thenReturn('mockTxId3');
      when(() => mockUtxos[2].vout).thenReturn(0);

      final mockComposeResponse = MockComposeResponse();

      when(() => mockUtxoRepository.getUnspentForAddress(source,
              excludeCached: true))
          .thenAnswer((_) async => (mockUtxos, mockCachedTxHashes));

      when(() => mockComposeFunction(feeRate, any(), mockComposeParams))
          .thenAnswer((_) async => mockComposeResponse);

      // Act
      final txResponse = await composeTransactionUseCase.call(
        feeRate: feeRate,
        source: source,
        params: mockComposeParams,
        composeFn: mockComposeFunction.call,
      );

      // Assert
      expect(txResponse, mockComposeResponse);
      verify(() => mockUtxoRepository.getUnspentForAddress(source,
          excludeCached: true)).called(1);

      final capturedInputs =
          verify(() => mockComposeFunction(any(), captureAny(), any()))
              .captured
              .single as List<Utxo>;
      expect(capturedInputs.length, equals(3));
    });

    test(
        'should throw ComposeTransactionException when all UTXOs in large set have balances',
        () async {
      final composeTransactionUseCase = ComposeTransactionUseCase(
        utxoRepository: mockUtxoRepository,
        balanceRepository: mockBalanceRepository,
        errorService: mockErrorService,
      );

      // Arrange
      const source = 'test_source_address';
      const feeRate = 10;
      final mockUtxos = List.generate(25, (_) => MockUtxo());
      const List<String> mockCachedTxHashes = [];

      // Setup UTXOs with descending values
      for (var i = 0; i < mockUtxos.length; i++) {
        when(() => mockUtxos[i].txid).thenReturn('mockTxId$i');
        when(() => mockUtxos[i].vout).thenReturn(i);
        when(() => mockUtxos[i].value).thenReturn(1000 - i);

        // Setup balance repository mock for each UTXO
        final utxoKey = 'mockTxId$i:$i';
        when(() => mockBalanceRepository.getBalancesForUTXO(utxoKey))
            .thenAnswer((_) async => [MockBalance()]);
      }

      when(() => mockUtxoRepository.getUnspentForAddress(source,
              excludeCached: true))
          .thenAnswer((_) async => (mockUtxos, mockCachedTxHashes));

      // Act & Assert
      await expectLater(
        () => composeTransactionUseCase.call(
          feeRate: feeRate,
          source: source,
          params: mockComposeParams,
          composeFn: mockComposeFunction.call,
        ),
        throwsA(isA<ComposeTransactionException>().having((e) => e.message,
            'message', 'Exception: No unattached UTXOs in input set')),
      );

      // Verify the repository calls
      verify(() => mockUtxoRepository.getUnspentForAddress(source,
          excludeCached: true)).called(1);

      // Verify balance checks - should check at least until we find all UTXOs have balances
      verify(() => mockBalanceRepository.getBalancesForUTXO(any()))
          .called(greaterThan(0));
    });
  });
}
