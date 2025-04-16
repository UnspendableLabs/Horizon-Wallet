import 'package:bloc_test/bloc_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/transactions/send/bloc/send_bloc.dart';
import 'package:horizon/presentation/screens/transactions/send/bloc/send_event.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/scaffolding.dart';

class MockComposeRepository extends Mock implements ComposeRepository {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockSignAndBroadcastTransactionUseCase extends Mock
    implements SignAndBroadcastTransactionUseCase<ComposeSendResponse> {}

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

class MockComposeTransactionUseCase extends Mock
    implements ComposeTransactionUseCase {}

class MockWriteLocalTransactionUseCase extends Mock
    implements WriteLocalTransactionUseCase {}

class MockLogger extends Mock implements Logger {}

class MockErrorService extends Mock implements ErrorService {}

class FakeMultiAddressBalance extends Fake implements MultiAddressBalance {}

class FakeMultiAddressBalanceEntry extends Fake
    implements MultiAddressBalanceEntry {}


class FakeAddress extends Fake implements Address {
  @override
  final String accountUuid = "test-account-uuid";
  @override
  final String address = "test-address";
  @override
  final int index = 0;
}

void main() {
  late SendBloc sendBloc;
  late MockComposeRepository mockComposeRepository;
  late MockAnalyticsService mockAnalyticsService;
  late MockBalanceRepository mockBalanceRepository;
  late MockSignAndBroadcastTransactionUseCase
      mockSignAndBroadcastTransactionUseCase;
  late MockGetFeeEstimatesUseCase mockGetFeeEstimatesUseCase;
  late MockComposeTransactionUseCase mockComposeTransactionUseCase;
  late MockWriteLocalTransactionUseCase mockWriteLocalTransactionUseCase;
  late MockLogger mockLogger;
  late MockErrorService mockErrorService;
  late String testAssetName = "ASSET_NAME";
  const mockFeeEstimates = FeeEstimates(fast: 5, medium: 3, slow: 1);
  late List<MultiAddressBalance> mockBalances;

  setUpAll(() {
    registerFallbackValue(FakeAddress().address);
    registerFallbackValue(FeeOption.Medium());
    registerFallbackValue(FakeMultiAddressBalance());
    registerFallbackValue(FakeMultiAddressBalanceEntry());
  });

  setUp(() {
    mockComposeRepository = MockComposeRepository();
    mockAnalyticsService = MockAnalyticsService();
    mockBalanceRepository = MockBalanceRepository();
    mockSignAndBroadcastTransactionUseCase =
        MockSignAndBroadcastTransactionUseCase();
    mockGetFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();
    mockComposeTransactionUseCase = MockComposeTransactionUseCase();
    mockWriteLocalTransactionUseCase = MockWriteLocalTransactionUseCase();
    mockLogger = MockLogger();
    mockErrorService = MockErrorService();
    sendBloc = SendBloc(
      composeRepository: mockComposeRepository,
      analyticsService: mockAnalyticsService,
      logger: mockLogger,
      balanceRepository: mockBalanceRepository,
      signAndBroadcastTransactionUseCase:
          mockSignAndBroadcastTransactionUseCase,
      getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
      composeTransactionUseCase: mockComposeTransactionUseCase,
      writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
    );

    GetIt.I.registerSingleton<ErrorService>(mockErrorService);
      mockBalances = [
        MultiAddressBalance(
          asset: 'BTC',
          assetLongname: 'Bitcoin',
          total: 100000000, // 1.00000000 BTC
          totalNormalized: '1.00000000',
          entries: [
            MultiAddressBalanceEntry(
              address: FakeAddress().address,
              quantity: 100000000,
              quantityNormalized: '1.00000000',
              utxo: null,
              utxoAddress: null,
            ),
          ],
          assetInfo: const AssetInfo(
            assetLongname: 'Bitcoin',
            description: 'Bitcoin',
            divisible: true,
            locked: true,
          ),
        ),
        MultiAddressBalance(
          asset: 'XCP',
          assetLongname: 'Counterparty',
          total: 50000000, // 0.50000000 XCP
          totalNormalized: '0.50000000',
          entries: [
            MultiAddressBalanceEntry(
              address: FakeAddress().address,
              quantity: 50000000,
              quantityNormalized: '0.50000000',
              utxo: null,
              utxoAddress: null,
            ),
          ],
          assetInfo: const AssetInfo(
            assetLongname: 'Counterparty',
            description: 'Counterparty',
            divisible: true,
            locked: true,
          ),
        ),
      ];
  });

  group(SendDependenciesRequested, () {
    blocTest<SendBloc, TransactionState<SendData, ComposeSendResponse>>(
      'emits loading and then success states when data is fetched successfully',
      build: () {
        when(() => mockBalanceRepository.getBalancesForAddressesAndAsset(
            any(), any(), any()))
            .thenAnswer((_) async => mockBalances.first);
        when(() => mockGetFeeEstimatesUseCase.call())
            .thenAnswer((_) async => mockFeeEstimates);
        return sendBloc;
      },
      act: (bloc) {
        bloc.add(SendDependenciesRequested(
            assetName: testAssetName, addresses: [FakeAddress().address]));
      },
      expect: () => [
        sendBloc.state.copyWith(
          formState: sendBloc.state.formState.copyWith(
            balancesState: const BalancesState.loading(),
            feeState: const FeeState.loading(),
            dataState: const TransactionDataState.loading(),
            feeOption: FeeOption.Medium(),
          ),
          composeState: const ComposeState.initial(),
          broadcastState: const BroadcastState.initial(),
        ),
        sendBloc.state.copyWith(
          formState: sendBloc.state.formState.copyWith(
            balancesState: BalancesState.success(mockBalances.first),
            feeState: const FeeState.success(mockFeeEstimates),
            dataState: TransactionDataState.success(SendData()),
            feeOption: FeeOption.Medium(),
          ),
          composeState: const ComposeState.initial(),
          broadcastState: const BroadcastState.initial(),
        ),
      ],
    );
  });
}
