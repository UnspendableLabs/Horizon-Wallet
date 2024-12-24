import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/fairminter_repository.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/fairminter.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/screens/compose_fairminter/usecase/fetch_form_data.dart';
import 'package:fpdart/fpdart.dart';

// Mock classes
class MockAssetRepository extends Mock implements AssetRepository {}

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

class MockFairminterRepository extends Mock implements FairminterRepository {}

class MockAsset extends Mock implements Asset {}

class MockFairminter extends Mock implements Fairminter {}

void main() {
  late FetchFairminterFormDataUseCase useCase;
  late MockAssetRepository mockAssetRepository;
  late MockGetFeeEstimatesUseCase mockGetFeeEstimatesUseCase;
  late MockFairminterRepository mockFairminterRepository;

  setUp(() {
    mockAssetRepository = MockAssetRepository();
    mockGetFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();
    mockFairminterRepository = MockFairminterRepository();
    useCase = FetchFairminterFormDataUseCase(
      assetRepository: mockAssetRepository,
      getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
      fairminterRepository: mockFairminterRepository,
    );
  });

  group('FetchFairminterFormDataUseCase', () {
    const testAddress = 'test_address';
    final mockAssets = [MockAsset(), MockAsset()];
    final mockFairminters = [MockFairminter(), MockFairminter()];
    const mockFeeEstimates = FeeEstimates(
      slow: 1,
      medium: 2,
      fast: 3,
    );

    test('should fetch all data successfully', () async {
      // Arrange
      when(() =>
              mockAssetRepository.getAllValidAssetsByOwnerVerbose(testAddress))
          .thenAnswer((_) async => mockAssets);

      when(() => mockGetFeeEstimatesUseCase.call())
          .thenAnswer((_) async => mockFeeEstimates);

      when(() => mockFairminterRepository.getFairmintersByAddress(testAddress))
          .thenAnswer((_) => TaskEither.right(mockFairminters));

      // Act
      final result = await useCase.call(testAddress);

      // Assert
      expect(result.$1, equals(mockAssets));
      expect(result.$2, equals(mockFeeEstimates));
      expect(result.$3, equals(mockFairminters));

      verify(() =>
              mockAssetRepository.getAllValidAssetsByOwnerVerbose(testAddress))
          .called(1);
      verify(() => mockGetFeeEstimatesUseCase.call()).called(1);
      verify(() =>
              mockFairminterRepository.getFairmintersByAddress(testAddress))
          .called(1);
    });

    test('should throw FetchAssetsException when asset fetch fails', () async {
      // Arrange
      when(() =>
              mockAssetRepository.getAllValidAssetsByOwnerVerbose(testAddress))
          .thenThrow(Exception('Asset fetch failed'));

      when(() => mockGetFeeEstimatesUseCase.call())
          .thenAnswer((_) async => mockFeeEstimates);

      when(() => mockFairminterRepository.getFairmintersByAddress(testAddress))
          .thenAnswer((_) => TaskEither.right(mockFairminters));

      // Act & Assert
      expect(
        () => useCase.call(testAddress),
        throwsA(isA<FetchAssetsException>()),
      );
    });

    test(
        'should throw FetchFeeEstimatesException when fee estimates fetch fails',
        () async {
      // Arrange
      when(() =>
              mockAssetRepository.getAllValidAssetsByOwnerVerbose(testAddress))
          .thenAnswer((_) async => mockAssets);

      when(() => mockGetFeeEstimatesUseCase.call())
          .thenThrow(Exception('Fee estimates fetch failed'));

      when(() => mockFairminterRepository.getFairmintersByAddress(testAddress))
          .thenAnswer((_) => TaskEither.right(mockFairminters));

      // Act & Assert
      expect(
        () => useCase.call(testAddress),
        throwsA(isA<FetchFeeEstimatesException>()),
      );
    });

    test('should throw FetchFairmintersException when fairminters fetch fails',
        () async {
      // Arrange
      when(() =>
              mockAssetRepository.getAllValidAssetsByOwnerVerbose(testAddress))
          .thenAnswer((_) async => mockAssets);

      when(() => mockGetFeeEstimatesUseCase.call())
          .thenAnswer((_) async => mockFeeEstimates);

      when(() => mockFairminterRepository.getFairmintersByAddress(testAddress))
          .thenThrow(Exception('Fairminters fetch failed'));

      // Act & Assert
      expect(
        () => useCase.call(testAddress),
        throwsA(isA<FetchFairmintersException>()),
      );
    });
  });
}
