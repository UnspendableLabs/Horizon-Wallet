import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/screens/compose_issuance/usecase/fetch_form_data.dart';

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

void main() {
  late FetchIssuanceFormDataUseCase useCase;
  late MockBalanceRepository mockBalanceRepository;
  late MockGetFeeEstimatesUseCase mockGetFeeEstimatesUseCase;

  setUpAll(() {
    registerFallbackValue((1, 3, 6));
  });

  setUp(() {
    mockBalanceRepository = MockBalanceRepository();
    mockGetFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();
    useCase = FetchIssuanceFormDataUseCase(
      balanceRepository: mockBalanceRepository,
      getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
    );
  });

  group('FetchIssuanceFormDataUseCase', () {
    const testAddress = 'test_address';
    const assetInfo = AssetInfo(
      assetLongname: "TEST_ASSET",
      divisible: true,
      description: "Test Asset Description",
      locked: false,
    );

    final balances = [
      Balance(
        address: testAddress,
        asset: 'TEST_ASSET',
        quantity: 1000,
        quantityNormalized: '0.00001000',
        assetInfo: assetInfo,
      ),
    ];

    const feeEstimates = FeeEstimates(
      slow: 1,
      medium: 2,
      fast: 3,
    );

    test('should fetch all data successfully', () async {
      // Arrange
      when(() => mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .thenAnswer((_) async => balances);

      when(() => mockGetFeeEstimatesUseCase.call())
          .thenAnswer((_) async => feeEstimates);

      // Act
      final result = await useCase.call(testAddress);

      // Assert
      expect(result.$1, equals(balances));
      expect(result.$2, equals(feeEstimates));

      verify(() =>
              mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .called(1);
      verify(() => mockGetFeeEstimatesUseCase.call()).called(1);
    });

    test('should throw FetchBalancesException when balance fetch fails',
        () async {
      // Arrange
      when(() => mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .thenThrow(Exception('Balance fetch failed'));

      when(() => mockGetFeeEstimatesUseCase.call())
          .thenAnswer((_) async => feeEstimates);

      // Act & Assert
      expect(
        () => useCase.call(testAddress),
        throwsA(isA<FetchBalancesException>()),
      );
    });

    test(
        'should throw FetchFeeEstimatesException when fee estimates fetch fails',
        () async {
      // Arrange
      when(() => mockBalanceRepository.getBalancesForAddress(testAddress, true))
          .thenAnswer((_) async => balances);

      when(() => mockGetFeeEstimatesUseCase.call())
          .thenThrow(Exception('Fee estimates fetch failed'));

      // Act & Assert
      expect(
        () => useCase.call(testAddress),
        throwsA(isA<FetchFeeEstimatesException>()),
      );
    });
  });
}
