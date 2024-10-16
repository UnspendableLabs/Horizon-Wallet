import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/presentation/screens/close_dispenser/bloc/close_dispenser_bloc.dart';
import 'package:horizon/presentation/screens/close_dispenser/bloc/close_dispenser_state.dart';
import 'package:horizon/presentation/screens/close_dispenser/usecase/fetch_form_data.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/presentation/screens/compose_dispenser/bloc/compose_dispenser_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/entities/address.dart';

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

class MockComposeDispenserVerbose extends Mock
    implements ComposeDispenserResponseVerbose {}

class MockComposeDispenserResponseVerboseParams extends Mock
    implements ComposeDispenserResponseVerboseParams {}

class MockBalance extends Mock implements Balance {}

class MockComposeDispenserEventParams extends Mock
    implements ComposeDispenserEventParams {}

class FakeAddress extends Fake implements Address {
  @override
  final String accountUuid = "test-account-uuid";
  @override
  final String address = "test-address";
  @override
  final int index = 0;
}

class FakeUtxo extends Fake implements Utxo {}

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

  const mockFeeEstimates = FeeEstimates(fast: 5, medium: 3, slow: 1);
  final mockDispenser = Dispenser(
    assetName: 'ASSET_NAME',
    openAddress: 'test-address',
    giveQuantity: 1000,
    escrowQuantity: 500,
    mainchainrate: 1,
    status: 0,
  );
  final mockAddress = FakeAddress();
  final mockBalances = [MockBalance()];
  final mockComposeDispenserVerbose = MockComposeDispenserVerbose();
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
    registerFallbackValue(FakeAddress());
    registerFallbackValue(composeTransactionParams);
    registerFallbackValue(utxos);
    registerFallbackValue(FeeOption.Medium());
    registerFallbackValue(ComposeTransactionEvent(
      params: composeTransactionParams,
      // utxos: utxos,
      // feeRate: feeRate,
      sourceAddress: 'source-address',
    ));
    registerFallbackValue(SignAndBroadcastTransactionEvent(
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

    closeDispenserBloc = CloseDispenserBloc(
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
  });

  group(FetchFormData, () {
    blocTest<CloseDispenserBloc, CloseDispenserState>(
      'emits loading and then success states when data is fetched successfully',
      build: () {
        when(() => mockFetchCloseDispenserFormDataUseCase.call(any()))
            .thenAnswer((_) async => (mockFeeEstimates, [mockDispenser]));
        return closeDispenserBloc;
      },
      act: (bloc) {
        bloc.add(FetchFormData(currentAddress: mockAddress));
      },
      expect: () => [
        closeDispenserBloc.state.copyWith(
          feeState: const FeeState.loading(),
          balancesState: const BalancesState.loading(), // Added this line
          dispensersState: const DispenserState.loading(),
          submitState: const SubmitInitial(),
        ),
        closeDispenserBloc.state.copyWith(
          feeState: const FeeState.success(mockFeeEstimates),
          balancesState: const BalancesState.success([]), // And this line
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
        bloc.add(FetchFormData(currentAddress: mockAddress));
      },
      expect: () => [
        closeDispenserBloc.state.copyWith(
          dispensersState: const DispenserState.loading(),
          submitState: const SubmitInitial(),
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
        bloc.add(FetchFormData(currentAddress: mockAddress));
      },
      expect: () => [
        closeDispenserBloc.state.copyWith(
          feeState: const FeeState.loading(),
          submitState: const SubmitInitial(),
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
        bloc.add(FetchFormData(currentAddress: mockAddress));
      },
      expect: () => [
        closeDispenserBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          dispensersState: const DispenserState.loading(),
          submitState: const SubmitInitial(),
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
            )).thenAnswer((_) async => mockComposeDispenserVerbose);

        when(() => mockComposeDispenserVerbose.btcFee).thenReturn(250);

        return closeDispenserBloc;
      },
      seed: () => closeDispenserBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Medium(),
      ),
      act: (bloc) => bloc.add(ComposeTransactionEvent(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitInitial>().having((s) => s.loading, 'loading', true),
        ),
        isA<CloseDispenserState>().having(
            (state) => state.submitState,
            'submitState',
            isA<SubmitComposingTransaction<ComposeDispenserResponseVerbose>>()
                .having((s) => s.composeTransaction, 'composeTransaction',
                    mockComposeDispenserVerbose)
                .having((s) => s.fee, 'fee', 250)
                .having((s) => s.feeRate, 'feeRate', 3) // default ( medium ),
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
            )).thenAnswer((_) async => mockComposeDispenserVerbose);

        when(() => mockComposeDispenserVerbose.btcFee).thenReturn(250);

        return closeDispenserBloc;
      },
      seed: () => closeDispenserBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Custom(10),
      ),
      act: (bloc) => bloc.add(ComposeTransactionEvent(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitInitial>().having((s) => s.loading, 'loading', true),
        ),
        isA<CloseDispenserState>().having(
            (state) => state.submitState,
            'submitState',
            isA<SubmitComposingTransaction<ComposeDispenserResponseVerbose>>()
                .having((s) => s.composeTransaction, 'composeTransaction',
                    mockComposeDispenserVerbose)
                .having((s) => s.fee, 'fee', 250)
                .having((s) => s.feeRate, 'feeRate', 10) // custom ,
            ),
      ],
    );

    blocTest<CloseDispenserBloc, CloseDispenserState>(
      'emits SubmitInitial with error when transaction composition fails',
      build: () {
        when(() => mockComposeTransactionUseCase
                .call<ComposeDispenserParams, ComposeDispenserResponseVerbose>(
              feeRate: any(named: 'feeRate'),
              source: any(named: 'source'),
              composeFn: any(named: 'composeFn'),
              params: any(named: 'params'),
            )).thenThrow(ComposeTransactionException('Compose error'));

        return closeDispenserBloc;
      },
      seed: () => closeDispenserBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Medium(),
      ),
      act: (bloc) => bloc.add(ComposeTransactionEvent(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitInitial>().having((s) => s.loading, 'loading', true),
        ),
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitInitial>()
              .having((s) => s.loading, 'loading', false)
              .having((s) => s.error, 'error', 'Compose error'),
        ),
      ],
    );
  });
  group(FinalizeTransactionEvent, () {
    const fee = 250;

    blocTest<CloseDispenserBloc, CloseDispenserState>(
      'emits SubmitFinalizing when FinalizeTransactionEvent is added',
      build: () => closeDispenserBloc,
      act: (bloc) => bloc.add(FinalizeTransactionEvent(
        composeTransaction: mockComposeDispenserVerbose,
        fee: fee,
      )),
      expect: () => [
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitFinalizing<ComposeDispenserResponseVerbose>>()
              .having((s) => s.loading, 'loading', false)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDispenserVerbose)
              .having((s) => s.fee, 'fee', fee),
        ),
      ],
    );
  });

  group(SignAndBroadcastTransactionEvent, () {
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
              password: any(named: 'password'),
              extractParams: any(named: 'extractParams'),
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError'),
            )).thenAnswer((invocation) async {
          final onSuccess =
              invocation.namedArguments[const Symbol('onSuccess')] as Function;
          // Simulate asynchronous operation
          Future.delayed(Duration.zero, () {
            onSuccess(txHex, txHash, sourceAddress, 'destination-address', 1000,
                'ASSET_NAME');
          });
        });

        when(() => mockWriteLocalTransactionUseCase.call(txHex, txHash))
            .thenAnswer((_) async {});

        when(() => mockAnalyticsService.trackEvent(any()))
            .thenAnswer((_) async {});

        // Set up the composeTransaction mock
        when(() => mockComposeDispenserVerbose.params)
            .thenReturn(mockComposeDispenserVerboseParams);
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

        return closeDispenserBloc;
      },
      seed: () => CloseDispenserState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: FeeOption.Medium(),
        submitState: SubmitFinalizing<ComposeDispenserResponseVerbose>(
          loading: false,
          error: null,
          composeTransaction: mockComposeDispenserVerbose,
          fee: 250,
        ),
        dispensersState: const DispenserState.initial(),
      ),
      act: (bloc) async {
        bloc.add(SignAndBroadcastTransactionEvent(password: password));
        // Wait for asynchronous operations to complete
        await Future.delayed(Duration.zero);
      },
      expect: () => [
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitFinalizing<ComposeDispenserResponseVerbose>>()
              .having((s) => s.loading, 'loading', true)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDispenserVerbose)
              .having((s) => s.fee, 'fee', 250),
        ),
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitSuccess>()
              .having((s) => s.transactionHex, 'transactionHex', txHex)
              .having((s) => s.sourceAddress, 'sourceAddress', sourceAddress),
        ),
      ],
      // verify: (_) {
      //   verify(() => mockSignAndBroadcastTransactionUseCase.call(
      //         password: password,
      //         extractParams: any(named: 'extractParams'),
      //         onSuccess: any(named: 'onSuccess'),
      //         onError: any(named: 'onError'),
      //       )).called(1);
      //   verify(() => mockWriteLocalTransactionUseCase.call(txHex, txHash))
      //       .called(1);
      //   verify(() =>
      //           mockAnalyticsService.trackEvent('broadcast_tx_dispenser'))
      //       .called(1);
      // },
    );

    blocTest<CloseDispenserBloc, CloseDispenserState>(
      'emits SubmitFinalizing with error when transaction signing fails',
      build: () {
        when(() => mockSignAndBroadcastTransactionUseCase(
              password: any(named: 'password'),
              extractParams: any(named: 'extractParams'),
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError'),
            )).thenAnswer((invocation) async {
          final onError =
              invocation.namedArguments[const Symbol('onError')] as Function;
          onError('Signing error');
        });

        return closeDispenserBloc;
      },
      seed: () => closeDispenserBloc.state.copyWith(
        submitState: SubmitFinalizing<ComposeDispenserResponseVerbose>(
          loading: false,
          error: null,
          composeTransaction: mockComposeDispenserVerbose,
          fee: 250,
        ),
      ),
      act: (bloc) =>
          bloc.add(SignAndBroadcastTransactionEvent(password: password)),
      expect: () => [
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitFinalizing<ComposeDispenserResponseVerbose>>()
              .having((s) => s.loading, 'loading', true)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDispenserVerbose)
              .having((s) => s.fee, 'fee', 250),
        ),
        isA<CloseDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitFinalizing<ComposeDispenserResponseVerbose>>()
              .having((s) => s.loading, 'loading', false)
              .having((s) => s.error, 'error', 'Signing error')
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDispenserVerbose)
              .having((s) => s.fee, 'fee', 250),
        ),
      ],
    );
  });
}
