import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/fetch_form_data.dart';

// Mock classes
class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

void main() {
  late FetchDispenseFormDataUseCase useCase;
  late MockBalanceRepository mockBalanceRepository;
  late MockGetFeeEstimatesUseCase mockGetFeeEstimatesUseCase;

  setUpAll(() {
    registerFallbackValue((1, 3, 6));
  });

  setUp(() {
    mockBalanceRepository = MockBalanceRepository();
    mockGetFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();
    useCase = FetchDispenseFormDataUseCase(
      balanceRepository: mockBalanceRepository,
      getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
    );
  });

  test('should return balances and fee estimates when both fetches succeed',
      () async {
    // Arrange
    const address = Address(
      accountUuid: 'test-account-uuid',
      address: 'test-address',
      index: 0,
    );

    const assetInfo = AssetInfo(
      assetLongname: "BTC_LONGNAME",
      divisible: true,
      description: "Bitcoin Description",
    );

    final balances = [
      Balance(
        address: address.address,
        asset: 'BTC',
        quantity: 1000,
        quantityNormalized: '0.00001000',
        assetInfo: assetInfo, // Adding assetInfo to the balance entity
      ),
    ];

    const feeEstimates = FeeEstimates(fast: 10, medium: 5, slow: 2);

    when(() => mockBalanceRepository.getBalancesForAddress(address.address))
        .thenAnswer((_) async => balances);

    when(() => mockGetFeeEstimatesUseCase.call())
        .thenAnswer((_) async => feeEstimates);

    // Act
    final result = await useCase.call(address.address);

    // Assert
    expect(result.$1, balances);
    expect(result.$2, feeEstimates);
    expect(result.$1.first.assetInfo,
        assetInfo); // Verifying assetInfo is returned correctly
  });

  test('should throw FetchBalancesException when balance fetch fails',
      () async {
    // Arrange
    const address = Address(
      accountUuid: 'test-account-uuid',
      address: 'test-address',
      index: 0,
    );

    when(() => mockBalanceRepository.getBalancesForAddress(address.address))
        .thenThrow(FetchBalancesException('Balance error'));

    when(() => mockGetFeeEstimatesUseCase.call()).thenAnswer(
        (_) async => const FeeEstimates(fast: 10, medium: 5, slow: 2));

    // Act & Assert
    expect(
      () => useCase.call(address.address),
      throwsA(isA<FetchBalancesException>()),
    );
  });

  test('should throw FetchFeeEstimatesException when fee estimate fetch fails',
      () async {
    // Arrange
    const address = Address(
      accountUuid: 'test-account-uuid',
      address: 'test-address',
      index: 0,
    );

    const assetInfo = AssetInfo(
      assetLongname: "BTC_LONGNAME",
      divisible: true,
      description: "Bitcoin Description",
    );

    final balances = [
      Balance(
        address: address.address,
        asset: 'BTC',
        quantity: 1000,
        quantityNormalized: '0.00001000',
        assetInfo: assetInfo, // Adding assetInfo to the balance entity
      ),
    ];

    when(() => mockBalanceRepository.getBalancesForAddress(address.address))
        .thenAnswer((_) async => balances);

    when(() => mockGetFeeEstimatesUseCase.call())
        .thenThrow(FetchFeeEstimatesException('Fee estimate error'));

    // Act & Assert
    expect(
      () => useCase.call(address.address),
      throwsA(isA<FetchFeeEstimatesException>()),
    );
  });

  test('should throw generic Exception when an unexpected error occurs',
      () async {
    // Arrange
    const address = Address(
      accountUuid: 'test-account-uuid',
      address: 'test-address',
      index: 0,
    );

    when(() => mockBalanceRepository.getBalancesForAddress(address.address))
        .thenThrow(Exception('Unexpected error'));

    // Act & Assert
    expect(
      () => useCase.call(address.address),
      throwsA(isA<Exception>()),
    );
  });
}
