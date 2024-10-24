import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/presentation/screens/compose_dispenser/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

void main() {
  late FetchDispenserFormDataUseCase useCase;
  late MockBalanceRepository mockBalanceRepository;
  late MockGetFeeEstimatesUseCase mockGetFeeEstimatesUseCase;

  setUpAll(() {
    registerFallbackValue((1, 3, 6));
  });

  setUp(() {
    mockBalanceRepository = MockBalanceRepository();
    mockGetFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();

    useCase = FetchDispenserFormDataUseCase(
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
      assetLongname: "ASSET_LONGNAME",
      divisible: true,
      description: "ASSET_DESCRIPTION",
    );

    final balances = [
      Balance(
        address: address.address,
        quantity: 1000,
        asset: 'ASSET',
        assetInfo: assetInfo,
        quantityNormalized: '0.00001000',
      ),
    ];

    const feeEstimates = FeeEstimates(fast: 10, medium: 5, slow: 2);

    when(() => mockBalanceRepository.getBalancesForAddress(address.address))
        .thenAnswer((_) async => balances);

    when(() => mockGetFeeEstimatesUseCase.call(targets: any(named: 'targets')))
        .thenAnswer((_) async => feeEstimates);

    // Act
    final result = await useCase.call(address);

    // Assert
    expect(result.$1, balances);
    expect(result.$2, feeEstimates);
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
        .thenThrow(Exception('Balance error'));

    when(() => mockGetFeeEstimatesUseCase.call(targets: any(named: 'targets')))
        .thenAnswer(
            (_) async => const FeeEstimates(fast: 10, medium: 5, slow: 2));

    // Act & Assert
    expect(
      () => useCase.call(address),
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
      assetLongname: "ASSET_LONGNAME",
      divisible: true,
      description: "ASSET_DESCRIPTION",
    );

    final balances = [
      Balance(
        address: address.address,
        quantity: 1000,
        asset: 'ASSET',
        assetInfo: assetInfo,
        quantityNormalized: '0.00001000',
      ),
    ];

    when(() => mockBalanceRepository.getBalancesForAddress(address.address))
        .thenAnswer((_) async => balances);

    when(() => mockGetFeeEstimatesUseCase.call(targets: any(named: 'targets')))
        .thenThrow(Exception('Fee estimate error'));

    // Act & Assert
    expect(
      () => useCase.call(address),
      throwsA(isA<FetchFeeEstimatesException>()),
    );
  });
}
