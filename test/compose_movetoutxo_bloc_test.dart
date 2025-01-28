import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_movetoutxo.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
// Import necessary files
import 'package:horizon/presentation/screens/compose_movetoutxo/bloc/compose_movetoutxo_bloc.dart';
import 'package:horizon/presentation/screens/compose_movetoutxo/bloc/compose_movetoutxo_state.dart';
import 'package:mocktail/mocktail.dart';

class MockComposeRepository extends Mock implements ComposeRepository {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockLogger extends Mock implements Logger {}

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

class MockComposeTransactionUseCase extends Mock
    implements ComposeTransactionUseCase {}

class MockSignAndBroadcastTransactionUseCase extends Mock
    implements SignAndBroadcastTransactionUseCase {}

class MockWriteLocalTransactionUseCase extends Mock
    implements WriteLocalTransactionUseCase {}

class MockComposeMoveToUtxoResponse extends Mock
    implements ComposeMoveToUtxoResponse {}

class MockComposeMoveToUtxoResponseParams extends Mock
    implements ComposeMoveToUtxoResponseParams {}

class MockBalance extends Mock implements Balance {}

class FakeVirtualSize extends Fake implements VirtualSize {
  @override
  final int virtualSize;
  @override
  final int adjustedVirtualSize;

  FakeVirtualSize({
    required this.virtualSize,
    required this.adjustedVirtualSize,
  });
}

class MockErrorService extends Mock implements ErrorService {}

void main() {
  late ComposeMoveToUtxoBloc composeMoveToUtxoBloc;
  late MockComposeRepository mockComposeRepository;
  late MockAnalyticsService mockAnalyticsService;
  late MockLogger mockLogger;
  late MockGetFeeEstimatesUseCase mockGetFeeEstimatesUseCase;
  late MockComposeTransactionUseCase mockComposeTransactionUseCase;
  late MockSignAndBroadcastTransactionUseCase
      mockSignAndBroadcastTransactionUseCase;
  late MockWriteLocalTransactionUseCase mockWriteLocalTransactionUseCase;
  late MockErrorService mockErrorService;

  const mockFeeEstimates = FeeEstimates(fast: 5, medium: 3, slow: 1);
  final mockComposeMoveToUtxoResponse = MockComposeMoveToUtxoResponse();

  final composeTransactionParams = ComposeMoveToUtxoEventParams(
    utxo: 'some-utxo',
    destination: 'destination-address',
  );

  setUpAll(() {
    registerFallbackValue(FeeOption.Medium());
    registerFallbackValue(composeTransactionParams);
    registerFallbackValue(
      ComposeTransactionEvent(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      ),
    );
    registerFallbackValue(
      SignAndBroadcastTransactionEvent(
        password: 'password',
      ),
    );
    registerFallbackValue(
      ComposeMoveToUtxoParams(
        utxo: 'some-utxo',
        destination: 'destination-address',
      ),
    );
    registerFallbackValue((1, 3, 6));
  });

  setUp(() {
    mockComposeRepository = MockComposeRepository();
    mockAnalyticsService = MockAnalyticsService();
    mockLogger = MockLogger();
    mockGetFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();
    mockComposeTransactionUseCase = MockComposeTransactionUseCase();
    mockSignAndBroadcastTransactionUseCase =
        MockSignAndBroadcastTransactionUseCase();
    mockWriteLocalTransactionUseCase = MockWriteLocalTransactionUseCase();
    mockErrorService = MockErrorService();

    // Register the ErrorService mock with GetIt
    GetIt.I.registerSingleton<ErrorService>(mockErrorService);

    composeMoveToUtxoBloc = ComposeMoveToUtxoBloc(
      composeRepository: mockComposeRepository,
      analyticsService: mockAnalyticsService,
      logger: mockLogger,
      getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
      composeTransactionUseCase: mockComposeTransactionUseCase,
      signAndBroadcastTransactionUseCase:
          mockSignAndBroadcastTransactionUseCase,
      writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
    );
  });

  tearDown(() {
    composeMoveToUtxoBloc.close();
    // Reset GetIt instance after each test
    GetIt.I.reset();
  });

  group('FetchFormData', () {
    blocTest<ComposeMoveToUtxoBloc, ComposeMoveToUtxoState>(
      'emits loading and then success states when data is fetched successfully',
      build: () {
        when(() => mockGetFeeEstimatesUseCase.call())
            .thenAnswer((_) async => mockFeeEstimates);
        return composeMoveToUtxoBloc;
      },
      act: (bloc) {
        bloc.add(FetchFormData(
          currentAddress: 'source-address',
        ));
      },
      expect: () => [
        composeMoveToUtxoBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          submitState: const FormStep(),
          utxoAddress: '',
        ),
        composeMoveToUtxoBloc.state.copyWith(
          feeState: const FeeState.success(mockFeeEstimates),
          balancesState: const BalancesState.success([]),
          utxoAddress: 'source-address',
        ),
      ],
    );

    blocTest<ComposeMoveToUtxoBloc, ComposeMoveToUtxoState>(
      'emits error state when FetchFormData fails',
      build: () {
        when(() => mockGetFeeEstimatesUseCase.call()).thenThrow(
            FetchFeeEstimatesException('Failed to fetch fee estimates'));
        return composeMoveToUtxoBloc;
      },
      act: (bloc) {
        bloc.add(FetchFormData(
          currentAddress: 'source-address',
        ));
      },
      expect: () => [
        composeMoveToUtxoBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          submitState: const FormStep(),
        ),
        composeMoveToUtxoBloc.state.copyWith(
          feeState: const FeeState.error('Failed to fetch fee estimates'),
        ),
      ],
    );
  });

  group('ChangeFeeOption', () {
    blocTest<ComposeMoveToUtxoBloc, ComposeMoveToUtxoState>(
      'emits new state with updated fee option',
      build: () => composeMoveToUtxoBloc,
      act: (bloc) => bloc.add(ChangeFeeOption(value: FeeOption.Fast())),
      expect: () => [
        isA<ComposeMoveToUtxoState>().having(
          (state) => state.feeOption,
          'feeOption',
          isA<FeeOption.Fast>(),
        ),
      ],
    );
  });

  group('ComposeTransactionEvent', () {
    blocTest<ComposeMoveToUtxoBloc, ComposeMoveToUtxoState>(
      'emits SubmitComposingTransaction when transaction composition succeeds',
      build: () {
        when(() => mockComposeTransactionUseCase
                .call<ComposeMoveToUtxoParams, ComposeMoveToUtxoResponse>(
              feeRate: any(named: 'feeRate'),
              source: any(named: 'source'),
              composeFn: any(named: 'composeFn'),
              params: any(named: 'params'),
            )).thenAnswer(
          (_) async => mockComposeMoveToUtxoResponse,
        );
        when(() => mockComposeMoveToUtxoResponse.btcFee).thenReturn(250);
        when(() => mockComposeMoveToUtxoResponse.signedTxEstimatedSize)
            .thenReturn(SignedTxEstimatedSize(
          virtualSize: 120,
          adjustedVirtualSize: 155,
          sigopsCount: 1,
        ));
        return composeMoveToUtxoBloc;
      },
      seed: () => composeMoveToUtxoBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Medium(),
      ),
      act: (bloc) => bloc.add(ComposeTransactionEvent(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<ComposeMoveToUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<FormStep>().having((s) => s.loading, 'loading', true),
        ),
        isA<ComposeMoveToUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<ReviewStep<ComposeMoveToUtxoResponse, void>>()
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeMoveToUtxoResponse)
              .having((s) => s.fee, 'fee', 250)
              .having((s) => s.feeRate, 'feeRate', 3)
              .having((s) => s.virtualSize, 'virtualSize', 120)
              .having((s) => s.adjustedVirtualSize, 'adjustedVirtualSize', 155),
        ),
      ],
    );

    blocTest<ComposeMoveToUtxoBloc, ComposeMoveToUtxoState>(
      'emits SubmitInitial with error when transaction composition fails',
      build: () {
        when(() => mockComposeTransactionUseCase
                .call<ComposeMoveToUtxoParams, ComposeMoveToUtxoResponse>(
              feeRate: any(named: 'feeRate'),
              source: any(named: 'source'),
              composeFn: any(named: 'composeFn'),
              params: any(named: 'params'),
            )).thenThrow(
          ComposeTransactionException('Compose error', StackTrace.current),
        );
        return composeMoveToUtxoBloc;
      },
      seed: () => composeMoveToUtxoBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Medium(),
      ),
      act: (bloc) => bloc.add(ComposeTransactionEvent(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<ComposeMoveToUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<FormStep>().having((s) => s.loading, 'loading', true),
        ),
        isA<ComposeMoveToUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<FormStep>()
              .having((s) => s.loading, 'loading', false)
              .having((s) => s.error, 'error', 'Compose error'),
        ),
      ],
    );
  });

  group('FinalizeTransactionEvent', () {
    const fee = 250;

    blocTest<ComposeMoveToUtxoBloc, ComposeMoveToUtxoState>(
      'emits SubmitFinalizing when FinalizeTransactionEvent is added',
      build: () => composeMoveToUtxoBloc,
      act: (bloc) => bloc.add(FinalizeTransactionEvent(
        composeTransaction: mockComposeMoveToUtxoResponse,
        fee: fee,
      )),
      expect: () => [
        isA<ComposeMoveToUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<PasswordStep<ComposeMoveToUtxoResponse>>()
              .having((s) => s.loading, 'loading', false)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeMoveToUtxoResponse)
              .having((s) => s.fee, 'fee', fee),
        ),
      ],
    );
  });

  group('SignAndBroadcastTransactionEvent', () {
    const password = 'test-password';
    const txHex = 'rawtransaction';
    const txHash = 'transaction-hash';
    const destinationAddress = 'destination';
    const sourceAddress = 'source-address';

    blocTest<ComposeMoveToUtxoBloc, ComposeMoveToUtxoState>(
      'emits SubmitSuccess when transaction is signed and broadcasted successfully',
      build: () {
        final mockComposeMoveToUtxoResponseParams =
            MockComposeMoveToUtxoResponseParams();

        when(() => mockComposeMoveToUtxoResponse.params)
            .thenReturn(mockComposeMoveToUtxoResponseParams);

        when(() => mockComposeMoveToUtxoResponseParams.source)
            .thenReturn(sourceAddress);

        when(() => mockComposeMoveToUtxoResponseParams.destination)
            .thenReturn(destinationAddress);

        when(() => mockComposeMoveToUtxoResponse.rawtransaction)
            .thenReturn(txHex);

        when(() => mockSignAndBroadcastTransactionUseCase.call(
              source: any(named: 'source'),
              rawtransaction: any(named: 'rawtransaction'),
              password: any(named: 'password'),
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError'),
            )).thenAnswer((invocation) async {
          final onSuccess = invocation.namedArguments[const Symbol('onSuccess')]
              as Function(String, String);
          onSuccess(txHex, txHash);
        });

        when(() => mockWriteLocalTransactionUseCase.call(txHex, txHash))
            .thenAnswer((_) async {});

        when(() => mockAnalyticsService.trackAnonymousEvent(
              'broadcast_tx_move_to_utxo',
              properties: any(named: 'properties'),
            )).thenAnswer((_) async {});

        return composeMoveToUtxoBloc;
      },
      seed: () => composeMoveToUtxoBloc.state.copyWith(
        submitState: PasswordStep<ComposeMoveToUtxoResponse>(
          loading: false,
          error: null,
          composeTransaction: mockComposeMoveToUtxoResponse,
          fee: 250,
        ),
        utxoAddress: sourceAddress,
      ),
      act: (bloc) => bloc.add(SignAndBroadcastTransactionEvent(
        password: password,
      )),
      expect: () => [
        isA<ComposeMoveToUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<PasswordStep<ComposeMoveToUtxoResponse>>()
              .having((s) => s.loading, 'loading', true)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeMoveToUtxoResponse)
              .having((s) => s.fee, 'fee', 250),
        ),
        isA<ComposeMoveToUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitSuccess>()
              .having((s) => s.transactionHex, 'transactionHex', txHex)
              .having((s) => s.sourceAddress, 'sourceAddress', sourceAddress),
        ),
      ],
      verify: (_) {
        verify(() => mockAnalyticsService.trackAnonymousEvent(
              'broadcast_tx_move_to_utxo',
              properties: any(named: 'properties'),
            )).called(1);
      },
    );

    blocTest<ComposeMoveToUtxoBloc, ComposeMoveToUtxoState>(
      'emits SubmitFinalizing with error when transaction signing fails',
      build: () {
        const txHex = 'rawtransaction';
        const txHash = 'transaction-hash';
        const destinationAddress = 'destination';
        const sourceAddress = 'source-address';
        const password = 'test-password';

        // Create the mock for ComposeMoveToUtxoResponseParams
        final mockComposeMoveToUtxoResponseParams =
            MockComposeMoveToUtxoResponseParams();

        // Set up the mocked methods and properties
        when(() => mockComposeMoveToUtxoResponse.params)
            .thenReturn(mockComposeMoveToUtxoResponseParams);

        when(() => mockComposeMoveToUtxoResponseParams.destination)
            .thenReturn(destinationAddress);

        when(() => mockComposeMoveToUtxoResponseParams.source)
            .thenReturn(sourceAddress);

        when(() => mockComposeMoveToUtxoResponse.rawtransaction)
            .thenReturn(txHex);

        // Mock the signAndBroadcastTransactionUseCase to call onError
        when(() => mockSignAndBroadcastTransactionUseCase.call(
              source: any(named: 'source'),
              rawtransaction: any(named: 'rawtransaction'),
              password: any(named: 'password'),
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError'),
            )).thenAnswer((invocation) async {
          final onError = invocation.namedArguments[const Symbol('onError')]
              as Function(String);
          onError('Signing error');
        });

        return composeMoveToUtxoBloc;
      },
      seed: () => composeMoveToUtxoBloc.state.copyWith(
        submitState: PasswordStep<ComposeMoveToUtxoResponse>(
          loading: false,
          error: null,
          composeTransaction: mockComposeMoveToUtxoResponse,
          fee: 250,
        ),
        utxoAddress: sourceAddress,
      ),
      act: (bloc) => bloc.add(SignAndBroadcastTransactionEvent(
        password: password,
      )),
      expect: () => [
        isA<ComposeMoveToUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<PasswordStep<ComposeMoveToUtxoResponse>>()
              .having((s) => s.loading, 'loading', true)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeMoveToUtxoResponse)
              .having((s) => s.fee, 'fee', 250),
        ),
        isA<ComposeMoveToUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<PasswordStep<ComposeMoveToUtxoResponse>>()
              .having((s) => s.loading, 'loading', false)
              .having((s) => s.error, 'error', 'Signing error')
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeMoveToUtxoResponse)
              .having((s) => s.fee, 'fee', 250),
        ),
      ],
    );
  });
}
