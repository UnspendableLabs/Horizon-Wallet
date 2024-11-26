import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/presentation/screens/compose_detach_utxo/bloc/compose_detach_utxo_bloc.dart';
import 'package:horizon/presentation/screens/compose_detach_utxo/bloc/compose_detach_utxo_state.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/screens/compose_detach_utxo/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/domain/repositories/block_repository.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';

import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/entities/compose_detach_utxo.dart';

class MockComposeRepository extends Mock implements ComposeRepository {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockLogger extends Mock implements Logger {}

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

class MockFetchComposeDetachUtxoFormDataUseCase extends Mock
    implements FetchComposeDetachUtxoFormDataUseCase {}

class MockComposeTransactionUseCase extends Mock
    implements ComposeTransactionUseCase {}

class MockSignAndBroadcastTransactionUseCase extends Mock
    implements SignAndBroadcastTransactionUseCase {}

class MockWriteLocalTransactionUseCase extends Mock
    implements WriteLocalTransactionUseCase {}

class MockBlockRepository extends Mock implements BlockRepository {}

class MockComposeDetachUtxoResponse extends Mock
    implements ComposeDetachUtxoResponse {}

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
  late MockFetchComposeDetachUtxoFormDataUseCase
      mockFetchComposeDetachUtxoFormDataUseCase;
  late MockComposeTransactionUseCase mockComposeTransactionUseCase;
  late MockSignAndBroadcastTransactionUseCase
      mockSignAndBroadcastTransactionUseCase;
  late MockWriteLocalTransactionUseCase mockWriteLocalTransactionUseCase;

  const mockFeeEstimates = FeeEstimates(fast: 5, medium: 3, slow: 1);
  final mockBalance = Balance(
    asset: 'ASSET_NAME',
    quantity: 100,
    address: 'ADDRESS',
    quantityNormalized: '100',
    assetInfo: const AssetInfo(
      divisible: false,
    ),
  );
  final mockComposeDetachUtxoResponse = MockComposeDetachUtxoResponse();

  final composeTransactionParams = ComposeDetachUtxoEventParams(
    utxo: 'some-utxo',
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
    registerFallbackValue(SignAndBroadcastTransactionEvent(
      password: 'password',
    ));
    registerFallbackValue(ComposeDetachUtxoParams(
      utxo: 'some-utxo',
      destination: 'ADDRESS',
    ));
  });

  setUp(() {
    mockComposeRepository = MockComposeRepository();
    mockAnalyticsService = MockAnalyticsService();
    mockLogger = MockLogger();
    mockGetFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();
    mockFetchComposeDetachUtxoFormDataUseCase =
        MockFetchComposeDetachUtxoFormDataUseCase();
    mockComposeTransactionUseCase = MockComposeTransactionUseCase();
    mockSignAndBroadcastTransactionUseCase =
        MockSignAndBroadcastTransactionUseCase();
    mockWriteLocalTransactionUseCase = MockWriteLocalTransactionUseCase();

    composeDetachUtxoBloc = ComposeDetachUtxoBloc(
      composeRepository: mockComposeRepository,
      analyticsService: mockAnalyticsService,
      logger: mockLogger,
      getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
      fetchComposeDetachUtxoFormDataUseCase:
          mockFetchComposeDetachUtxoFormDataUseCase,
      composeTransactionUseCase: mockComposeTransactionUseCase,
      signAndBroadcastTransactionUseCase:
          mockSignAndBroadcastTransactionUseCase,
      writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
    );
  });

  tearDown(() {
    composeDetachUtxoBloc.close();
  });

  group('FetchFormData', () {
    blocTest<ComposeDetachUtxoBloc, ComposeDetachUtxoState>(
      'emits loading and then success states when data is fetched successfully',
      build: () {
        when(() => mockFetchComposeDetachUtxoFormDataUseCase.call(
              any(),
            )).thenAnswer(
          (_) async => (
            mockFeeEstimates,
            mockBalance,
          ),
        );
        return composeDetachUtxoBloc;
      },
      act: (bloc) {
        bloc.add(FetchFormData(
          currentAddress: 'test-address',
          assetName: 'ASSET_NAME',
        ));
      },
      expect: () => [
        composeDetachUtxoBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          submitState: const SubmitInitial(),
        ),
        composeDetachUtxoBloc.state.copyWith(
          balancesState: BalancesState.success([mockBalance]),
          feeState: const FeeState.success(mockFeeEstimates),
        ),
      ],
    );

    blocTest<ComposeDetachUtxoBloc, ComposeDetachUtxoState>(
      'emits error state when fetching fee estimates fails',
      build: () {
        when(() => mockFetchComposeDetachUtxoFormDataUseCase.call(
              any(),
            )).thenThrow(
          FetchFeeEstimatesException('Failed to fetch fee estimates'),
        );
        return composeDetachUtxoBloc;
      },
      act: (bloc) {
        bloc.add(FetchFormData(
          currentAddress: 'test-address',
          assetName: 'ASSET_NAME',
        ));
      },
      expect: () => [
        composeDetachUtxoBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          submitState: const SubmitInitial(),
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
      act: (bloc) => bloc.add(ChangeFeeOption(value: FeeOption.Fast())),
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
              composeFn: any(named: 'composeFn'),
              params: any(named: 'params'),
            )).thenAnswer(
          (_) async => (
            mockComposeDetachUtxoResponse,
            FakeVirtualSize(virtualSize: 100, adjustedVirtualSize: 500)
          ),
        );
        when(() => mockComposeDetachUtxoResponse.btcFee).thenReturn(250);
        return composeDetachUtxoBloc;
      },
      seed: () => composeDetachUtxoBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Medium(),
      ),
      act: (bloc) => bloc.add(ComposeTransactionEvent(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<ComposeDetachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitInitial>().having((s) => s.loading, 'loading', true),
        ),
        isA<ComposeDetachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitComposingTransaction<ComposeDetachUtxoResponse, void>>()
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDetachUtxoResponse)
              .having((s) => s.fee, 'fee', 250)
              .having((s) => s.feeRate, 'feeRate', 3),
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
      act: (bloc) => bloc.add(ComposeTransactionEvent(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<ComposeDetachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitInitial>().having((s) => s.loading, 'loading', true),
        ),
        isA<ComposeDetachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitInitial>()
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
      act: (bloc) => bloc.add(FinalizeTransactionEvent(
        composeTransaction: mockComposeDetachUtxoResponse,
        fee: fee,
      )),
      expect: () => [
        isA<ComposeDetachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitFinalizing<ComposeDetachUtxoResponse>>()
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
              'broadcast_tx_detach_utxo',
              properties: any(named: 'properties'),
            )).thenAnswer((_) async {});

        return composeDetachUtxoBloc;
      },
      seed: () => composeDetachUtxoBloc.state.copyWith(
        submitState: SubmitFinalizing<ComposeDetachUtxoResponse>(
          loading: false,
          error: null,
          composeTransaction: mockComposeDetachUtxoResponse,
          fee: 250,
        ),
      ),
      act: (bloc) => bloc.add(SignAndBroadcastTransactionEvent(
        password: password,
      )),
      expect: () => [
        isA<ComposeDetachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitFinalizing<ComposeDetachUtxoResponse>>()
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
              password: any(named: 'password'),
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError'),
            )).thenAnswer((invocation) async {
          final onError = invocation.namedArguments[const Symbol('onError')]
              as Function(String);
          onError('Signing error');
        });

        return composeDetachUtxoBloc;
      },
      seed: () => composeDetachUtxoBloc.state.copyWith(
        submitState: SubmitFinalizing<ComposeDetachUtxoResponse>(
          loading: false,
          error: null,
          composeTransaction: mockComposeDetachUtxoResponse,
          fee: 250,
        ),
      ),
      act: (bloc) => bloc.add(SignAndBroadcastTransactionEvent(
        password: password,
      )),
      expect: () => [
        isA<ComposeDetachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitFinalizing<ComposeDetachUtxoResponse>>()
              .having((s) => s.loading, 'loading', true)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDetachUtxoResponse)
              .having((s) => s.fee, 'fee', 250),
        ),
        isA<ComposeDetachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitFinalizing<ComposeDetachUtxoResponse>>()
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
