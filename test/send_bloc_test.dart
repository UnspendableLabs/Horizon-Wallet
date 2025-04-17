import 'package:bloc_test/bloc_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
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
import 'package:horizon/presentation/screens/compose_dispenser/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/transactions/send/bloc/send_bloc.dart';
import 'package:horizon/presentation/screens/transactions/send/bloc/send_event.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/scaffolding.dart';
import 'package:test/test.dart' show isA, predicate;

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

class MockComposeSendParams extends Mock implements ComposeSendParams {}

class MockComposeSendResponseParams extends Mock
    implements ComposeSendResponseParams {
  @override
  String get source => "source-address";
  @override
  String get destination => "destination-address";
  @override
  String get asset => "ASSET_NAME";
  @override
  int get quantity => 100000000;
  @override
  bool get useEnhancedSend => false;
  @override
  AssetInfo get assetInfo => const AssetInfo(
        assetLongname: 'Bitcoin',
        description: 'Bitcoin',
        divisible: true,
        locked: true,
      );
  @override
  String get quantityNormalized => "1.00000000";
}

class MockComposeSendResponse extends Mock implements ComposeSendResponse {}

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
  late MockComposeSendResponse mockComposeSendResponse =
      MockComposeSendResponse();

  final composeTransactionParams = SendTransactionParams(
    destinationAddress: 'destination-address',
    asset: 'ASSET_NAME',
    quantity: 100000000,
  );

  setUpAll(() {
    registerFallbackValue(FakeAddress().address);
    registerFallbackValue(FeeOption.Medium());
    registerFallbackValue(FakeMultiAddressBalance());
    registerFallbackValue(FakeMultiAddressBalanceEntry());
    registerFallbackValue(SendTransactionComposed(
        params: composeTransactionParams, sourceAddress: 'source-address'));
    registerFallbackValue(mockComposeSendResponse);
    registerFallbackValue(MockComposeSendParams());
    registerFallbackValue(Password('test-password'));
    registerFallbackValue(MockComposeSendResponseParams());
    registerFallbackValue(SendTransactionBroadcasted(
      decryptionStrategy: Password('test-password'),
    ));
  });

  tearDown(() {
    sendBloc.close();
    GetIt.I.reset();
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
            any(), any(), any())).thenAnswer((_) async => mockBalances.first);
        when(() => mockGetFeeEstimatesUseCase.call())
            .thenAnswer((_) async => mockFeeEstimates);
        return sendBloc;
      },
      act: (bloc) {
        bloc.add(SendDependenciesRequested(
            assetName: testAssetName, addresses: [FakeAddress().address]));
      },
      expect: () => [
        // Loading state
        predicate<TransactionState<SendData, ComposeSendResponse>>((state) =>
            state.formState.balancesState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            ) &&
            state.formState.feeState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            ) &&
            state.formState.dataState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            ) &&
            state.formState.feeOption is FeeOption.Medium &&
            state.composeState.maybeWhen(
              initial: () => true,
              orElse: () => false,
            ) &&
            state.broadcastState.maybeWhen(
              initial: () => true,
              orElse: () => false,
            )),
        // Success state
        predicate<TransactionState<SendData, ComposeSendResponse>>((state) =>
            state.formState.balancesState.maybeWhen(
              success: (balances) => true,
              orElse: () => false,
            ) &&
            state.formState.feeState.maybeWhen(
              success: (feeEstimates) => true,
              orElse: () => false,
            ) &&
            state.formState.dataState.maybeWhen(
              success: (data) => true,
              orElse: () => false,
            ) &&
            state.formState.feeOption is FeeOption.Medium &&
            state.composeState.maybeWhen(
              initial: () => true,
              orElse: () => false,
            ) &&
            state.broadcastState.maybeWhen(
              initial: () => true,
              orElse: () => false,
            )),
      ],
    );

    blocTest<SendBloc, TransactionState<SendData, ComposeSendResponse>>(
      'emits error state when fetching balances fails',
      build: () {
        when(() => mockBalanceRepository.getBalancesForAddressesAndAsset(
                any(), any(), any()))
            .thenThrow(FetchBalancesException('Failed to fetch balances'));
        return sendBloc;
      },
      act: (bloc) {
        bloc.add(SendDependenciesRequested(
            assetName: testAssetName, addresses: [FakeAddress().address]));
      },
      expect: () => [
        // Loading state
        predicate<TransactionState<SendData, ComposeSendResponse>>((state) =>
            state.formState.balancesState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            ) &&
            state.formState.feeState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            ) &&
            state.formState.dataState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            ) &&
            state.formState.feeOption is FeeOption.Medium &&
            state.composeState.maybeWhen(
              initial: () => true,
              orElse: () => false,
            ) &&
            state.broadcastState.maybeWhen(
              initial: () => true,
              orElse: () => false,
            )),

        // Error state
        predicate<TransactionState<SendData, ComposeSendResponse>>((state) =>
            state.formState.balancesState.maybeWhen(
              error: (error) =>
                  error == "FetchBalancesException: Failed to fetch balances",
              orElse: () => false,
            ) &&
            state.formState.feeState.maybeWhen(
              error: (error) =>
                  error ==
                  FetchBalancesException('Failed to fetch balances').toString(),
              orElse: () => false,
            ) &&
            state.formState.dataState.maybeWhen(
              error: (error) =>
                  error ==
                  FetchBalancesException('Failed to fetch balances').toString(),
              orElse: () => false,
            ) &&
            state.formState.feeOption is FeeOption.Medium &&
            state.composeState.maybeWhen(
              initial: () => true,
              orElse: () => false,
            ) &&
            state.broadcastState.maybeWhen(
              initial: () => true,
              orElse: () => false,
            )),
      ],
    );

    blocTest<SendBloc, TransactionState<SendData, ComposeSendResponse>>(
      'emits error state when fetching fee estimates fails',
      build: () {
        when(() => mockGetFeeEstimatesUseCase.call()).thenThrow(
            FetchFeeEstimatesException('Failed to fetch fee estimates'));
        when(() => mockBalanceRepository.getBalancesForAddressesAndAsset(
            any(), any(), any())).thenAnswer((_) async => mockBalances.first);
        return sendBloc;
      },
      act: (bloc) {
        bloc.add(SendDependenciesRequested(
            assetName: testAssetName, addresses: [FakeAddress().address]));
      },
      expect: () => [
        predicate<TransactionState<SendData, ComposeSendResponse>>((state) =>
            state.formState.balancesState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            ) &&
            state.formState.feeState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            ) &&
            state.formState.dataState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            ) &&
            state.formState.feeOption is FeeOption.Medium &&
            state.composeState.maybeWhen(
              initial: () => true,
              orElse: () => false,
            ) &&
            state.broadcastState.maybeWhen(
              initial: () => true,
              orElse: () => false,
            )),
        predicate<TransactionState<SendData, ComposeSendResponse>>((state) =>
            state.formState.balancesState.maybeWhen(
              error: (error) =>
                  error ==
                  FetchFeeEstimatesException('Failed to fetch fee estimates')
                      .toString(),
              orElse: () => false,
            ) &&
            state.formState.feeState.maybeWhen(
              error: (error) =>
                  error ==
                  FetchFeeEstimatesException('Failed to fetch fee estimates')
                      .toString(),
              orElse: () => false,
            ) &&
            state.formState.dataState.maybeWhen(
              error: (error) =>
                  error ==
                  FetchFeeEstimatesException('Failed to fetch fee estimates')
                      .toString(),
              orElse: () => false,
            ) &&
            state.formState.feeOption is FeeOption.Medium &&
            state.composeState.maybeWhen(
              initial: () => true,
              orElse: () => false,
            ) &&
            state.broadcastState.maybeWhen(
              initial: () => true,
              orElse: () => false,
            )),
      ],
    );
  });

  group('ComposeTransactionEvent', () {
    blocTest<SendBloc, TransactionState<SendData, ComposeSendResponse>>(
        'emits SubmitComposingTransaction when transaction composition succeeds',
        build: () {
          when(() => mockComposeTransactionUseCase
                  .call<ComposeSendParams, ComposeSendResponse>(
                feeRate: any(named: 'feeRate'),
                source: any(named: 'source'),
                composeFn: any(named: 'composeFn'),
                params: any(named: 'params'),
              )).thenAnswer((_) async => mockComposeSendResponse);
          when(() => mockComposeSendResponse.btcFee).thenReturn(250);
          when(() => mockComposeSendResponse.signedTxEstimatedSize)
              .thenReturn(SignedTxEstimatedSize(
            virtualSize: 120,
            adjustedVirtualSize: 155,
            sigopsCount: 1,
          ));
          return sendBloc;
        },
        seed: () => TransactionState(
            formState: TransactionFormState(
              balancesState: BalancesState.success(mockBalances.first),
              feeState: const FeeState.success(mockFeeEstimates),
              feeOption: FeeOption.Medium(),
              dataState: const TransactionDataState.initial(),
            ),
            composeState: const ComposeStateInitial(),
            broadcastState: const BroadcastState.initial()),
        act: (bloc) => bloc.add(SendTransactionComposed(
              params: composeTransactionParams,
              sourceAddress: 'source-address',
            )),
        expect: () => [
              predicate<TransactionState<SendData, ComposeSendResponse>>(
                  (state) =>
                      state.formState.balancesState.maybeWhen(
                        success: (balances) => true,
                        orElse: () => false,
                      ) &&
                      state.formState.feeOption is FeeOption.Medium &&
                      state.formState.feeState.maybeWhen(
                        success: (feeEstimates) => true,
                        orElse: () => false,
                      ) &&
                      state.composeState.maybeWhen(
                        loading: () => true,
                        orElse: () => false,
                      ) &&
                      state.broadcastState.maybeWhen(
                        initial: () => true,
                        orElse: () => false,
                      )),
              predicate<TransactionState<SendData, ComposeSendResponse>>(
                  (state) =>
                      state.formState.balancesState.maybeWhen(
                        success: (balances) => true,
                        orElse: () => false,
                      ) &&
                      state.formState.feeOption is FeeOption.Medium &&
                      state.formState.feeState.maybeWhen(
                        success: (feeEstimates) => true,
                        orElse: () => false,
                      ) &&
                      state.composeState.maybeWhen(
                        success: (composeSendResponse) =>
                            composeSendResponse
                                    .signedTxEstimatedSize.virtualSize ==
                                120 &&
                            composeSendResponse.signedTxEstimatedSize
                                    .adjustedVirtualSize ==
                                155 &&
                            composeSendResponse.btcFee == 250,
                        orElse: () => false,
                      ) &&
                      state.broadcastState.maybeWhen(
                        initial: () => true,
                        orElse: () => false,
                      )),
            ]);

    blocTest<SendBloc, TransactionState<SendData, ComposeSendResponse>>(
        'emits SubmitComposingTransaction when transaction composition succeeds ( Custom Fee )',
        build: () {
          when(() => mockComposeTransactionUseCase
                  .call<ComposeSendParams, ComposeSendResponse>(
                feeRate: any(named: 'feeRate'),
                source: any(named: 'source'),
                composeFn: any(named: 'composeFn'),
                params: any(named: 'params'),
              )).thenAnswer((_) async => mockComposeSendResponse);
          when(() => mockComposeSendResponse.btcFee).thenReturn(250);

          return sendBloc;
        },
        seed: () => TransactionState(
            formState: TransactionFormState(
              balancesState: BalancesState.success(mockBalances.first),
              feeState: const FeeState.success(mockFeeEstimates),
              feeOption: FeeOption.Custom(10),
              dataState: const TransactionDataState.initial(),
            ),
            composeState: const ComposeStateInitial(),
            broadcastState: const BroadcastState.initial()),
        act: (bloc) => bloc.add(SendTransactionComposed(
              params: composeTransactionParams,
              sourceAddress: 'source-address',
            )),
        expect: () => [
              predicate<TransactionState<SendData, ComposeSendResponse>>(
                  (state) =>
                      state.formState.balancesState.maybeWhen(
                        success: (balances) => true,
                        orElse: () => false,
                      ) &&
                      (state.formState.feeOption as FeeOption.Custom).fee ==
                          10 &&
                      state.formState.feeState.maybeWhen(
                        success: (feeEstimates) => true,
                        orElse: () => false,
                      ) &&
                      state.composeState.maybeWhen(
                        loading: () => true,
                        orElse: () => false,
                      ) &&
                      state.broadcastState.maybeWhen(
                        initial: () => true,
                        orElse: () => false,
                      )),
              predicate<TransactionState<SendData, ComposeSendResponse>>(
                  (state) =>
                      state.formState.balancesState.maybeWhen(
                        success: (balances) => true,
                        orElse: () => false,
                      ) &&
                      (state.formState.feeOption as FeeOption.Custom).fee ==
                          10 &&
                      state.formState.feeState.maybeWhen(
                        success: (feeEstimates) => true,
                        orElse: () => false,
                      ) &&
                      state.composeState.maybeWhen(
                        success: (composeSendResponse) => true,
                        orElse: () => false,
                      ) &&
                      state.broadcastState.maybeWhen(
                        initial: () => true,
                        orElse: () => false,
                      )),
            ]);

    blocTest<SendBloc, TransactionState<SendData, ComposeSendResponse>>(
      'emits SubmitComposingTransaction when transaction composition fails',
      build: () {
        when(
            () => mockComposeTransactionUseCase
                    .call<ComposeSendParams, ComposeSendResponse>(
                  feeRate: any(named: 'feeRate'),
                  source: any(named: 'source'),
                  composeFn: any(named: 'composeFn'),
                  params: any(named: 'params'),
                )).thenThrow(
            ComposeTransactionException('Compose error', StackTrace.current));
        return sendBloc;
      },
      seed: () => TransactionState(
          formState: TransactionFormState(
            balancesState: BalancesState.success(mockBalances.first),
            feeState: const FeeState.success(mockFeeEstimates),
            feeOption: FeeOption.Medium(),
            dataState: const TransactionDataState.initial(),
          ),
          composeState: const ComposeStateInitial(),
          broadcastState: const BroadcastState.initial()),
      act: (bloc) => bloc.add(SendTransactionComposed(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        predicate<TransactionState<SendData, ComposeSendResponse>>((state) =>
            state.formState.balancesState.maybeWhen(
              success: (balances) => true,
              orElse: () => false,
            ) &&
            state.formState.feeOption is FeeOption.Medium &&
            state.formState.feeState.maybeWhen(
              success: (feeEstimates) => true,
              orElse: () => false,
            ) &&
            state.composeState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            ) &&
            state.broadcastState.maybeWhen(
              initial: () => true,
              orElse: () => false,
            )),
        predicate<TransactionState<SendData, ComposeSendResponse>>((state) =>
            state.formState.balancesState.maybeWhen(
              success: (balances) => true,
              orElse: () => false,
            ) &&
            state.formState.feeOption is FeeOption.Medium &&
            state.formState.feeState.maybeWhen(
              success: (feeEstimates) => true,
              orElse: () => false,
            ) &&
            state.composeState.maybeWhen(
              error: (error) => error == 'Compose error',
              orElse: () => false,
            ) &&
            state.broadcastState.maybeWhen(
              initial: () => true,
              orElse: () => false,
            )),
      ],
    );
  });

  group(SendTransactionBroadcasted, () {
    const txHex = 'transaction-hex';
    const txHash = 'transaction-hash';
    final mockComposeSendResponseParams = MockComposeSendResponseParams();

    blocTest<SendBloc, TransactionState<SendData, ComposeSendResponse>>(
      "emits SubmitSuccess when transaction is signed and broadcasted successfully",
      build: () {
        when(() => mockSignAndBroadcastTransactionUseCase.call(
              source: "source-address",
              rawtransaction: txHex,
              decryptionStrategy: Password('test-password'),
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError'),
            )).thenAnswer((invocation) async {
          final onSuccess =
              invocation.namedArguments[const Symbol('onSuccess')] as Function;
          onSuccess(txHex, txHash);
        });

        // Mock other dependencies
        when(() => mockWriteLocalTransactionUseCase.call(txHex, txHash))
            .thenAnswer((_) async {});
        when(() => mockAnalyticsService.trackAnonymousEvent(
              any(),
              properties: any(named: 'properties'),
            )).thenAnswer((_) async {});

        when(() => mockComposeSendResponse.params)
            .thenReturn(mockComposeSendResponseParams);

        when(() => mockComposeSendResponse.rawtransaction).thenReturn(txHex);

        return sendBloc;
      },
      seed: () => TransactionState(
          formState: TransactionFormState(
            balancesState: BalancesState.success(mockBalances.first),
            feeState: const FeeState.success(mockFeeEstimates),
            feeOption: FeeOption.Medium(),
            dataState: const TransactionDataState.initial(),
          ),
          composeState: ComposeState.success(mockComposeSendResponse),
          broadcastState: const BroadcastState.initial()),
      act: (bloc) => bloc.add(SendTransactionBroadcasted(
        decryptionStrategy: Password('test-password'),
      )),
      wait: const Duration(milliseconds: 10),
      expect: () => [
        predicate<TransactionState<SendData, ComposeSendResponse>>((state) =>
            state.formState.balancesState.maybeWhen(
              success: (balances) => true,
              orElse: () => false,
            ) &&
            state.formState.feeOption is FeeOption.Medium &&
            state.formState.feeState.maybeWhen(
              success: (feeEstimates) => true,
              orElse: () => false,
            ) &&
            state.formState.dataState.maybeWhen(
              initial: () => true,
              orElse: () => false,
            ) &&
            state.composeState.maybeWhen(
              success: (composeSendResponse) => true,
              orElse: () => false,
            ) &&
            state.broadcastState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            )),
        predicate<TransactionState<SendData, ComposeSendResponse>>((state) =>
            state.formState.balancesState.maybeWhen(
              success: (balances) => true,
              orElse: () => false,
            ) &&
            state.formState.feeOption is FeeOption.Medium &&
            state.formState.feeState.maybeWhen(
              success: (feeEstimates) => true,
              orElse: () => false,
            ) &&
            state.formState.dataState.maybeWhen(
              initial: () => true,
              orElse: () => false,
            ) &&
            state.composeState.maybeWhen(
              success: (composeSendResponse) => true,
              orElse: () => false,
            ) &&
            state.broadcastState.maybeWhen(
              success: (broadcastState) => true,
              orElse: () => false,
            )),
      ],
    );
  });
}
