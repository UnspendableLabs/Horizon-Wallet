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

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockGetVirtualSizeUseCase extends Mock implements GetVirtualSizeUseCase {}

class MockComposeParams extends Mock implements ComposeParams {}

class MockComposeResponse extends Mock implements ComposeResponse {}

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
    mockBalanceRepository = MockBalanceRepository();
    mockGetVirtualSizeUseCase = MockGetVirtualSizeUseCase();
    mockComposeFunction = MockComposeFunction();
    mockComposeParams = MockComposeParams();
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

      // Update to match the stubbed txid:vout values
      when(() => mockBalanceRepository.getBalancesForUTXO(any()))
          .thenAnswer((_) async => []);

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
      when(() => mockBalanceRepository.getBalancesForUTXO(source))
          .thenAnswer((_) async => []);

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
      when(() => mockBalanceRepository.getBalancesForUTXO(source))
          .thenAnswer((_) async => []);

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

    test('should use only available UTXOs when some UTXOs are unavailable',
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

      // Mock UTXOs
      final mockUtxo1 = MockUtxo();
      final mockUtxo2 = MockUtxo();
      final mockUtxos = [mockUtxo1, mockUtxo2];

      // Stub txid and vout for both UTXOs
      when(() => mockUtxo1.txid).thenReturn('mockTxId1');
      when(() => mockUtxo1.vout).thenReturn(0);

      when(() => mockUtxo2.txid).thenReturn('mockTxId2');
      when(() => mockUtxo2.vout).thenReturn(1);

      // Set up the virtual size and total fee calculations
      const virtualSize = 100;
      const adjustedVirtualSize = virtualSize * 5;
      const totalFee = adjustedVirtualSize * feeRate;

      final mockComposeResponse = MockComposeResponse();

      // Mock the UTXO repository to return our mock UTXOs
      when(() => mockUtxoRepository.getUnspentForAddress(source))
          .thenAnswer((_) async => mockUtxos);

      // Mock the balance repository to simulate that mockUtxo1 has an associated balance (unavailable)
      when(() => mockBalanceRepository.getBalancesForUTXO('mockTxId1:0'))
          .thenAnswer((_) async => [MockBalance()]); // Non-empty list

      // Mock the balance repository to simulate that mockUtxo2 has no associated balances (available)
      when(() => mockBalanceRepository.getBalancesForUTXO('mockTxId2:1'))
          .thenAnswer((_) async => []); // Empty list

      // Since only mockUtxo2 is available, it should be the only one used in subsequent calls
      when(() => mockGetVirtualSizeUseCase.call(
              composeFunction: mockComposeFunction.call,
              inputsSet: [mockUtxo2], // Only mockUtxo2
              params: mockComposeParams))
          .thenAnswer((_) async => (virtualSize, adjustedVirtualSize));

      when(() => mockComposeFunction(totalFee, [mockUtxo2], mockComposeParams))
          .thenAnswer((_) async => mockComposeResponse);

      // Act
      final result = await composeTransactionUseCase.call(
        feeRate: feeRate,
        source: source,
        params: mockComposeParams,
        composeFn: mockComposeFunction.call,
      );

      // Assert
      expect(result,
          (mockComposeResponse, const VirtualSize(virtualSize, adjustedVirtualSize)));

      // Verify that getUnspentForAddress was called once
      verify(() => mockUtxoRepository.getUnspentForAddress(source)).called(1);

      // Verify that getBalancesForUTXO was called for each UTXO
      verify(() => mockBalanceRepository.getBalancesForUTXO('mockTxId1:0'))
          .called(1);
      verify(() => mockBalanceRepository.getBalancesForUTXO('mockTxId2:1'))
          .called(1);

      // Verify that getVirtualSizeUseCase and composeFunction were called with only the available UTXO
      verify(() => mockGetVirtualSizeUseCase.call(
            composeFunction: mockComposeFunction.call,
            inputsSet: [mockUtxo2], // Only the available UTXO
            params: mockComposeParams,
          )).called(1);

      verify(() =>
              mockComposeFunction(totalFee, [mockUtxo2], mockComposeParams))
          .called(1);
    });
  });
}
