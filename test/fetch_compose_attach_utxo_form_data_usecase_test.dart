import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/estimate_xcp_fee_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/usecase/fetch_form_data.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockEstimateXcpFeeRepository extends Mock
    implements EstimateXcpFeeRepository {}

class MockComposeRepository extends Mock implements ComposeRepository {}

void main() {
  late FetchComposeAttachUtxoFormDataUseCase useCase;
  late MockGetFeeEstimatesUseCase mockGetFeeEstimatesUseCase;
  late MockBalanceRepository mockBalanceRepository;
  late MockEstimateXcpFeeRepository mockEstimateXcpFeeRepository;

  setUp(() {
    mockGetFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();
    mockBalanceRepository = MockBalanceRepository();
    mockEstimateXcpFeeRepository = MockEstimateXcpFeeRepository();
    useCase = FetchComposeAttachUtxoFormDataUseCase(
      getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
      balanceRepository: mockBalanceRepository,
      estimateXcpFeeRepository: mockEstimateXcpFeeRepository,
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

    const mockXcpFeeEstimate = 3;

    test('should return fee estimates and balance when both fetches succeed',
        () async {
      // Arrange
      when(() => mockGetFeeEstimatesUseCase.call())
          .thenAnswer((_) async => feeEstimates);

      when(() => mockBalanceRepository.getBalancesForAddress(
            testAddress,
            true,
          )).thenAnswer((_) async => [balance]);

      when(() => mockEstimateXcpFeeRepository.estimateAttachXcpFees(any()))
          .thenAnswer((_) async => mockXcpFeeEstimate);

      // Act
      final result = await useCase.call(testAddress);

      // Assert
      expect(result.$1, feeEstimates);
      expect(result.$2, [balance]);
      expect(result.$3, mockXcpFeeEstimate);
      verify(() => mockGetFeeEstimatesUseCase.call()).called(1);
      verify(() =>
              mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .called(1);
      verify(() =>
              mockEstimateXcpFeeRepository.estimateAttachXcpFees(testAddress))
          .called(1);
    });

    test('should throw FetchBalanceException when balance fetch fails',
        () async {
      // Arrange
      when(() => mockGetFeeEstimatesUseCase.call())
          .thenAnswer((_) async => feeEstimates);

      when(() => mockBalanceRepository.getBalancesForAddress(
            testAddress,
            true,
          )).thenThrow(Exception('Balance fetch failed'));

      // Act & Assert
      expect(
        () => useCase.call(testAddress),
        throwsA(isA<FetchBalanceException>()),
      );

      verify(() => mockGetFeeEstimatesUseCase.call()).called(1);
      verify(() =>
              mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .called(1);
    });

    test(
        'should throw FetchFeeEstimatesException when fee estimates fetch fails',
        () async {
      // Arrange
      when(() => mockGetFeeEstimatesUseCase.call())
          .thenThrow(Exception('Fee estimates fetch failed'));

      when(() => mockBalanceRepository.getBalancesForAddress(
            testAddress,
            true,
          )).thenAnswer((_) async => [balance]);

      // Act & Assert
      expect(
        () => useCase.call(testAddress),
        throwsA(isA<FetchFeeEstimatesException>()),
      );

      verify(() => mockGetFeeEstimatesUseCase.call()).called(1);
      verify(() =>
              mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .called(1);
    });
  });

  test(
      'should throw FetchAttachXcpFeesException when an xcp fees estimate error occurs',
      () async {
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

    // Arrange
    when(() => mockGetFeeEstimatesUseCase.call())
        .thenAnswer((_) async => feeEstimates);
    when(() => mockBalanceRepository.getBalancesForAddress(testAddress, true))
        .thenAnswer((_) async => [balance]);
    when(() => mockEstimateXcpFeeRepository.estimateAttachXcpFees(testAddress))
        .thenThrow(Exception('xcp fees estimate error'));

    // Act & Assert
    expect(
      () => useCase.call(testAddress),
      throwsA(isA<FetchAttachXcpFeesException>()),
    );
    verify(() => mockGetFeeEstimatesUseCase.call()).called(1);
    verify(() => mockBalanceRepository.getBalancesForAddress(testAddress, true))
        .called(1);
    verify(() =>
            mockEstimateXcpFeeRepository.estimateAttachXcpFees(testAddress))
        .called(1);
  });
}
