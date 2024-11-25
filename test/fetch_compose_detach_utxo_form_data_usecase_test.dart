import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/presentation/screens/compose_detach_utxo/usecase/fetch_form_data.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

class MockBalanceRepository extends Mock implements BalanceRepository {}

void main() {
  late FetchComposeDetachUtxoFormDataUseCase useCase;
  late MockGetFeeEstimatesUseCase mockGetFeeEstimatesUseCase;
  late MockBalanceRepository mockBalanceRepository;

  setUp(() {
    mockGetFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();
    mockBalanceRepository = MockBalanceRepository();

    useCase = FetchComposeDetachUtxoFormDataUseCase(
      getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
      balanceRepository: mockBalanceRepository,
    );
  });

  group('FetchComposeMoveToUtxoFormDataUseCase', () {
    const testAddress = 'test-address';
    const testAssetName = 'ASSET_NAME';
    const feeEstimates = FeeEstimates(fast: 10, medium: 5, slow: 2);

    final balance = Balance(
      address: testAddress,
      asset: testAssetName,
      quantity: 1000,
      quantityNormalized: '0.00001000',
      assetInfo: const AssetInfo(
        description: testAssetName,
        divisible: true,
      ),
      utxo: 'some-utxo',
      utxoAddress: 'some-utxo-address',
    );
    const testUtxo = 'some-utxo';

    test('should return fee estimates and balance when both fetches succeed',
        () async {
      // Arrange
      when(() => mockGetFeeEstimatesUseCase.call(targets: (1, 3, 6)))
          .thenAnswer((_) async => feeEstimates);

      when(() => mockBalanceRepository.getBalancesForUTXO(
            testUtxo,
          )).thenAnswer((_) async => [balance]);

      // Act
      final result = await useCase.call(testUtxo);

      // Assert
      expect(result.$1, feeEstimates);
      expect(result.$2, balance);

      verify(() => mockGetFeeEstimatesUseCase.call(targets: (1, 3, 6)))
          .called(1);
      verify(() => mockBalanceRepository.getBalancesForUTXO(
            testUtxo,
          )).called(1);
    });

    test('should throw FetchBalanceException when balance fetch fails',
        () async {
      // Arrange
      when(() => mockGetFeeEstimatesUseCase.call(targets: (1, 3, 6)))
          .thenAnswer((_) async => feeEstimates);

      when(() => mockBalanceRepository.getBalancesForUTXO(
            testUtxo,
          )).thenThrow(Exception('Balance fetch failed'));

      // Act & Assert
      expect(
        () => useCase.call(testUtxo),
        throwsA(isA<FetchBalanceException>()),
      );

      verify(() => mockGetFeeEstimatesUseCase.call(targets: (1, 3, 6)))
          .called(1);
      verify(() => mockBalanceRepository.getBalancesForUTXO(
            testUtxo,
          )).called(1);
    });

    test('should throw FetchBalanceException when balance is empty', () async {
      // Arrange
      when(() => mockGetFeeEstimatesUseCase.call(targets: (1, 3, 6)))
          .thenAnswer((_) async => feeEstimates);

      when(() => mockBalanceRepository.getBalancesForUTXO(
            testUtxo,
          )).thenAnswer((_) async => []);

      // Act & Assert
      expect(
        () => useCase.call(testUtxo),
        throwsA(isA<FetchBalanceException>()),
      );

      verify(() => mockGetFeeEstimatesUseCase.call(targets: (1, 3, 6)))
          .called(1);
      verify(() => mockBalanceRepository.getBalancesForUTXO(
            testUtxo,
          )).called(1);
    });

    test('should throw FetchBalanceException when balance has multiple entries',
        () async {
      // Arrange
      when(() => mockGetFeeEstimatesUseCase.call(targets: (1, 3, 6)))
          .thenAnswer((_) async => feeEstimates);

      when(() => mockBalanceRepository.getBalancesForUTXO(
            testUtxo,
          )).thenAnswer((_) async => [balance, balance]);

      // Act & Assert
      expect(
        () => useCase.call(testUtxo),
        throwsA(isA<FetchBalanceException>()),
      );

      verify(() => mockGetFeeEstimatesUseCase.call(targets: (1, 3, 6)))
          .called(1);
      verify(() => mockBalanceRepository.getBalancesForUTXO(
            testUtxo,
          )).called(1);
    });

    test(
        'should throw FetchFeeEstimatesException when fee estimates fetch fails',
        () async {
      // Arrange
      when(() => mockGetFeeEstimatesUseCase.call(targets: (1, 3, 6)))
          .thenThrow(Exception('Fee estimates fetch failed'));

      when(() => mockBalanceRepository.getBalancesForUTXO(
            testUtxo,
          )).thenAnswer((_) async => [balance]);

      // Act & Assert
      expect(
        () => useCase.call(testUtxo),
        throwsA(isA<FetchFeeEstimatesException>()),
      );

      verify(() => mockGetFeeEstimatesUseCase.call(targets: (1, 3, 6)))
          .called(1);
      verify(() => mockBalanceRepository.getBalancesForUTXO(
            testUtxo,
          )).called(1);
    });
  });
}
