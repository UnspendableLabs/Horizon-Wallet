import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/domain/repositories/dispenser_repository.dart';
import 'package:horizon/presentation/screens/close_dispenser/usecase/fetch_form_data.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import "package:fpdart/fpdart.dart";

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

class MockDispenserRepository extends Mock implements DispenserRepository {}

class FakeDispenser extends Fake implements Dispenser {
  final String _asset;
  final int _giveQuantity;
  final int _satoshirate;
  // final int _giveRemaining;
  // final AssetInfo _assetInfo;
  final String _source;
  final int _escrowQuantity;
  final int _status;

  FakeDispenser({
    required String asset,
    required int giveQuantity,
    required int satoshirate,
    // required int giveRemaining,
    // required AssetInfo assetInfo,
    required String source,
    required int escrowQuantity,
    required int status,
  })  : _asset = asset,
        _giveQuantity = giveQuantity,
        _satoshirate = satoshirate,
        // _giveRemaining = giveRemaining,
        // _assetInfo = assetInfo,
        _source = source,
        _escrowQuantity = escrowQuantity,
        _status = status;

  @override
  String get asset => _asset;

  @override
  int get giveQuantity => _giveQuantity;

  @override
  int get satoshirate => _satoshirate;

  // @override
  // int get giveRemaining => _giveRemaining;
  // //
  // @override
  // AssetInfo get assetInfo => _assetInfo;

  @override
  String get source => _source;

  @override
  int get escrowQuantity => _escrowQuantity;

  @override
  int get status => _status;
}

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
    final dispenser = FakeDispenser(
      asset: 'ASSET',
      source: 'OPEN_ADDRESS',
      giveQuantity: 1000,
      escrowQuantity: 1000,
      satoshirate: 1000,
      status: 0,
    );

    const feeEstimates = FeeEstimates(fast: 10, medium: 5, slow: 2);

    when(() => mockGetFeeEstimatesUseCase.call())
        .thenAnswer((_) async => feeEstimates);

    when(() => mockDispenserRepository.getDispensersByAddress(dispenser.source))
        .thenAnswer((_) => TaskEither.right([dispenser]));

    // Act
    final result = await useCase.call(dispenser.source);

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

    when(() => mockDispenserRepository.getDispensersByAddress(address.address))
        .thenThrow(Exception('Dispenser error'));

    when(() => mockGetFeeEstimatesUseCase.call()).thenAnswer(
        (_) async => const FeeEstimates(fast: 10, medium: 5, slow: 2));

    // Act & Assert
    expect(
      () => useCase.call(address.address),
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

    when(() => mockDispenserRepository.getDispensersByAddress(address.address))
        .thenAnswer((_) => TaskEither.right([]));

    when(() => mockGetFeeEstimatesUseCase.call())
        .thenThrow(Exception('Fee estimate error'));

    // Act & Assert
    expect(
      () => useCase.call(address.address),
      throwsA(isA<FetchFeeEstimatesException>()),
    );
  });
}
