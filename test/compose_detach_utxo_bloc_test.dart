import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_detach_utxo.dart';
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
import 'package:horizon/presentation/screens/compose_detach_utxo/bloc/compose_detach_utxo_bloc.dart';
import 'package:horizon/presentation/screens/compose_detach_utxo/bloc/compose_detach_utxo_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';

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

class MockComposeDetachUtxoResponse extends Mock
    implements ComposeDetachUtxoResponse {}

class MockErrorService extends Mock implements ErrorService {}

class MockInMemoryKeyRepository extends Mock implements InMemoryKeyRepository {}

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

class MockComposeDetachUtxoResponseParams extends Mock
    implements ComposeDetachUtxoResponseParams {}

void main() {
  late ComposeDetachUtxoBloc composeDetachUtxoBloc;
  late MockComposeRepository mockComposeRepository;
  late MockAnalyticsService mockAnalyticsService;
  late MockLogger mockLogger;
  late MockGetFeeEstimatesUseCase mockGetFeeEstimatesUseCase;
  late MockComposeTransactionUseCase mockComposeTransactionUseCase;
  late MockSignAndBroadcastTransactionUseCase
      mockSignAndBroadcastTransactionUseCase;
  late MockWriteLocalTransactionUseCase mockWriteLocalTransactionUseCase;
  late MockErrorService mockErrorService;
  late MockInMemoryKeyRepository mockInMemoryKeyRepository;

  const mockFeeEstimates = FeeEstimates(fast: 5, medium: 3, slow: 1);

  final mockComposeDetachUtxoResponse = MockComposeDetachUtxoResponse();

  final composeTransactionParams = ComposeDetachUtxoEventParams(
    utxo: 'some-utxo',
  );

  setUpAll(() {
    registerFallbackValue(FeeOption.Medium());
    registerFallbackValue(composeTransactionParams);
    registerFallbackValue(
      FormSubmitted(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      ),
    );
    registerFallbackValue(SignAndBroadcastFormSubmitted(
      password: 'password',
    ));
    registerFallbackValue(ComposeDetachUtxoParams(
      utxo: 'some-utxo',
      destination: 'ADDRESS',
    ));
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
    mockInMemoryKeyRepository = MockInMemoryKeyRepository();

    // Register the ErrorService mock with GetIt
    GetIt.I.registerSingleton<ErrorService>(mockErrorService);

    composeDetachUtxoBloc = ComposeDetachUtxoBloc(
      inMemoryKeyRepository: mockInMemoryKeyRepository,
      passwordRequired: true,
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
    composeDetachUtxoBloc.close();
    // Reset GetIt instance after each test
    GetIt.I.reset();
  });

  group('FetchFormData', () {
    blocTest<ComposeDetachUtxoBloc, ComposeDetachUtxoState>(
      'emits loading and then success states when data is fetched successfully',
      build: () {
        when(() => mockGetFeeEstimatesUseCase.call()).thenAnswer(
          (_) async => mockFeeEstimates,
        );
        return composeDetachUtxoBloc;
      },
      act: (bloc) {
        bloc.add(AsyncFormDependenciesRequested(
          currentAddress: 'test-address',
          assetName: 'ASSET_NAME',
        ));
      },
      expect: () => [
        composeDetachUtxoBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          submitState: const FormStep(),
        ),
        composeDetachUtxoBloc.state.copyWith(
          balancesState: const BalancesState.success([]),
          feeState: const FeeState.success(mockFeeEstimates),
        ),
      ],
    );

    blocTest<ComposeDetachUtxoBloc, ComposeDetachUtxoState>(
      'emits error state when fetching fee estimates fails',
      build: () {
        when(() => mockGetFeeEstimatesUseCase.call()).thenThrow(
          FetchFeeEstimatesException('Failed to fetch fee estimates'),
        );
        return composeDetachUtxoBloc;
      },
      act: (bloc) {
        bloc.add(AsyncFormDependenciesRequested(
          currentAddress: 'test-address',
          assetName: 'ASSET_NAME',
        ));
      },
      expect: () => [
        composeDetachUtxoBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          submitState: const FormStep(),
        ),
        composeDetachUtxoBloc.state.copyWith(
          feeState: const FeeState.error('Failed to fetch fee estimates'),
        ),
      ],
    );
  });

  group('ChangeFeeOption', () {
    blocTest<ComposeDetachUtxoBloc, ComposeDetachUtxoState>(
      'emits new state with updated fee option',
      build: () => composeDetachUtxoBloc,
      act: (bloc) => bloc.add(FeeOptionChanged(value: FeeOption.Fast())),
      expect: () => [
        isA<ComposeDetachUtxoState>().having(
          (state) => state.feeOption,
          'feeOption',
          isA<FeeOption.Fast>(),
        ),
      ],
    );
  });

  group('ComposeTransactionEvent', () {
    blocTest<ComposeDetachUtxoBloc, ComposeDetachUtxoState>(
      'emits SubmitComposingTransaction when transaction composition succeeds',
      build: () {
        when(() => mockComposeTransactionUseCase
                .call<ComposeDetachUtxoParams, ComposeDetachUtxoResponse>(
              feeRate: any(named: 'feeRate'),
              source: any(named: 'source'),
              params: any(named: 'params'),
              composeFn: any(named: 'composeFn'),
            )).thenAnswer((_) async => mockComposeDetachUtxoResponse);

        when(() => mockComposeDetachUtxoResponse.btcFee).thenReturn(250);
        when(() => mockComposeDetachUtxoResponse.signedTxEstimatedSize)
            .thenReturn(SignedTxEstimatedSize(
          virtualSize: 120,
          adjustedVirtualSize: 155,
          sigopsCount: 1,
        ));

        return composeDetachUtxoBloc;
      },
      seed: () => composeDetachUtxoBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Medium(),
      ),
      act: (bloc) => bloc.add(FormSubmitted(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<ComposeDetachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<FormStep>().having((s) => s.loading, 'loading', true),
        ),
        isA<ComposeDetachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<ReviewStep<ComposeDetachUtxoResponse, void>>()
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDetachUtxoResponse)
              .having((s) => s.fee, 'fee', 250)
              .having((s) => s.feeRate, 'feeRate', 3)
              .having((s) => s.virtualSize, 'virtualSize', 120)
              .having((s) => s.adjustedVirtualSize, 'adjustedVirtualSize', 155),
        ),
      ],
    );

    blocTest<ComposeDetachUtxoBloc, ComposeDetachUtxoState>(
      'emits SubmitInitial with error when transaction composition fails',
      build: () {
        when(() => mockComposeTransactionUseCase
                .call<ComposeDetachUtxoParams, ComposeDetachUtxoResponse>(
              feeRate: any(named: 'feeRate'),
              source: any(named: 'source'),
              composeFn: any(named: 'composeFn'),
              params: any(named: 'params'),
            )).thenThrow(
          ComposeTransactionException('Compose error', StackTrace.current),
        );
        return composeDetachUtxoBloc;
      },
      seed: () => composeDetachUtxoBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Medium(),
      ),
      act: (bloc) => bloc.add(FormSubmitted(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<ComposeDetachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<FormStep>().having((s) => s.loading, 'loading', true),
        ),
        isA<ComposeDetachUtxoState>().having(
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

    blocTest<ComposeDetachUtxoBloc, ComposeDetachUtxoState>(
      'emits SubmitFinalizing when FinalizeTransactionEvent is added',
      build: () => composeDetachUtxoBloc,
      act: (bloc) => bloc.add(ReviewSubmitted(
        composeTransaction: mockComposeDetachUtxoResponse,
        fee: fee,
      )),
      expect: () => [
        isA<ComposeDetachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<PasswordStep<ComposeDetachUtxoResponse>>()
              .having((s) => s.loading, 'loading', false)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDetachUtxoResponse)
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
    const sourceAddress = 'source';

    blocTest<ComposeDetachUtxoBloc, ComposeDetachUtxoState>(
      'emits SubmitSuccess when transaction is signed and broadcasted successfully',
      build: () {
        final mockComposeDetachUtxoResponseParams =
            MockComposeDetachUtxoResponseParams();

        when(() => mockComposeDetachUtxoResponse.params)
            .thenReturn(mockComposeDetachUtxoResponseParams);

        when(() => mockComposeDetachUtxoResponseParams.source)
            .thenReturn(sourceAddress);

        when(() => mockComposeDetachUtxoResponseParams.destination)
            .thenReturn(destinationAddress);

        when(() => mockComposeDetachUtxoResponse.rawtransaction)
            .thenReturn(txHex);

        when(() => mockSignAndBroadcastTransactionUseCase.call(
              source: destinationAddress,
              rawtransaction: txHex,
              decryptionStrategy: Password(password),
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
              'broadcast_tx_detach_utxo',
              properties: any(named: 'properties'),
            )).thenAnswer((_) async {});

        return composeDetachUtxoBloc;
      },
      seed: () => composeDetachUtxoBloc.state.copyWith(
        submitState: PasswordStep<ComposeDetachUtxoResponse>(
          loading: false,
          error: null,
          composeTransaction: mockComposeDetachUtxoResponse,
          fee: 250,
        ),
      ),
      act: (bloc) => bloc.add(SignAndBroadcastFormSubmitted(
        password: password,
      )),
      expect: () => [
        isA<ComposeDetachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<PasswordStep<ComposeDetachUtxoResponse>>()
              .having((s) => s.loading, 'loading', true)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDetachUtxoResponse)
              .having((s) => s.fee, 'fee', 250),
        ),
        isA<ComposeDetachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitSuccess>()
              .having((s) => s.transactionHex, 'transactionHex', txHex)
              .having((s) => s.sourceAddress, 'sourceAddress', sourceAddress),
        ),
      ],
      verify: (_) {
        verify(() => mockAnalyticsService.trackAnonymousEvent(
              'broadcast_tx_detach_utxo',
              properties: any(named: 'properties'),
            )).called(1);
      },
    );

    blocTest<ComposeDetachUtxoBloc, ComposeDetachUtxoState>(
      'emits SubmitFinalizing with error when transaction signing fails',
      build: () {
        const txHex = 'rawtransaction';
        const txHash = 'transaction-hash';
        const destinationAddress = 'destination';
        const sourceAddress = 'source';
        const password = 'test-password';

        // Create the mock for ComposeDetachUtxoResponseParams
        final mockComposeDetachUtxoResponseParams =
            MockComposeDetachUtxoResponseParams();

        // Set up the mocked methods and properties
        when(() => mockComposeDetachUtxoResponse.params)
            .thenReturn(mockComposeDetachUtxoResponseParams);

        when(() => mockComposeDetachUtxoResponseParams.destination)
            .thenReturn(destinationAddress);

        when(() => mockComposeDetachUtxoResponseParams.source)
            .thenReturn(sourceAddress);

        when(() => mockComposeDetachUtxoResponse.rawtransaction)
            .thenReturn(txHex);

        // Mock the signAndBroadcastTransactionUseCase to call onError
        when(() => mockSignAndBroadcastTransactionUseCase.call(
              source: any(named: 'source'),
              rawtransaction: any(named: 'rawtransaction'),
              decryptionStrategy: Password(password),
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError'),
            )).thenAnswer((invocation) async {
          print("are we even ansewring");
          final onError = invocation.namedArguments[const Symbol('onError')]
              as Function(String);
          onError('Signing error');
        });

        return composeDetachUtxoBloc;
      },
      seed: () => composeDetachUtxoBloc.state.copyWith(
        submitState: PasswordStep<ComposeDetachUtxoResponse>(
          loading: false,
          error: null,
          composeTransaction: mockComposeDetachUtxoResponse,
          fee: 250,
        ),
      ),
      act: (bloc) => bloc.add(SignAndBroadcastFormSubmitted(
        password: password,
      )),
      expect: () => [
        isA<ComposeDetachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<PasswordStep<ComposeDetachUtxoResponse>>()
              .having((s) => s.loading, 'loading', true)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDetachUtxoResponse)
              .having((s) => s.fee, 'fee', 250),
        ),
        isA<ComposeDetachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<PasswordStep<ComposeDetachUtxoResponse>>()
              .having((s) => s.loading, 'loading', false)
              .having((s) => s.error, 'error', 'Signing error')
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDetachUtxoResponse)
              .having((s) => s.fee, 'fee', 250),
        ),
      ],
    );
  });
}
