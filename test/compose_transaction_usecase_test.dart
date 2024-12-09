import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/presentation/common/usecase/get_virtual_size_usecase.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/compose_fn.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';

// Define mock classes
class MockUtxoRepository extends Mock implements UtxoRepository {}

class MockGetVirtualSizeUseCase extends Mock implements GetVirtualSizeUseCase {}

class MockComposeParams extends Mock implements ComposeParams {}

class MockComposeResponse extends Mock implements ComposeResponse {}

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockComposeFunction extends Mock {
  Future<MockComposeResponse> call(
    int fee,
    List<Utxo> inputsSet,
    ComposeParams params, // Adjusted for new signature
  );
}

class MockUtxo extends Mock implements Utxo {}

class MockBalance extends Mock implements Balance {}

void main() {
  late MockUtxoRepository mockUtxoRepository;
  late MockGetVirtualSizeUseCase mockGetVirtualSizeUseCase;
  late MockComposeFunction mockComposeFunction;
  late MockComposeParams mockComposeParams;
  late MockBalanceRepository mockBalanceRepository;
  setUp(() {
    // Initialize mocks before each test
    mockUtxoRepository = MockUtxoRepository();
    mockGetVirtualSizeUseCase = MockGetVirtualSizeUseCase();
    mockComposeFunction = MockComposeFunction();
    mockComposeParams = MockComposeParams();
    mockBalanceRepository = MockBalanceRepository();
    registerFallbackValue(mockComposeParams);
  });

  group('ComposeTransactionUseCase', () {
    test('should successfully compose a transaction', () async {
      // Create a fresh instance for this test
      final composeTransactionUseCase = ComposeTransactionUseCase(
        utxoRepository: mockUtxoRepository,
        balanceRepository: mockBalanceRepository,
        getVirtualSizeUseCase: mockGetVirtualSizeUseCase,
      );

      // Arrange
      const source = 'test_source_address';
      const feeRate = 10;

      // Mock UTXOs with placeholder values
      final mockUtxos = [MockUtxo(), MockUtxo()];

      // Stub txid and vout
      when(() => mockUtxos[0].txid).thenReturn('mockTxId1');
      when(() => mockUtxos[0].vout).thenReturn(0);
      when(() => mockUtxos[1].txid).thenReturn('mockTxId2');
      when(() => mockUtxos[1].vout).thenReturn(1);

      const virtualSize = 100;
      const adjustedVirtualSize = virtualSize * 5;
      const totalFee = adjustedVirtualSize * feeRate;
      final mockComposeResponse = MockComposeResponse();

      when(() => mockUtxoRepository.getUnspentForAddress(source))
          .thenAnswer((_) async => mockUtxos);

      when(() => mockGetVirtualSizeUseCase.call(
              composeFunction: mockComposeFunction.call,
              inputsSet: mockUtxos,
              params: mockComposeParams))
          .thenAnswer((_) async => (virtualSize, adjustedVirtualSize));

      when(() => mockComposeFunction(totalFee, mockUtxos, mockComposeParams))
          .thenAnswer((_) async => mockComposeResponse);

      // Act
      final result = await composeTransactionUseCase.call(
        feeRate: feeRate,
        source: source,
        params: mockComposeParams,
        composeFn: mockComposeFunction.call,
      );

      // Assert
      expect(result, (mockComposeResponse, const VirtualSize(100, 500)));
      verify(() => mockUtxoRepository.getUnspentForAddress(source)).called(1);
      verify(() => mockGetVirtualSizeUseCase.call(
            composeFunction: mockComposeFunction.call,
            inputsSet: mockUtxos,
            params: mockComposeParams,
          )).called(1);
      verify(() => mockComposeFunction(totalFee, mockUtxos, mockComposeParams))
          .called(1);
    });

    test('should throw ComposeTransactionException if fetching UTXOs fails',
        () async {
      // Create a fresh instance for this test
      final composeTransactionUseCase = ComposeTransactionUseCase(
        utxoRepository: mockUtxoRepository,
        balanceRepository: mockBalanceRepository,
        getVirtualSizeUseCase: mockGetVirtualSizeUseCase,
      );

      // Arrange
      const source = 'test_source_address';
      const feeRate = 10;

      when(() => mockUtxoRepository.getUnspentForAddress(source))
          .thenThrow(Exception('Failed to fetch UTXOs'));

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
      verify(() => mockUtxoRepository.getUnspentForAddress(source)).called(1);
    });

    test(
        'should throw ComposeTransactionException if calculating virtual size fails',
        () async {
      // Create a fresh instance for this test

      final composeTransactionUseCase = ComposeTransactionUseCase(
        utxoRepository: mockUtxoRepository,
        balanceRepository: mockBalanceRepository,
        getVirtualSizeUseCase: mockGetVirtualSizeUseCase,
      );

      // Arrange
      const source = 'test_source_address';
      const feeRate = 10;
      final mockUtxos = [MockUtxo(), MockUtxo()];

      when(() => mockUtxoRepository.getUnspentForAddress(source))
          .thenAnswer((_) async => mockUtxos);

      when(() => mockGetVirtualSizeUseCase.call(
            params: mockComposeParams,
            composeFunction: mockComposeFunction.call,
            inputsSet: mockUtxos,
          )).thenThrow(Exception('Failed to calculate virtual size'));

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
      // Create a fresh instance for this test
      final composeTransactionUseCase = ComposeTransactionUseCase(
        utxoRepository: mockUtxoRepository,
        balanceRepository: mockBalanceRepository,
        getVirtualSizeUseCase: mockGetVirtualSizeUseCase,
      );

      // Arrange
      const source = 'test_source_address';
      const feeRate = 10;
      final mockUtxos = [MockUtxo(), MockUtxo()];
      const virtualSize = 100;
      const adjustedVirtualSize = 5 * virtualSize;
      const totalFee = adjustedVirtualSize * feeRate;

      when(() => mockUtxoRepository.getUnspentForAddress(source))
          .thenAnswer((_) async => mockUtxos);

      when(() => mockGetVirtualSizeUseCase.call(
            params: mockComposeParams,
            composeFunction: mockComposeFunction.call,
            inputsSet: mockUtxos,
          )).thenAnswer((_) async => (virtualSize, adjustedVirtualSize));

      when(() => mockComposeFunction(totalFee, mockUtxos, mockComposeParams))
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
        getVirtualSizeUseCase: mockGetVirtualSizeUseCase,
      );

      // Arrange
      const source = 'test_source_address';
      const feeRate = 10;

      // Mock UTXOs with placeholder values
      final mockUtxos = List.generate(25, (_) => MockUtxo());

      // Stub txid, vout, and value for each UTXO
      for (var i = 0; i < mockUtxos.length; i++) {
        when(() => mockUtxos[i].txid).thenReturn('mockTxId$i');
        when(() => mockUtxos[i].vout).thenReturn(i);
        when(() => mockUtxos[i].value).thenReturn(1000 - i); // Decreasing value
      }

      const virtualSize = 100;
      const adjustedVirtualSize = virtualSize * 5;
      const totalFee = adjustedVirtualSize * feeRate;
      final mockComposeResponse = MockComposeResponse();

      when(() => mockUtxoRepository.getUnspentForAddress(source))
          .thenAnswer((_) async => mockUtxos);

      when(() => mockBalanceRepository.getBalancesForUTXO(any()))
          .thenAnswer((_) async => []);

      mockUtxos.sort((a, b) => b.value.compareTo(a.value));
      final sortedUtxos = mockUtxos.take(20).toList();
      when(() => mockGetVirtualSizeUseCase.call(
              composeFunction: mockComposeFunction.call,
              inputsSet: sortedUtxos,
              params: mockComposeParams))
          .thenAnswer((_) async => (virtualSize, adjustedVirtualSize));

      when(() => mockComposeFunction(totalFee, sortedUtxos, mockComposeParams))
          .thenAnswer((_) async => mockComposeResponse);

      // Act
      final result = await composeTransactionUseCase.call(
        feeRate: feeRate,
        source: source,
        params: mockComposeParams,
        composeFn: mockComposeFunction.call,
      );

      // Assert
      expect(result, (mockComposeResponse, const VirtualSize(100, 500)));
      verify(() => mockUtxoRepository.getUnspentForAddress(source)).called(1);
      verify(() => mockBalanceRepository.getBalancesForUTXO(any())).called(20);
      verify(() => mockGetVirtualSizeUseCase.call(
            composeFunction: mockComposeFunction.call,
            inputsSet: sortedUtxos,
            params: mockComposeParams,
          )).called(1);
      // Verify that the compose function is called with the expected largest 10 UTXOs
      final capturedInputs =
          verify(() => mockComposeFunction(any(), captureAny(), any()))
              .captured
              .single as List<Utxo>;
      expect(capturedInputs.length, equals(20));
      // Check that the captured inputs are the largest 20 UTXOs
      expect(capturedInputs, containsAllInOrder(sortedUtxos));
    });

    test('should exclude top 2 UTXOs with balances from the final inputs',
        () async {
      final composeTransactionUseCase = ComposeTransactionUseCase(
        utxoRepository: mockUtxoRepository,
        balanceRepository: mockBalanceRepository,
        getVirtualSizeUseCase: mockGetVirtualSizeUseCase,
      );

      // Arrange
      const source = 'test_source_address';
      const feeRate = 10;

      // Mock UTXOs with placeholder values
      final mockUtxos = List.generate(25, (_) => MockUtxo());

      // Stub txid, vout, and value for each UTXO
      for (var i = 0; i < mockUtxos.length; i++) {
        when(() => mockUtxos[i].txid).thenReturn('mockTxId$i');
        when(() => mockUtxos[i].vout).thenReturn(i);
        when(() => mockUtxos[i].value).thenReturn(1000 - i); // Decreasing value
      }

      const virtualSize = 100;
      const adjustedVirtualSize = virtualSize * 5;
      const totalFee = adjustedVirtualSize * feeRate;
      final mockComposeResponse = MockComposeResponse();

      when(() => mockUtxoRepository.getUnspentForAddress(source))
          .thenAnswer((_) async => mockUtxos);

      // Return a balance for the top 2 UTXOs
      when(() => mockBalanceRepository.getBalancesForUTXO('mockTxId0:0'))
          .thenAnswer((_) async => [MockBalance()]);
      when(() => mockBalanceRepository.getBalancesForUTXO('mockTxId1:1'))
          .thenAnswer((_) async => [MockBalance()]);

      // Return no balance for other UTXOs
      for (var i = 2; i < mockUtxos.length; i++) {
        when(() => mockBalanceRepository.getBalancesForUTXO('mockTxId$i:$i'))
            .thenAnswer((_) async => []);
      }

      mockUtxos.sort((a, b) => b.value.compareTo(a.value));
      final sortedUtxos = mockUtxos.skip(2).take(20).toList(); // Exclude top 2

      when(() => mockGetVirtualSizeUseCase.call(
              composeFunction: mockComposeFunction.call,
              inputsSet: sortedUtxos,
              params: mockComposeParams))
          .thenAnswer((_) async => (virtualSize, adjustedVirtualSize));

      when(() => mockComposeFunction(totalFee, sortedUtxos, mockComposeParams))
          .thenAnswer((_) async => mockComposeResponse);

      // Act
      final result = await composeTransactionUseCase.call(
        feeRate: feeRate,
        source: source,
        params: mockComposeParams,
        composeFn: mockComposeFunction.call,
      );

      // Assert
      expect(result, (mockComposeResponse, const VirtualSize(100, 500)));
      verify(() => mockUtxoRepository.getUnspentForAddress(source)).called(1);
      verify(() => mockBalanceRepository.getBalancesForUTXO(any()))
          .called(22); // 20 inputs calls without balances and 2 with balances
      verify(() => mockGetVirtualSizeUseCase.call(
            composeFunction: mockComposeFunction.call,
            inputsSet: sortedUtxos,
            params: mockComposeParams,
          )).called(1);

      // Verify that the compose function is called with the expected UTXOs
      final capturedInputs =
          verify(() => mockComposeFunction(any(), captureAny(), any()))
              .captured
              .single as List<Utxo>;
      expect(capturedInputs.length, equals(20));
      // Check that the captured inputs exclude the top 2 UTXOs
      expect(capturedInputs, containsAllInOrder(sortedUtxos));
    });
  });
}
