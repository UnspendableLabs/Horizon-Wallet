import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/screens/compose_dividend/usecase/fetch_form_data.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockAssetRepository extends Mock implements AssetRepository {}

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

void main() {
  late FetchDividendFormDataUseCase useCase;
  late MockBalanceRepository mockBalanceRepository;
  late MockAssetRepository mockAssetRepository;
  late MockGetFeeEstimatesUseCase mockGetFeeEstimatesUseCase;

  setUp(() {
    mockBalanceRepository = MockBalanceRepository();
    mockAssetRepository = MockAssetRepository();
    mockGetFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();
    useCase = FetchDividendFormDataUseCase(
      balanceRepository: mockBalanceRepository,
      assetRepository: mockAssetRepository,
      getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
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

    test('should fetch all data successfully', () async {
      // Arrange
      when(() => mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .thenAnswer((_) async => mockBalances);

      when(() => mockAssetRepository.getAssetVerbose(testAssetName))
          .thenAnswer((_) async => mockAsset);

      when(() => mockGetFeeEstimatesUseCase.call())
          .thenAnswer((_) async => mockFeeEstimates);

      // Act
      final result = await useCase.call(testAddress, testAssetName);

      // Assert
      expect(result.$1, equals(mockBalances));
      expect(result.$2, equals(mockAsset));
      expect(result.$3, equals(mockFeeEstimates));

      verify(() =>
              mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .called(1);
      verify(() => mockAssetRepository.getAssetVerbose(testAssetName))
          .called(1);
      verify(() => mockGetFeeEstimatesUseCase.call()).called(1);
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

      // Act & Assert
      expect(
        () => useCase.call(testAddress, testAssetName),
        throwsA(isA<FetchBalancesException>()),
      );
    });

    test('should throw FetchAssetException when asset fetch fails', () async {
      // Arrange
      when(() => mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .thenAnswer((_) async => mockBalances);

      when(() => mockAssetRepository.getAssetVerbose(testAssetName))
          .thenThrow(Exception('Asset fetch failed'));

      when(() => mockGetFeeEstimatesUseCase.call())
          .thenAnswer((_) async => mockFeeEstimates);

      // Act & Assert
      expect(
        () => useCase.call(testAddress, testAssetName),
        throwsA(isA<FetchAssetException>()),
      );
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

      // Act & Assert
      expect(
        () => useCase.call(testAddress, testAssetName),
        throwsA(isA<FetchFeeEstimatesException>()),
      );
    });
  });
}
