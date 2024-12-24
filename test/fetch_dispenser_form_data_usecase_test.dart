import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/domain/repositories/dispenser_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/presentation/screens/compose_dispenser/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockDispenserRepository extends Mock implements DispenserRepository {}

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

void main() {
  late FetchDispenserFormDataUseCase useCase;
  late MockBalanceRepository mockBalanceRepository;
  late MockGetFeeEstimatesUseCase mockGetFeeEstimatesUseCase;
  late MockDispenserRepository mockDispenserRepository;
  setUpAll(() {
    registerFallbackValue((1, 3, 6));
  });

  setUp(() {
    mockBalanceRepository = MockBalanceRepository();
    mockGetFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();
    mockDispenserRepository = MockDispenserRepository();
    useCase = FetchDispenserFormDataUseCase(
      balanceRepository: mockBalanceRepository,
      getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
      dispenserRepository: mockDispenserRepository,
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

    final dispensers = [
      Dispenser(
        asset: 'ASSET',
        assetInfo: assetInfo,
        txIndex: 0,
        txHash: '0x123',
        blockIndex: 0,
        source: 'source',
        giveQuantity: 1000,
        escrowQuantity: 1000,
        status: 0,
        giveQuantityNormalized: '0.00001000',
        escrowQuantityNormalized: '0.00001000',
        satoshirateNormalized: '0.00001000',
        origin: 'origin',
        dispenseCount: 0,
        confirmed: true,
        giveRemaining: 1000,
        giveRemainingNormalized: '0.00001000',
        satoshirate: 1000,
      ),
    ];

    const feeEstimates = FeeEstimates(fast: 10, medium: 5, slow: 2);

    when(() =>
            mockBalanceRepository.getBalancesForAddress(address.address, true))
        .thenAnswer((_) async => balances);

    when(() => mockGetFeeEstimatesUseCase.call())
        .thenAnswer((_) async => feeEstimates);

    when(() => mockDispenserRepository.getDispensersByAddress(address.address))
        .thenAnswer((_) => TaskEither.right(dispensers));

    // Act
    final result = await useCase.call(address.address);

    // Assert
    expect(result.$1, balances);
    expect(result.$2, feeEstimates);
    expect(result.$3, dispensers);
  });

  test('should throw FetchBalancesException when balance fetch fails',
      () async {
    // Arrange
    const address = Address(
      accountUuid: 'test-account-uuid',
      address: 'test-address',
      index: 0,
    );

    when(() =>
            mockBalanceRepository.getBalancesForAddress(address.address, true))
        .thenThrow(Exception('Balance error'));

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

    when(() =>
            mockBalanceRepository.getBalancesForAddress(address.address, true))
        .thenAnswer((_) async => balances);

    when(() => mockGetFeeEstimatesUseCase.call())
        .thenThrow(Exception('Fee estimate error'));

    // Act & Assert
    expect(
      () => useCase.call(address.address),
      throwsA(isA<FetchFeeEstimatesException>()),
    );
  });

  test('should throw FetchDispenserException when dispenser fetch fails',
      () async {
    // Arrange
    const address = Address(
      accountUuid: 'test-account-uuid',
      address: 'test-address',
      index: 0,
    );

    when(() =>
            mockBalanceRepository.getBalancesForAddress(address.address, true))
        .thenAnswer((_) async => []);

    when(() => mockGetFeeEstimatesUseCase.call()).thenAnswer(
        (_) async => const FeeEstimates(fast: 10, medium: 5, slow: 2));

    when(() => mockDispenserRepository.getDispensersByAddress(address.address))
        .thenThrow(Exception('Dispenser error'));

    // Act & Assert
    expect(
      () => useCase.call(address.address),
      throwsA(isA<FetchDispenserException>()),
    );
  });
}
