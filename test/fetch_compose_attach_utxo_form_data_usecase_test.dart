import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/usecase/fetch_form_data.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

class MockBalanceRepository extends Mock implements BalanceRepository {}

void main() {
  late FetchComposeAttachUtxoFormDataUseCase useCase;
  late MockGetFeeEstimatesUseCase mockGetFeeEstimatesUseCase;
  late MockBalanceRepository mockBalanceRepository;

  setUp(() {
    mockGetFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();
    mockBalanceRepository = MockBalanceRepository();

    useCase = FetchComposeAttachUtxoFormDataUseCase(
      getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
      balanceRepository: mockBalanceRepository,
    );
  });

  group('FetchComposeAttachUtxoFormDataUseCase', () {
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
      utxo: null,
      utxoAddress: null,
    );

    test('should return fee estimates and balance when both fetches succeed',
        () async {
      // Arrange
      when(() => mockGetFeeEstimatesUseCase.call())
          .thenAnswer((_) async => feeEstimates);

      when(() => mockBalanceRepository.getBalancesForAddressAndAssetVerbose(
            testAddress,
            testAssetName,
          )).thenAnswer((_) async => [balance]);

      // Act
      final result = await useCase.call(testAddress, testAssetName);

      // Assert
      expect(result.$1, feeEstimates);
      expect(result.$2, balance);

      verify(() => mockGetFeeEstimatesUseCase.call()).called(1);
      verify(() => mockBalanceRepository.getBalancesForAddressAndAssetVerbose(
            testAddress,
            testAssetName,
          )).called(1);
    });

    test(
        'should throw FetchBalanceException when balance contains multiple asset balances',
        () async {
      // Arrange
      when(() => mockGetFeeEstimatesUseCase.call())
          .thenAnswer((_) async => feeEstimates);

      when(() => mockBalanceRepository.getBalancesForAddressAndAssetVerbose(
            testAddress,
            testAssetName,
          )).thenAnswer((_) async => [balance, balance]);

      // Act & Assert
      expect(
        () => useCase.call(testAddress, testAssetName),
        throwsA(isA<FetchBalanceException>()),
      );

      verify(() => mockGetFeeEstimatesUseCase.call()).called(1);
      verify(() => mockBalanceRepository.getBalancesForAddressAndAssetVerbose(
            testAddress,
            testAssetName,
          )).called(1);
    });

    test('should throw FetchBalanceException when balance contains no balances',
        () async {
      // Arrange
      when(() => mockGetFeeEstimatesUseCase.call())
          .thenAnswer((_) async => feeEstimates);

      when(() => mockBalanceRepository.getBalancesForAddressAndAssetVerbose(
            testAddress,
            testAssetName,
          )).thenAnswer((_) async => []);

      // Act & Assert
      expect(
        () => useCase.call(testAddress, testAssetName),
        throwsA(isA<FetchBalanceException>()),
      );

      verify(() => mockGetFeeEstimatesUseCase.call()).called(1);
      verify(() => mockBalanceRepository.getBalancesForAddressAndAssetVerbose(
            testAddress,
            testAssetName,
          )).called(1);
    });

    test('should throw FetchBalanceException when balance fetch fails',
        () async {
      // Arrange
      when(() => mockGetFeeEstimatesUseCase.call())
          .thenAnswer((_) async => feeEstimates);

      when(() => mockBalanceRepository.getBalancesForAddressAndAssetVerbose(
            testAddress,
            testAssetName,
          )).thenThrow(Exception('Balance fetch failed'));

      // Act & Assert
      expect(
        () => useCase.call(testAddress, testAssetName),
        throwsA(isA<FetchBalanceException>()),
      );

      verify(() => mockGetFeeEstimatesUseCase.call()).called(1);
      verify(() => mockBalanceRepository.getBalancesForAddressAndAssetVerbose(
            testAddress,
            testAssetName,
          )).called(1);
    });

    test(
        'should throw FetchFeeEstimatesException when fee estimates fetch fails',
        () async {
      // Arrange
      when(() => mockGetFeeEstimatesUseCase.call())
          .thenThrow(Exception('Fee estimates fetch failed'));

      when(() => mockBalanceRepository.getBalancesForAddressAndAssetVerbose(
            testAddress,
            testAssetName,
          )).thenAnswer((_) async => [balance]);

      // Act & Assert
      expect(
        () => useCase.call(testAddress, testAssetName),
        throwsA(isA<FetchFeeEstimatesException>()),
      );

      verify(() => mockGetFeeEstimatesUseCase.call()).called(1);
      verify(() => mockBalanceRepository.getBalancesForAddressAndAssetVerbose(
            testAddress,
            testAssetName,
          )).called(1);
    });
  });
}
