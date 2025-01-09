import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/estimate_xcp_fee_repository.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/screens/compose_dividend/usecase/fetch_form_data.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockAssetRepository extends Mock implements AssetRepository {}

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

class MockEstimateXcpFeeRepository extends Mock
    implements EstimateXcpFeeRepository {}

void main() {
  late FetchDividendFormDataUseCase useCase;
  late MockBalanceRepository mockBalanceRepository;
  late MockAssetRepository mockAssetRepository;
  late MockGetFeeEstimatesUseCase mockGetFeeEstimatesUseCase;
  late MockEstimateXcpFeeRepository mockEstimateXcpFeeRepository;
  setUp(() {
    mockBalanceRepository = MockBalanceRepository();
    mockAssetRepository = MockAssetRepository();
    mockGetFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();
    mockEstimateXcpFeeRepository = MockEstimateXcpFeeRepository();
    useCase = FetchDividendFormDataUseCase(
      balanceRepository: mockBalanceRepository,
      assetRepository: mockAssetRepository,
      getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
      estimateXcpFeeRepository: mockEstimateXcpFeeRepository,
    );
  });

  group('FetchDividendFormDataUseCase', () {
    const testAddress = 'test_address';
    const testAssetName = 'TEST_ASSET';

    const mockAsset = Asset(
      asset: testAssetName,
      assetLongname: 'Test Asset Long Name',
      description: 'Test Description',
      divisible: true,
      locked: false,
      issuer: testAddress,
      owner: testAddress,
      supply: 1000,
      supplyNormalized: '1000.00000000',
    );

    const mockAssetInfo = AssetInfo(
      assetLongname: 'Test Asset Info',
      divisible: true,
      description: 'Test Description',
    );

    final mockBalances = [
      Balance(
        address: testAddress,
        quantity: 1000,
        asset: 'ASSET1',
        assetInfo: mockAssetInfo,
        quantityNormalized: '1000.00000000',
      ),
      Balance(
        address: testAddress,
        quantity: 2000,
        asset: 'ASSET2',
        assetInfo: mockAssetInfo,
        quantityNormalized: '2000.00000000',
      ),
    ];

    const mockFeeEstimates = FeeEstimates(
      slow: 1,
      medium: 2,
      fast: 3,
    );
    const mockDividendXcpFee = 10000000;

    test('should fetch all data successfully', () async {
      // Arrange
      when(() => mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .thenAnswer((_) async => mockBalances);

      when(() => mockAssetRepository.getAssetVerbose(testAssetName))
          .thenAnswer((_) async => mockAsset);

      when(() => mockGetFeeEstimatesUseCase.call())
          .thenAnswer((_) async => mockFeeEstimates);

      when(() => mockEstimateXcpFeeRepository.estimateDividendXcpFees(
              testAddress, testAssetName))
          .thenAnswer((_) async => mockDividendXcpFee);

      // Act
      final result = await useCase.call(testAddress, testAssetName);

      // Assert
      expect(result.$1, equals(mockBalances));
      expect(result.$2, equals(mockAsset));
      expect(result.$3, equals(mockFeeEstimates));
      expect(result.$4, equals(mockDividendXcpFee));
      verify(() =>
              mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .called(1);
      verify(() => mockAssetRepository.getAssetVerbose(testAssetName))
          .called(1);
      verify(() => mockGetFeeEstimatesUseCase.call()).called(1);
      verify(() => mockEstimateXcpFeeRepository.estimateDividendXcpFees(
          testAddress, testAssetName)).called(1);
    });

    test('should throw FetchBalancesException when balance fetch fails',
        () async {
      // Arrange
      when(() => mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .thenThrow(Exception('Balance fetch failed'));

      when(() => mockAssetRepository.getAssetVerbose(testAssetName))
          .thenAnswer((_) async => mockAsset);

      when(() => mockGetFeeEstimatesUseCase.call())
          .thenAnswer((_) async => mockFeeEstimates);

      when(() => mockEstimateXcpFeeRepository.estimateDividendXcpFees(
              testAddress, testAssetName))
          .thenAnswer((_) async => mockDividendXcpFee);

      // Act & Assert
      expect(
        () => useCase.call(testAddress, testAssetName),
        throwsA(isA<FetchBalancesException>()),
      );

      verify(() =>
              mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .called(1);
    });

    test('should throw FetchAssetException when asset fetch fails', () async {
      // Arrange
      when(() => mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .thenAnswer((_) async => mockBalances);

      when(() => mockAssetRepository.getAssetVerbose(testAssetName))
          .thenThrow(Exception('Asset fetch failed'));

      when(() => mockGetFeeEstimatesUseCase.call())
          .thenAnswer((_) async => mockFeeEstimates);

      when(() => mockEstimateXcpFeeRepository.estimateDividendXcpFees(
              testAddress, testAssetName))
          .thenAnswer((_) async => mockDividendXcpFee);

      // Act & Assert
      expect(
        () => useCase.call(testAddress, testAssetName),
        throwsA(isA<FetchAssetException>()),
      );

      verify(() =>
              mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .called(1);
    });

    test(
        'should throw FetchFeeEstimatesException when fee estimates fetch fails',
        () async {
      // Arrange
      when(() => mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .thenAnswer((_) async => mockBalances);

      when(() => mockAssetRepository.getAssetVerbose(testAssetName))
          .thenAnswer((_) async => mockAsset);

      when(() => mockGetFeeEstimatesUseCase.call())
          .thenThrow(Exception('Fee estimates fetch failed'));

      when(() => mockEstimateXcpFeeRepository.estimateDividendXcpFees(
              testAddress, testAssetName))
          .thenAnswer((_) async => mockDividendXcpFee);

      // Act & Assert
      expect(
        () => useCase.call(testAddress, testAssetName),
        throwsA(isA<FetchFeeEstimatesException>()),
      );

      verify(() =>
              mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .called(1);
      verify(() => mockAssetRepository.getAssetVerbose(testAssetName))
          .called(1);
    });

    test(
        'should throw FetchDividendXcpFeeException when dividend XCP fee fetch fails',
        () async {
      // Arrange
      when(() => mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .thenAnswer((_) async => mockBalances);

      when(() => mockAssetRepository.getAssetVerbose(testAssetName))
          .thenAnswer((_) async => mockAsset);

      when(() => mockGetFeeEstimatesUseCase.call())
          .thenAnswer((_) async => mockFeeEstimates);

      when(() => mockEstimateXcpFeeRepository.estimateDividendXcpFees(
              testAddress, testAssetName))
          .thenThrow(Exception('Dividend XCP fee fetch failed'));

      // Act & Assert
      expect(
        () => useCase.call(testAddress, testAssetName),
        throwsA(isA<FetchDividendXcpFeeException>()),
      );

      verify(() =>
              mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .called(1);
      verify(() => mockAssetRepository.getAssetVerbose(testAssetName))
          .called(1);
      verify(() => mockGetFeeEstimatesUseCase.call()).called(1);
      verify(() => mockEstimateXcpFeeRepository.estimateDividendXcpFees(
          testAddress, testAssetName)).called(1);
    });
  });
}
