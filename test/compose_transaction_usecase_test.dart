import 'package:flutter_test/flutter_test.dart';
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

class MockComposeFunction extends Mock {
  Future<MockComposeResponse> call(
    int fee,
    List<Utxo> inputsSet,
    ComposeParams params, // Adjusted for new signature
  );
}

class MockUtxo extends Mock implements Utxo {}

void main() {
  late MockUtxoRepository mockUtxoRepository;
  late MockGetVirtualSizeUseCase mockGetVirtualSizeUseCase;
  late MockComposeFunction mockComposeFunction;
  late MockComposeParams mockComposeParams;

  setUp(() {
    // Initialize mocks before each test
    mockUtxoRepository = MockUtxoRepository();
    mockGetVirtualSizeUseCase = MockGetVirtualSizeUseCase();
    mockComposeFunction = MockComposeFunction();
    mockComposeParams = MockComposeParams();
  });

  group('ComposeTransactionUseCase', () {
    test('should successfully compose a transaction', () async {
      // Create a fresh instance for this test
      final composeTransactionUseCase = ComposeTransactionUseCase(
        utxoRepository: mockUtxoRepository,
        getVirtualSizeUseCase: mockGetVirtualSizeUseCase,
      );

      // Arrange
      const source = 'test_source_address';
      const feeRate = 10;

      // Mock UTXOs with placeholder values
      final mockUtxos = [MockUtxo(), MockUtxo()];

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
      expect(result, (mockComposeResponse, VirtualSize(100, 500)));
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
  });
}
