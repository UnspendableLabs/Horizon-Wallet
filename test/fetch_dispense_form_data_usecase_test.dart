import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/fetch_form_data.dart';

// Mock classes
class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

void main() {
  late FetchDispenseFormDataUseCase useCase;
  late MockGetFeeEstimatesUseCase mockGetFeeEstimatesUseCase;

  setUpAll(() {
    registerFallbackValue((1, 3, 6));
  });

  setUp(() {
    mockGetFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();
    useCase = FetchDispenseFormDataUseCase(
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

    const feeEstimates = FeeEstimates(fast: 10, medium: 5, slow: 2);

    when(() => mockGetFeeEstimatesUseCase.call())
        .thenAnswer((_) async => feeEstimates);

    // Act
    final result = await useCase.call(address.address);

    // Assert
    expect(result, feeEstimates);
  });

  test('should throw FetchFeeEstimatesException when fee estimate fetch fails',
      () async {
    // Arrange
    const address = Address(
      accountUuid: 'test-account-uuid',
      address: 'test-address',
      index: 0,
    );

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

    // Act & Assert
    expect(
      () => useCase.call(address.address),
      throwsA(isA<Exception>()),
    );
  });
}
