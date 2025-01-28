import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/close_dispenser/bloc/close_dispenser_bloc.dart';
import 'package:horizon/presentation/screens/close_dispenser/bloc/close_dispenser_state.dart';
import 'package:horizon/presentation/screens/close_dispenser/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/compose_dispenser/bloc/compose_dispenser_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/core/logging/logger.dart';


class MockInMemoryKeyRepository extends Mock implements InMemoryKeyRepository {}

class MockLogger extends Mock implements Logger {}

class MockComposeRepository extends Mock implements ComposeRepository {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockFetchCloseDispenserFormDataUseCase extends Mock
    implements FetchCloseDispenserFormDataUseCase {}

class MockComposeTransactionUseCase extends Mock
    implements ComposeTransactionUseCase {}

class MockSignAndBroadcastTransactionUseCase extends Mock
    implements SignAndBroadcastTransactionUseCase {}

class MockWriteLocalTransactionUseCase extends Mock
    implements WriteLocalTransactionUseCase {}

class MockComposeDispenserResponseVerbose extends Mock
    implements ComposeDispenserResponseVerbose {}

class MockComposeDispenserResponseVerboseParams extends Mock
    implements ComposeDispenserResponseVerboseParams {}

class MockBalance extends Mock implements Balance {}

class MockComposeDispenserEventParams extends Mock
    implements ComposeDispenserEventParams {}

class MockErrorService extends Mock implements ErrorService {}

class FakeAddress extends Fake implements Address {
  @override
  final String accountUuid = "test-account-uuid";
  @override
  final String address = "test-address";
  @override
  final int index = 0;
}

class FakeUtxo extends Fake implements Utxo {}

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

class FakeVirtualSize extends Fake implements VirtualSize {
  @override
  final int virtualSize;
  @override
  final int adjustedVirtualSize;

  FakeVirtualSize(
      {required this.virtualSize, required this.adjustedVirtualSize});
}

void main() {
  late CloseDispenserBloc closeDispenserBloc;
  late MockComposeRepository mockComposeRepository;
  late MockAnalyticsService mockAnalyticsService;
  late MockFetchCloseDispenserFormDataUseCase
      mockFetchCloseDispenserFormDataUseCase;
  late MockComposeTransactionUseCase mockComposeTransactionUseCase;
  late MockSignAndBroadcastTransactionUseCase
      mockSignAndBroadcastTransactionUseCase;
  late MockWriteLocalTransactionUseCase mockWriteLocalTransactionUseCase;
  late MockErrorService mockErrorService;

  const mockFeeEstimates = FeeEstimates(fast: 5, medium: 3, slow: 1);
  final mockDispenser = FakeDispenser(
    asset: 'ASSET_NAME',
    source: 'test-address',
    giveQuantity: 1000,
    escrowQuantity: 500,
    satoshirate: 1,
    status: 0,
  );
  final mockAddress = FakeAddress().address;
  final mockComposeDispenserResponseVerbose =
      MockComposeDispenserResponseVerbose();
  final composeTransactionParams = ComposeDispenserEventParams(
    asset: 'ASSET_NAME',
    giveQuantity: 1000,
    escrowQuantity: 500,
    mainchainrate: 1,
    status: 0,
  );

  final composeDispenserParams = ComposeDispenserParams(
      asset: 'ASSET_NAME',
      giveQuantity: 1000,
      escrowQuantity: 500,
      mainchainrate: 1,
      source: "test-address",
      status: 10);

  final List<Utxo> utxos = [FakeUtxo()];

  setUpAll(() {
    registerFallbackValue(FakeAddress().address);
    registerFallbackValue(composeTransactionParams);
    registerFallbackValue(utxos);
    registerFallbackValue(FeeOption.Medium());
    registerFallbackValue(FormSubmitted(
      params: composeTransactionParams,
      sourceAddress: 'source-address',
    ));
    registerFallbackValue(SignAndBroadcastFormSubmitted(
      password: 'password',
    ));
    registerFallbackValue(composeDispenserParams);
    // Register the mock classes
    registerFallbackValue(MockComposeDispenserResponseVerboseParams());
  });
  setUp(() {
    mockComposeRepository = MockComposeRepository();
    mockAnalyticsService = MockAnalyticsService();
    mockFetchCloseDispenserFormDataUseCase =
        MockFetchCloseDispenserFormDataUseCase();
    mockComposeTransactionUseCase = MockComposeTransactionUseCase();
    mockSignAndBroadcastTransactionUseCase =
        MockSignAndBroadcastTransactionUseCase();
    mockWriteLocalTransactionUseCase = MockWriteLocalTransactionUseCase();
    mockErrorService = MockErrorService();

    // Register the ErrorService mock with GetIt
    GetIt.I.registerSingleton<ErrorService>(mockErrorService);

    closeDispenserBloc = CloseDispenserBloc(
      passwordRequired: true,
      inMemoryKeyRepository: MockInMemoryKeyRepository(),
      logger: MockLogger(),
      fetchCloseDispenserFormDataUseCase:
          mockFetchCloseDispenserFormDataUseCase,
      composeTransactionUseCase: mockComposeTransactionUseCase,
      composeRepository: mockComposeRepository,
      analyticsService: mockAnalyticsService,
      signAndBroadcastTransactionUseCase:
          mockSignAndBroadcastTransactionUseCase,
      writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
    );
  });

  tearDown(() {
    closeDispenserBloc.close();
    // Reset GetIt instance after each test
    GetIt.I.reset();
  });

  group(AsyncFormDependenciesRequested, () {
    blocTest<CloseDispenserBloc, CloseDispenserState>(
      'emits loading and then success states when data is fetched successfully',
      build: () {
        when(() => mockFetchCloseDispenserFormDataUseCase.call(any()))
            .thenAnswer((_) async => (mockFeeEstimates, [mockDispenser]));
        return closeDispenserBloc;
      },
      act: (bloc) {
        bloc.add(AsyncFormDependenciesRequested(currentAddress: mockAddress));
      },
      expect: () => [
        closeDispenserBloc.state.copyWith(
          feeState: const FeeState.loading(),
          balancesState: const BalancesState.loading(),
          dispensersState: const DispenserState.loading(),
          submitState: const FormStep(),
        ),
        closeDispenserBloc.state.copyWith(
          feeState: const FeeState.success(mockFeeEstimates),
          balancesState: const BalancesState.success([]),
          dispensersState: DispenserState.success([mockDispenser]),
        ),
      ],
    );

    blocTest<CloseDispenserBloc, CloseDispenserState>(
      'emits error state when fetching dispensers fails',
      build: () {
        when(() => mockFetchCloseDispenserFormDataUseCase.call(any()))
            .thenThrow(FetchDispenserException('Failed to fetch dispensers'));
        return closeDispenserBloc;
      },
      act: (bloc) {
        bloc.add(AsyncFormDependenciesRequested(currentAddress: mockAddress));
      },
      expect: () => [
        closeDispenserBloc.state.copyWith(
          dispensersState: const DispenserState.loading(),
          submitState: const FormStep(),
        ),
        closeDispenserBloc.state.copyWith(
          dispensersState:
              const DispenserState.error('Failed to fetch dispensers'),
        ),
      ],
    );

    blocTest<CloseDispenserBloc, CloseDispenserState>(
      'emits error state when fetching fee estimates fails',
      build: () {
        when(() => mockFetchCloseDispenserFormDataUseCase.call(any()))
            .thenThrow(
                FetchFeeEstimatesException('Failed to fetch fee estimates'));
        return closeDispenserBloc;
      },
      act: (bloc) {
        bloc.add(AsyncFormDependenciesRequested(currentAddress: mockAddress));
      },
      expect: () => [
        closeDispenserBloc.state.copyWith(
          feeState: const FeeState.loading(),
          submitState: const FormStep(),
        ),
        closeDispenserBloc.state.copyWith(
          feeState: const FeeState.error('Failed to fetch fee estimates'),
        ),
      ],
    );
    blocTest<CloseDispenserBloc, CloseDispenserState>(
      'emits error state when unexpected error occurs',
      build: () {
        when(() => mockFetchCloseDispenserFormDataUseCase.call(any()))
            .thenThrow(Exception('Unexpected'));
        return closeDispenserBloc;
      },
      act: (bloc) {
        bloc.add(AsyncFormDependenciesRequested(currentAddress: mockAddress));
      },
      expect: () => [
        closeDispenserBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          dispensersState: const DispenserState.loading(),
          submitState: const FormStep(),
        ),
        closeDispenserBloc.state.copyWith(
          feeState: const FeeState.error(
              'An unexpected error occurred: Exception: Unexpected'),
          dispensersState: const DispenserState.error(
              'An unexpected error occurred: Exception: Unexpected'),
        ),
      ],
    );
  });
  group('ComposeTransactionEvent', () {
    blocTest<CloseDispenserBloc, CloseDispenserState>;

    blocTest<CloseDispenserBloc, CloseDispenserState>(
      'emits SubmitComposingTransaction when transaction composition succeeds',
      build: () {
        when(() => mockComposeTransactionUseCase
                .call<ComposeDispenserParams, ComposeDispenserResponseVerbose>(
              feeRate: any(named: 'feeRate'),
              source: any(named: 'source'),
              composeFn: any(named: 'composeFn'),
              params: any(named: 'params'),
            )).thenAnswer((_) async => mockComposeDispenserResponseVerbose);

        when(() => mockComposeDispenserResponseVerbose.btcFee).thenReturn(250);
        when(() => mockComposeDispenserResponseVerbose.signedTxEstimatedSize)
            .thenReturn(SignedTxEstimatedSize(
          virtualSize: 120,
          adjustedVirtualSize: 155,
          sigopsCount: 1,
        ));

        return closeDispenserBloc;
      },
      seed: () => closeDispenserBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Medium(),
      ),
      act: (bloc) => bloc.add(FormSubmitted(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<FormStep>().having((s) => s.loading, 'loading', true),
        ),
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<ReviewStep<ComposeDispenserResponseVerbose, void>>()
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDispenserResponseVerbose)
              .having((s) => s.fee, 'fee', 250)
              .having((s) => s.feeRate, 'feeRate', 3)
              .having((s) => s.virtualSize, 'virtualSize', 120)
              .having((s) => s.adjustedVirtualSize, 'adjustedVirtualSize', 155),
        ),
      ],
    );

    blocTest<CloseDispenserBloc, CloseDispenserState>(
      'emits SubmitComposingTransaction when transaction composition succeeds ( Custom Fee )',
      build: () {
        when(() => mockComposeTransactionUseCase
                .call<ComposeDispenserParams, ComposeDispenserResponseVerbose>(
              feeRate: any(named: 'feeRate'),
              source: any(named: 'source'),
              composeFn: any(named: 'composeFn'),
              params: any(named: 'params'),
            )).thenAnswer((_) async => mockComposeDispenserResponseVerbose);

        when(() => mockComposeDispenserResponseVerbose.btcFee).thenReturn(250);

        return closeDispenserBloc;
      },
      seed: () => closeDispenserBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Custom(10),
      ),
      act: (bloc) => bloc.add(FormSubmitted(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<FormStep>().having((s) => s.loading, 'loading', true),
        ),
        isA<CloseDispenserState>().having(
            (state) => state.submitState,
            'submitState',
            isA<ReviewStep<ComposeDispenserResponseVerbose, void>>()
                .having((s) => s.composeTransaction, 'composeTransaction',
                    mockComposeDispenserResponseVerbose)
                .having((s) => s.fee, 'fee', 250)
                .having((s) => s.feeRate, 'feeRate', 10) // custom ,
            ),
      ],
    );

    blocTest<CloseDispenserBloc, CloseDispenserState>(
      'emits SubmitInitial with error when transaction composition fails',
      build: () {
        when(
            () => mockComposeTransactionUseCase.call<ComposeDispenserParams,
                    ComposeDispenserResponseVerbose>(
                  feeRate: any(named: 'feeRate'),
                  source: any(named: 'source'),
                  composeFn: any(named: 'composeFn'),
                  params: any(named: 'params'),
                )).thenThrow(
            ComposeTransactionException('Compose error', StackTrace.current));

        return closeDispenserBloc;
      },
      seed: () => closeDispenserBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Medium(),
      ),
      act: (bloc) => bloc.add(FormSubmitted(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<FormStep>().having((s) => s.loading, 'loading', true),
        ),
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<FormStep>()
              .having((s) => s.loading, 'loading', false)
              .having((s) => s.error, 'error', 'Compose error'),
        ),
      ],
    );
  });
  group(ReviewSubmitted, () {
    const fee = 250;

    blocTest<CloseDispenserBloc, CloseDispenserState>(
      'emits SubmitFinalizing when FinalizeTransactionEvent is added',
      build: () => closeDispenserBloc,
      act: (bloc) => bloc.add(ReviewSubmitted(
        composeTransaction: mockComposeDispenserResponseVerbose,
        fee: fee,
      )),
      expect: () => [
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<PasswordStep<ComposeDispenserResponseVerbose>>()
              .having((s) => s.loading, 'loading', false)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDispenserResponseVerbose)
              .having((s) => s.fee, 'fee', fee),
        ),
      ],
    );
  });

  group(SignAndBroadcastFormSubmitted, () {
    const password = 'test-password';
    const txHex = 'transaction-hex';
    const txHash = 'transaction-hash';
    const sourceAddress = 'source-address';
    final mockComposeDispenserVerboseParams =
        MockComposeDispenserResponseVerboseParams();

    blocTest<CloseDispenserBloc, CloseDispenserState>(
      'emits SubmitSuccess when transaction is signed and broadcasted successfully',
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
          // Call onSuccess immediately without delay
          onSuccess(
            txHex,
            txHash,
          );
        });

        // Mock other dependencies
        when(() => mockWriteLocalTransactionUseCase.call(txHex, txHash))
            .thenAnswer((_) async {});
        when(() => mockAnalyticsService.trackAnonymousEvent(
              any(),
              properties: any(named: 'properties'),
            )).thenAnswer((_) async {});

        // Set up composeTransaction mock
        when(() => mockComposeDispenserResponseVerbose.params)
            .thenReturn(mockComposeDispenserVerboseParams);
        // Set up params
        when(() => mockComposeDispenserVerboseParams.source)
            .thenReturn(sourceAddress);
        when(() => mockComposeDispenserVerboseParams.giveQuantity)
            .thenReturn(1000);
        when(() => mockComposeDispenserVerboseParams.asset)
            .thenReturn('ASSET_NAME');
        when(() => mockComposeDispenserVerboseParams.escrowQuantity)
            .thenReturn(500);
        when(() => mockComposeDispenserVerboseParams.mainchainrate)
            .thenReturn(1);
        when(() => mockComposeDispenserVerboseParams.status).thenReturn(10);
        when(() => mockComposeDispenserResponseVerbose.rawtransaction)
            .thenReturn(txHex);

        return closeDispenserBloc;
      },
      seed: () => CloseDispenserState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: FeeOption.Medium(),
        submitState: PasswordStep<ComposeDispenserResponseVerbose>(
          loading: false,
          error: null,
          composeTransaction: mockComposeDispenserResponseVerbose,
          fee: 250,
        ),
        dispensersState: const DispenserState.initial(),
      ),
      act: (bloc) async {
        bloc.add(SignAndBroadcastFormSubmitted(password: password));
      },
      // Add a small wait to allow async operations to complete
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<PasswordStep<ComposeDispenserResponseVerbose>>()
              .having((s) => s.loading, 'loading', true)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDispenserResponseVerbose)
              .having((s) => s.fee, 'fee', 250),
        ),
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitSuccess>(),
        ),
      ],
    );
    //
    // password: test-password
    // source: source-address
    // raw: raw-transaction

    blocTest<CloseDispenserBloc, CloseDispenserState>(
      'emits SubmitFinalizing with error when transaction signing fails',
      build: () {
        when(() => mockSignAndBroadcastTransactionUseCase.call(
              source: "source-address",
              rawtransaction: "raw-transaction",
              decryptionStrategy: Password('test-password'),
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError'),
            )).thenAnswer((invocation) async {
          final onError =
              invocation.namedArguments[const Symbol('onError')] as Function;
          // Ensure onError is called asynchronously
          await Future.delayed(Duration.zero);
          onError('Signing error');
        });

        // Mock other dependencies
        when(() => mockWriteLocalTransactionUseCase.call(txHex, txHash))
            .thenAnswer((_) async {});
        when(() => mockAnalyticsService.trackAnonymousEvent(
              any(),
              properties: any(named: 'properties'),
            )).thenAnswer((_) async {});

        // Set up composeTransaction mock
        when(() => mockComposeDispenserResponseVerbose.params)
            .thenReturn(mockComposeDispenserVerboseParams);
        // Set up params
        when(() => mockComposeDispenserVerboseParams.source)
            .thenReturn(sourceAddress);
        when(() => mockComposeDispenserVerboseParams.giveQuantity)
            .thenReturn(1000);
        when(() => mockComposeDispenserVerboseParams.asset)
            .thenReturn('ASSET_NAME');
        when(() => mockComposeDispenserVerboseParams.escrowQuantity)
            .thenReturn(500);
        when(() => mockComposeDispenserVerboseParams.mainchainrate)
            .thenReturn(1);
        when(() => mockComposeDispenserVerboseParams.status).thenReturn(10);
        when(() => mockComposeDispenserResponseVerbose.rawtransaction)
            .thenReturn('raw-transaction');

        return closeDispenserBloc;
      },
      seed: () => CloseDispenserState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: FeeOption.Medium(),
        submitState: PasswordStep<ComposeDispenserResponseVerbose>(
          loading: false,
          error: null,
          composeTransaction: mockComposeDispenserResponseVerbose,
          fee: 250,
        ),
        dispensersState: const DispenserState.initial(),
      ),
      act: (bloc) =>
          bloc.add(SignAndBroadcastFormSubmitted(password: password)),
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<PasswordStep<ComposeDispenserResponseVerbose>>()
              .having((s) => s.loading, 'loading', true)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDispenserResponseVerbose)
              .having((s) => s.fee, 'fee', 250),
        ),
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<PasswordStep<ComposeDispenserResponseVerbose>>()
              .having((s) => s.loading, 'loading', false)
              .having((s) => s.error, 'error', 'Signing error')
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDispenserResponseVerbose)
              .having((s) => s.fee, 'fee', 250),
        ),
      ],
    );
  });
}
