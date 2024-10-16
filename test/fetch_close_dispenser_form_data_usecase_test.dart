import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/domain/repositories/dispenser_repository.dart';
import 'package:horizon/presentation/screens/close_dispenser/usecase/fetch_form_data.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

class MockDispenserRepository extends Mock implements DispenserRepository {}

void main() {
  late FetchCloseDispenserFormDataUseCase useCase;
  late MockGetFeeEstimatesUseCase mockGetFeeEstimatesUseCase;
  late MockDispenserRepository mockDispenserRepository;
  setUpAll(() {
    registerFallbackValue((1, 3, 6));
  });

  setUp(() {
    mockGetFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();
    mockDispenserRepository = MockDispenserRepository();
    useCase = FetchCloseDispenserFormDataUseCase(
      dispenserRepository: mockDispenserRepository,
      getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
    );
  });

  test('should return balances and fee estimates when both fetches succeed',
      () async {
    // Arrange
    final dispenser = Dispenser(
      assetName: 'ASSET',
      openAddress: 'OPEN_ADDRESS',
      giveQuantity: 1000,
      escrowQuantity: 1000,
      mainchainrate: 1000,
      status: 0,
    );

    const feeEstimates = FeeEstimates(fast: 10, medium: 5, slow: 2);

    when(() => mockGetFeeEstimatesUseCase.call(targets: any(named: 'targets')))
        .thenAnswer((_) async => feeEstimates);

    when(() => mockDispenserRepository.getDispenserByAddress(
        dispenser.openAddress)).thenAnswer((_) async => [dispenser]);

    // Act
    final result = await useCase.call(Address(
        address: dispenser.openAddress,
        index: 0,
        accountUuid: 'test-account-uuid'));

    // Assert
    expect(result.$1, feeEstimates);
    expect(result.$2, [dispenser]);
  });

  test('should throw FetchDispenserException when dispenser fetch fails',
      () async {
    // Arrange
    const address = Address(
      accountUuid: 'test-account-uuid',
      address: 'test-address',
      index: 0,
    );

    when(() => mockDispenserRepository.getDispenserByAddress(address.address))
        .thenThrow(Exception('Dispenser error'));

    when(() => mockGetFeeEstimatesUseCase.call(targets: any(named: 'targets')))
        .thenAnswer(
            (_) async => const FeeEstimates(fast: 10, medium: 5, slow: 2));

    // Act & Assert
    expect(
      () => useCase.call(address),
      throwsA(isA<FetchDispenserException>()),
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

    when(() => mockDispenserRepository.getDispenserByAddress(address.address))
        .thenAnswer((_) async => []);

    when(() => mockGetFeeEstimatesUseCase.call(targets: any(named: 'targets')))
        .thenThrow(Exception('Fee estimate error'));

    // Act & Assert
    expect(
      () => useCase.call(address),
      throwsA(isA<FetchFeeEstimatesException>()),
    );
  });
}
