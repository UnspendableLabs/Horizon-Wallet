import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/compose_sweep.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/estimate_xcp_fee_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_sweep/bloc/compose_sweep_bloc.dart';
import 'package:horizon/presentation/screens/compose_sweep/bloc/compose_sweep_state.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
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

class MockEstimateXcpFeeRepository extends Mock
    implements EstimateXcpFeeRepository {}

class MockErrorService extends Mock implements ErrorService {}

class MockComposeSweepResponse extends Mock implements ComposeSweepResponse {
  @override
  final ComposeSweepResponseParams params = MockComposeSweepResponseParams();

  @override
  String get rawtransaction => "rawtransaction";

  @override
  int get btcFee => 250;

  @override
  SignedTxEstimatedSize get signedTxEstimatedSize => SignedTxEstimatedSize(
        virtualSize: 100,
        adjustedVirtualSize: 100,
        sigopsCount: 1,
      );
}

class MockComposeSweepResponseParams extends Mock
    implements ComposeSweepResponseParams {
  @override
  String get source => "source";
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
  late ComposeSweepBloc bloc;
  late MockComposeRepository mockComposeRepository;
  late MockAnalyticsService mockAnalyticsService;
  late MockLogger mockLogger;
  late MockGetFeeEstimatesUseCase mockGetFeeEstimatesUseCase;
  late MockComposeTransactionUseCase mockComposeTransactionUseCase;
  late MockSignAndBroadcastTransactionUseCase
      mockSignAndBroadcastTransactionUseCase;
  late MockWriteLocalTransactionUseCase mockWriteLocalTransactionUseCase;
  late MockErrorService mockErrorService;
  late MockEstimateXcpFeeRepository mockEstimateXcpFeeRepository;
  const mockFeeEstimates = FeeEstimates(fast: 5, medium: 3, slow: 1);
  final mockComposeSweepResponse = MockComposeSweepResponse();

  final composeTransactionParams = ComposeSweepEventParams(
    destination: 'destination-address',
    flags: 0,
    memo: 'test memo',
  );

  setUpAll(() {
    registerFallbackValue(FeeOption.Medium());
    registerFallbackValue(ComposeSweepParams(
      source: 'source-address',
      destination: 'destination-address',
      flags: 0,
      memo: 'test memo',
    ));
    registerFallbackValue(FormSubmitted(
      params: composeTransactionParams,
      sourceAddress: 'source-address',
    ));
    registerFallbackValue(SignAndBroadcastFormSubmitted(
      password: 'password',
    ));
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
    mockEstimateXcpFeeRepository = MockEstimateXcpFeeRepository();
    mockErrorService = MockErrorService();

    // Register the ErrorService mock with GetIt
    GetIt.I.registerSingleton<ErrorService>(mockErrorService);

    bloc = ComposeSweepBloc(
      composeRepository: mockComposeRepository,
      analyticsService: mockAnalyticsService,
      logger: mockLogger,
      getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
      composeTransactionUseCase: mockComposeTransactionUseCase,
      signAndBroadcastTransactionUseCase:
          mockSignAndBroadcastTransactionUseCase,
      writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
      estimateXcpFeeRepository: mockEstimateXcpFeeRepository,
    );
  });

  tearDown(() {
    bloc.close();
    // Reset GetIt instance after each test
    GetIt.I.reset();
  });

  test('initial state is correct', () {
    final initialState = bloc.state;
    expect(initialState.feeState, equals(const FeeState.initial()));
    expect(initialState.balancesState, equals(const BalancesState.initial()));
    expect(initialState.feeOption, isA<FeeOption.Medium>());
    expect(initialState.submitState, isA<FormStep>());
  });

  group('FetchFormData', () {
    blocTest<ComposeSweepBloc, ComposeSweepState>(
      'emits loading and then success states when fee estimates are fetched successfully',
      build: () {
        when(() => mockGetFeeEstimatesUseCase.call())
            .thenAnswer((_) async => mockFeeEstimates);
        when(() => mockEstimateXcpFeeRepository.estimateSweepXcpFees(any()))
            .thenAnswer((_) async => 20000000);
        return bloc;
      },
      act: (bloc) => bloc
          .add(AsyncFormDependenciesRequested(currentAddress: 'test-address')),
      expect: () => [
        isA<ComposeSweepState>()
            .having((s) => s.balancesState, 'balancesState',
                const BalancesState.loading())
            .having((s) => s.feeState, 'feeState', const FeeState.loading())
            .having((s) => s.feeOption, 'feeOption', isA<FeeOption.Medium>())
            .having((s) => s.submitState, 'submitState', isA<FormStep>())
            .having((s) => s.sweepXcpFeeState, 'sweepXcpFeeState',
                const SweepXcpFeeState.loading()),
        isA<ComposeSweepState>()
            .having((s) => s.balancesState, 'balancesState',
                const BalancesState.success([]))
            .having((s) => s.feeState, 'feeState',
                const FeeState.success(mockFeeEstimates))
            .having((s) => s.feeOption, 'feeOption', isA<FeeOption.Medium>())
            .having((s) => s.submitState, 'submitState', isA<FormStep>())
            .having((s) => s.sweepXcpFeeState, 'sweepXcpFeeState',
                const SweepXcpFeeState.success(20000000)),
      ],
    );

    blocTest<ComposeSweepBloc, ComposeSweepState>(
      'emits error state when fee estimates fetch fails',
      build: () {
        when(() => mockGetFeeEstimatesUseCase.call())
            .thenThrow(Exception('Fee estimates error'));
        return bloc;
      },
      act: (bloc) => bloc
          .add(AsyncFormDependenciesRequested(currentAddress: 'test-address')),
      expect: () => [
        isA<ComposeSweepState>()
            .having((s) => s.balancesState, 'balancesState',
                const BalancesState.loading())
            .having((s) => s.feeState, 'feeState', const FeeState.loading())
            .having((s) => s.feeOption, 'feeOption', isA<FeeOption.Medium>())
            .having((s) => s.sweepXcpFeeState, 'sweepXcpFeeState',
                const SweepXcpFeeState.loading())
            .having((s) => s.submitState, 'submitState', isA<FormStep>()),
        isA<ComposeSweepState>()
            .having((s) => s.balancesState, 'balancesState',
                const BalancesState.loading())
            .having(
                (s) => s.feeState,
                'feeState',
                isA<FeeState>().having((f) => f.toString(), 'error message',
                    contains('Fee estimates error')))
            .having((s) => s.feeOption, 'feeOption', isA<FeeOption.Medium>())
            .having((s) => s.submitState, 'submitState', isA<FormStep>()),
      ],
    );
  });

  group('ChangeFeeOption', () {
    blocTest<ComposeSweepBloc, ComposeSweepState>(
      'updates fee option when changed',
      build: () => bloc,
      act: (bloc) => bloc.add(FeeOptionChanged(value: FeeOption.Fast())),
      expect: () => [
        isA<ComposeSweepState>()
            .having((s) => s.balancesState, 'balancesState',
                const BalancesState.initial())
            .having((s) => s.feeState, 'feeState', const FeeState.initial())
            .having((s) => s.feeOption, 'feeOption', isA<FeeOption.Fast>())
            .having((s) => s.submitState, 'submitState', isA<FormStep>())
            .having((s) => s.sweepXcpFeeState, 'sweepXcpFeeState',
                const SweepXcpFeeState.initial()),
      ],
    );
  });

  group('ComposeTransaction', () {
    final params = ComposeSweepEventParams(
      destination: 'destination-address',
      flags: 0,
      memo: 'test memo',
    );

    blocTest<ComposeSweepBloc, ComposeSweepState>(
      'emits composing states when transaction composition succeeds',
      build: () {
        when(() => mockComposeTransactionUseCase
                .call<ComposeSweepParams, ComposeSweepResponse>(
              feeRate: any(named: 'feeRate'),
              source: any(named: 'source'),
              params: any(named: 'params'),
              composeFn: any(named: 'composeFn'),
            )).thenAnswer((_) async => mockComposeSweepResponse);
        return bloc;
      },
      seed: () => ComposeSweepState(
        balancesState: const BalancesState.initial(),
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Medium(),
        submitState: const FormStep(),
        sweepXcpFeeState: const SweepXcpFeeState.initial(),
      ),
      act: (bloc) => bloc.add(FormSubmitted(
        params: params,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<ComposeSweepState>()
            .having((s) => s.balancesState, 'balancesState',
                const BalancesState.initial())
            .having((s) => s.feeState, 'feeState',
                const FeeState.success(mockFeeEstimates))
            .having((s) => s.feeOption, 'feeOption', isA<FeeOption.Medium>())
            .having((s) => s.submitState, 'submitState',
                isA<FormStep>().having((s) => s.loading, 'loading', true))
            .having((s) => s.sweepXcpFeeState, 'sweepXcpFeeState',
                const SweepXcpFeeState.initial()),
        isA<ComposeSweepState>()
            .having((s) => s.balancesState, 'balancesState',
                const BalancesState.initial())
            .having((s) => s.feeState, 'feeState',
                const FeeState.success(mockFeeEstimates))
            .having((s) => s.sweepXcpFeeState, 'sweepXcpFeeState',
                const SweepXcpFeeState.initial())
            .having((s) => s.feeOption, 'feeOption', isA<FeeOption.Medium>())
            .having(
                (s) => s.submitState,
                'submitState',
                isA<ReviewStep<ComposeSweepResponse, void>>()
                    .having((s) => s.composeTransaction, 'composeTransaction',
                        mockComposeSweepResponse)
                    .having((s) => s.fee, 'fee', 250)
                    .having((s) => s.feeRate, 'feeRate', 3)
                    .having((s) => s.virtualSize, 'virtualSize', 100)
                    .having((s) => s.adjustedVirtualSize, 'adjustedVirtualSize',
                        100)),
      ],
    );
  });

  group('SignAndBroadcastTransaction', () {
    const password = 'test-password';
    const txHex = 'rawtransaction';
    const txHash = 'transaction-hash';

    blocTest<ComposeSweepBloc, ComposeSweepState>(
      'successfully signs and broadcasts transaction',
      build: () {
        when(() => mockSignAndBroadcastTransactionUseCase.call(
              password: password,
              source: any(named: 'source'),
              rawtransaction: txHex,
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError'),
            )).thenAnswer((invocation) async {
          final onSuccess =
              invocation.namedArguments[const Symbol('onSuccess')] as Function;
          await onSuccess(txHex, txHash);
        });

        when(() => mockWriteLocalTransactionUseCase.call(txHex, txHash))
            .thenAnswer((_) async {});

        when(() => mockAnalyticsService.trackAnonymousEvent(
              'broadcast_tx_sweep',
              properties: any(named: 'properties'),
            )).thenAnswer((_) async {});

        return bloc;
      },
      seed: () => ComposeSweepState(
        balancesState: const BalancesState.initial(),
        feeState: const FeeState.initial(),
        feeOption: FeeOption.Medium(),
        sweepXcpFeeState: const SweepXcpFeeState.initial(),
        submitState: PasswordStep<ComposeSweepResponse>(
          loading: false,
          error: null,
          composeTransaction: mockComposeSweepResponse,
          fee: 250,
        ),
      ),
      act: (bloc) =>
          bloc.add(SignAndBroadcastFormSubmitted(password: password)),
      expect: () => [
        isA<ComposeSweepState>()
            .having((s) => s.balancesState, 'balancesState',
                const BalancesState.initial())
            .having((s) => s.feeState, 'feeState', const FeeState.initial())
            .having((s) => s.feeOption, 'feeOption', isA<FeeOption.Medium>())
            .having((s) => s.sweepXcpFeeState, 'sweepXcpFeeState',
                const SweepXcpFeeState.initial())
            .having(
                (s) => s.submitState,
                'submitState',
                isA<PasswordStep<ComposeSweepResponse>>()
                    .having((s) => s.loading, 'loading', true)
                    .having((s) => s.error, 'error', null)
                    .having((s) => s.composeTransaction, 'composeTransaction',
                        mockComposeSweepResponse)
                    .having((s) => s.fee, 'fee', 250)),
        isA<ComposeSweepState>()
            .having((s) => s.balancesState, 'balancesState',
                const BalancesState.initial())
            .having((s) => s.feeState, 'feeState', const FeeState.initial())
            .having((s) => s.feeOption, 'feeOption', isA<FeeOption.Medium>())
            .having((s) => s.sweepXcpFeeState, 'sweepXcpFeeState',
                const SweepXcpFeeState.initial())
            .having(
                (s) => s.submitState,
                'submitState',
                isA<SubmitSuccess>()
                    .having((s) => s.transactionHex, 'transactionHex', txHex)
                    .having((s) => s.sourceAddress, 'sourceAddress', 'source')),
      ],
      verify: (_) {
        verify(() => mockAnalyticsService.trackAnonymousEvent(
              'broadcast_tx_sweep',
              properties: any(named: 'properties'),
            )).called(1);
      },
    );
  });
}
