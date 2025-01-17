import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_attach_utxo.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/block_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/bloc/compose_attach_utxo_bloc.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/bloc/compose_attach_utxo_state.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/usecase/fetch_form_data.dart';
import 'package:mocktail/mocktail.dart';

class MockComposeRepository extends Mock implements ComposeRepository {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockLogger extends Mock implements Logger {}

class MockFetchComposeAttachUtxoFormDataUseCase extends Mock
    implements FetchComposeAttachUtxoFormDataUseCase {}

class MockComposeTransactionUseCase extends Mock
    implements ComposeTransactionUseCase {}

class MockSignAndBroadcastTransactionUseCase extends Mock
    implements SignAndBroadcastTransactionUseCase {}

class MockWriteLocalTransactionUseCase extends Mock
    implements WriteLocalTransactionUseCase {}

class MockBlockRepository extends Mock implements BlockRepository {}

class MockErrorService extends Mock implements ErrorService {}

class MockComposeAttachUtxoResponse extends Mock
    implements ComposeAttachUtxoResponse {
  @override
  ComposeAttachUtxoResponseParams get params =>
      MockComposeAttachUtxoResponseParams();

  @override
  String get rawtransaction => "rawtransaction";
}

class MockComposeAttachUtxoResponseParams extends Mock
    implements ComposeAttachUtxoResponseParams {
  @override
  String get source => "source";

  @override
  int get quantity => 10;

  @override
  String get asset => "ASSET_NAME";

  // Include other necessary overrides if needed
}

class MockCacheProvider extends Mock implements CacheProvider {}

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

void main() {
  late ComposeAttachUtxoBloc composeAttachUtxoBloc;
  late MockComposeRepository mockComposeRepository;
  late MockAnalyticsService mockAnalyticsService;
  late MockLogger mockLogger;
  late MockFetchComposeAttachUtxoFormDataUseCase
      mockFetchComposeAttachUtxoFormDataUseCase;
  late MockComposeTransactionUseCase mockComposeTransactionUseCase;
  late MockSignAndBroadcastTransactionUseCase
      mockSignAndBroadcastTransactionUseCase;
  late MockWriteLocalTransactionUseCase mockWriteLocalTransactionUseCase;
  late MockBlockRepository mockBlockRepository;
  late MockCacheProvider mockCacheProvider;
  late MockErrorService mockErrorService;
  const mockFeeEstimates = FeeEstimates(fast: 5, medium: 3, slow: 1);
  final mockBalance = Balance(
    asset: 'ASSET_NAME',
    quantity: 100,
    address: 'ADDRESS',
    quantityNormalized: '100',
    assetInfo: const AssetInfo(
      divisible: true,
      assetLongname: 'ASSET_NAME',
    ),
  );
  final mockComposeAttachUtxoResponse = MockComposeAttachUtxoResponse();

  final composeTransactionParams = ComposeAttachUtxoEventParams(
    asset: 'ASSET_NAME',
    quantity: 10,
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
    registerFallbackValue(ComposeAttachUtxoParams(
      asset: 'ASSET_NAME',
      quantity: 10,
      address: 'ADDRESS',
    ));
  });

  setUp(() {
    mockComposeRepository = MockComposeRepository();
    mockAnalyticsService = MockAnalyticsService();
    mockLogger = MockLogger();
    mockFetchComposeAttachUtxoFormDataUseCase =
        MockFetchComposeAttachUtxoFormDataUseCase();
    mockComposeTransactionUseCase = MockComposeTransactionUseCase();
    mockSignAndBroadcastTransactionUseCase =
        MockSignAndBroadcastTransactionUseCase();
    mockWriteLocalTransactionUseCase = MockWriteLocalTransactionUseCase();
    mockBlockRepository = MockBlockRepository();
    mockCacheProvider = MockCacheProvider();
    mockErrorService = MockErrorService();

    // Register the ErrorService mock with GetIt
    GetIt.I.registerSingleton<ErrorService>(mockErrorService);

    composeAttachUtxoBloc = ComposeAttachUtxoBloc(
      composeRepository: mockComposeRepository,
      analyticsService: mockAnalyticsService,
      logger: mockLogger,
      fetchComposeAttachUtxoFormDataUseCase:
          mockFetchComposeAttachUtxoFormDataUseCase,
      composeTransactionUseCase: mockComposeTransactionUseCase,
      signAndBroadcastTransactionUseCase:
          mockSignAndBroadcastTransactionUseCase,
      writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
      blockRepository: mockBlockRepository,
      cacheProvider: mockCacheProvider,
      initialFairminterTxHash: null,
    );
  });

  tearDown(() {
    composeAttachUtxoBloc.close();
    // Reset GetIt instance after each test
    GetIt.I.reset();
  });

  group('FetchFormData', () {
    blocTest<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
      'emits loading and then success states when data is fetched successfully',
      build: () {
        when(() => mockFetchComposeAttachUtxoFormDataUseCase.call(
              any(),
            )).thenAnswer(
          (_) async => (
            mockFeeEstimates,
            [mockBalance],
            0,
          ),
        );
        return composeAttachUtxoBloc;
      },
      act: (bloc) {
        bloc.add(FetchFormData(
          currentAddress: 'test-address',
        ));
      },
      expect: () => [
        composeAttachUtxoBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          submitState: const SubmitInitial(),
          xcpFeeEstimate: '',
        ),
        composeAttachUtxoBloc.state.copyWith(
          balancesState: BalancesState.success([mockBalance]),
          feeState: const FeeState.success(mockFeeEstimates),
          xcpFeeEstimate: '0',
        ),
      ],
    );

    blocTest<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
      'emits error when balances do not include xcp and xcp fee > 0',
      build: () {
        when(() => mockFetchComposeAttachUtxoFormDataUseCase.call(
              any(),
            )).thenAnswer(
          (_) async => (
            mockFeeEstimates,
            [mockBalance],
            5,
          ),
        );
        return composeAttachUtxoBloc;
      },
      act: (bloc) {
        bloc.add(FetchFormData(
          currentAddress: 'test-address',
        ));
      },
      expect: () => [
        composeAttachUtxoBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          submitState: const SubmitInitial(),
          xcpFeeEstimate: '',
        ),
        composeAttachUtxoBloc.state.copyWith(
          balancesState: const BalancesState.error(
              'Insufficient XCP balance for attach. Required: 0.00000005. Current XCP balance: 0'),
          xcpFeeEstimate: '0.00000005',
        ),
      ],
    );

    blocTest<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
      'emits error when xcp balance does not cover the xcp fee',
      build: () {
        when(() => mockFetchComposeAttachUtxoFormDataUseCase.call(
              any(),
            )).thenAnswer(
          (_) async => (
            mockFeeEstimates,
            [
              mockBalance,
              Balance(
                  asset: 'XCP',
                  quantity: 5,
                  address: 'ADDRESS',
                  quantityNormalized: '0.00000005',
                  assetInfo:
                      const AssetInfo(divisible: true, assetLongname: 'XCP'))
            ],
            10,
          ),
        );
        return composeAttachUtxoBloc;
      },
      act: (bloc) {
        bloc.add(FetchFormData(
          currentAddress: 'test-address',
        ));
      },
      expect: () => [
        composeAttachUtxoBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          submitState: const SubmitInitial(),
          xcpFeeEstimate: '',
        ),
        composeAttachUtxoBloc.state.copyWith(
          balancesState: const BalancesState.error(
              'Insufficient XCP balance for attach. Required: 0.00000010. Current XCP balance: 0.00000005'),
          xcpFeeEstimate: '0.00000010',
        ),
      ],
    );

    blocTest<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
      'emits error state when fetching fee estimates fails',
      build: () {
        when(() => mockFetchComposeAttachUtxoFormDataUseCase.call(
              any(),
            )).thenThrow(
          FetchFeeEstimatesException('Failed to fetch fee estimates'),
        );
        return composeAttachUtxoBloc;
      },
      act: (bloc) {
        bloc.add(FetchFormData(
          currentAddress: 'test-address',
        ));
      },
      expect: () => [
        composeAttachUtxoBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          submitState: const SubmitInitial(),
        ),
        composeAttachUtxoBloc.state.copyWith(
          feeState: const FeeState.error('Failed to fetch fee estimates'),
        ),
      ],
    );

    blocTest<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
      'emits error state when fetching xcp estimate fails',
      build: () {
        when(() => mockFetchComposeAttachUtxoFormDataUseCase.call(
              any(),
            )).thenThrow(
          FetchAttachXcpFeesException('Failed to fetch xcp estimate'),
        );

        return composeAttachUtxoBloc;
      },
      act: (bloc) {
        bloc.add(FetchFormData(
          currentAddress: 'test-address',
        ));
      },
      expect: () => [
        composeAttachUtxoBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          submitState: const SubmitInitial(),
        ),
        composeAttachUtxoBloc.state.copyWith(
          balancesState:
              const BalancesState.error('Failed to fetch xcp estimate'),
        ),
      ],
    );
  });

  group('ChangeFeeOption', () {
    blocTest<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
      'emits new state with updated fee option',
      build: () => composeAttachUtxoBloc,
      act: (bloc) => bloc.add(ChangeFeeOption(value: FeeOption.Fast())),
      expect: () => [
        isA<ComposeAttachUtxoState>().having(
          (state) => state.feeOption,
          'feeOption',
          isA<FeeOption.Fast>(),
        ),
      ],
    );
  });

  group('ComposeTransactionEvent', () {
    blocTest<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
      'emits SubmitComposingTransaction when transaction composition succeeds',
      build: () {
        when(() => mockComposeTransactionUseCase
                .call<ComposeAttachUtxoParams, ComposeAttachUtxoResponse>(
              feeRate: any(named: 'feeRate'),
              source: any(named: 'source'),
              composeFn: any(named: 'composeFn'),
              params: any(named: 'params'),
            )).thenAnswer(
          (_) async => mockComposeAttachUtxoResponse,
        );
        when(() => mockComposeAttachUtxoResponse.btcFee).thenReturn(250);
        when(() => mockComposeAttachUtxoResponse.signedTxEstimatedSize)
            .thenReturn(SignedTxEstimatedSize(
          virtualSize: 100,
          adjustedVirtualSize: 100,
          sigopsCount: 1,
        ));
        return composeAttachUtxoBloc;
      },
      seed: () => composeAttachUtxoBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Medium(),
      ),
      act: (bloc) => bloc.add(ComposeTransactionEvent(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<ComposeAttachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitInitial>().having((s) => s.loading, 'loading', true),
        ),
        isA<ComposeAttachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitComposingTransaction<ComposeAttachUtxoResponse, void>>()
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeAttachUtxoResponse)
              .having((s) => s.fee, 'fee', 250)
              .having((s) => s.feeRate, 'feeRate', 3),
        ),
      ],
    );

    blocTest<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
      'emits SubmitInitial with error when transaction composition fails',
      build: () {
        when(() => mockComposeTransactionUseCase
                .call<ComposeAttachUtxoParams, ComposeAttachUtxoResponse>(
              feeRate: any(named: 'feeRate'),
              source: any(named: 'source'),
              composeFn: any(named: 'composeFn'),
              params: any(named: 'params'),
            )).thenThrow(
          ComposeTransactionException('Compose error', StackTrace.current),
        );
        return composeAttachUtxoBloc;
      },
      seed: () => composeAttachUtxoBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Medium(),
      ),
      act: (bloc) => bloc.add(ComposeTransactionEvent(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<ComposeAttachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitInitial>().having((s) => s.loading, 'loading', true),
        ),
        isA<ComposeAttachUtxoState>().having(
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
    final mockComposeAttachUtxoResponse = MockComposeAttachUtxoResponse();

    blocTest<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
      'emits SubmitFinalizing when FinalizeTransactionEvent is added',
      build: () => composeAttachUtxoBloc,
      act: (bloc) => bloc.add(FinalizeTransactionEvent(
        composeTransaction: mockComposeAttachUtxoResponse,
        fee: fee,
      )),
      expect: () => [
        isA<ComposeAttachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitFinalizing<ComposeAttachUtxoResponse>>()
              .having((s) => s.loading, 'loading', false)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeAttachUtxoResponse)
              .having((s) => s.fee, 'fee', fee),
        ),
      ],
    );
  });

  group('SignAndBroadcastTransactionEvent', () {
    const password = 'test-password';
    const txHex = 'rawtransaction';
    const txHash = 'transaction-hash';
    const sourceAddress = 'source';

    blocTest<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
      'emits SubmitSuccess when transaction is signed and broadcasted successfully',
      build: () {
        when(() => mockSignAndBroadcastTransactionUseCase.call(
              source: sourceAddress,
              rawtransaction: txHex,
              password: any(named: 'password'),
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError'),
            )).thenAnswer((invocation) async {
          final onSuccess =
              invocation.namedArguments[const Symbol('onSuccess')] as Function;
          await onSuccess(txHex, txHash);
        });
        when(() => mockWriteLocalTransactionUseCase.call(txHex, txHash))
            .thenAnswer((_) async {});
        when(() => mockCacheProvider.getValue(sourceAddress))
            .thenReturn(['existing_hash']);
        when(() => mockCacheProvider.setObject(sourceAddress, any()))
            .thenAnswer((_) async {});
        when(() => mockAnalyticsService.trackAnonymousEvent(
              'broadcast_tx_attach_utxo',
              properties: any(named: 'properties'),
            )).thenAnswer((_) async {});

        return composeAttachUtxoBloc;
      },
      seed: () => composeAttachUtxoBloc.state.copyWith(
        submitState: SubmitFinalizing<ComposeAttachUtxoResponse>(
          loading: false,
          error: null,
          composeTransaction: mockComposeAttachUtxoResponse,
          fee: 250,
        ),
      ),
      act: (bloc) => bloc.add(SignAndBroadcastTransactionEvent(
        password: password,
      )),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<ComposeAttachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitFinalizing<ComposeAttachUtxoResponse>>()
              .having((s) => s.loading, 'loading', true)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeAttachUtxoResponse)
              .having((s) => s.fee, 'fee', 250),
        ),
        isA<ComposeAttachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitSuccess>()
              .having((s) => s.transactionHex, 'transactionHex', txHex)
              .having((s) => s.sourceAddress, 'sourceAddress', sourceAddress),
        ),
      ],
      verify: (_) {
        verify(() => mockAnalyticsService.trackAnonymousEvent(
              'broadcast_tx_attach_utxo',
              properties: any(named: 'properties'),
            )).called(1);

        verify(() => mockCacheProvider.getValue(sourceAddress)).called(1);
        verify(() => mockCacheProvider.setObject(
              sourceAddress,
              any(
                  that: predicate<List<dynamic>>((list) =>
                      list.length == 2 &&
                      list.contains('existing_hash') &&
                      list.contains(txHash))),
            )).called(1);
      },
    );

    blocTest<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
      'emits SubmitFinalizing with error when transaction signing fails',
      build: () {
        when(() => mockSignAndBroadcastTransactionUseCase.call(
              source: any(named: 'source'),
              rawtransaction: any(named: 'rawtransaction'),
              password: any(named: 'password'),
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError'),
            )).thenAnswer((invocation) async {
          final onError =
              invocation.namedArguments[const Symbol('onError')] as Function;
          onError('Signing error');
        });

        return composeAttachUtxoBloc;
      },
      seed: () => composeAttachUtxoBloc.state.copyWith(
        submitState: SubmitFinalizing<ComposeAttachUtxoResponse>(
          loading: false,
          error: null,
          composeTransaction: mockComposeAttachUtxoResponse,
          fee: 250,
        ),
      ),
      act: (bloc) => bloc.add(SignAndBroadcastTransactionEvent(
        password: password,
      )),
      expect: () => [
        isA<ComposeAttachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitFinalizing<ComposeAttachUtxoResponse>>()
              .having((s) => s.loading, 'loading', true)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeAttachUtxoResponse)
              .having((s) => s.fee, 'fee', 250),
        ),
        isA<ComposeAttachUtxoState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitFinalizing<ComposeAttachUtxoResponse>>()
              .having((s) => s.loading, 'loading', false)
              .having((s) => s.error, 'error', 'Signing error')
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeAttachUtxoResponse)
              .having((s) => s.fee, 'fee', 250),
        ),
      ],
    );
  });

  group('SignAndBroadcastTransaction', () {
    blocTest<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
      'should update cache when broadcasting an attach transaction',
      build: () {
        // const source = 'source-address';
        when(() => mockSignAndBroadcastTransactionUseCase.call(
              password: any(named: 'password'),
              source: any(named: 'source'),
              rawtransaction: any(named: 'rawtransaction'),
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError'),
            )).thenAnswer((invocation) async {
          final onSuccess = invocation.namedArguments[const Symbol('onSuccess')]
              as Function(String, String);
          await onSuccess('txHex', 'test_hash');
        });

        when(() => mockWriteLocalTransactionUseCase.call(any(), any()))
            .thenAnswer((_) async {});

        // Setup cache behavior
        when(() => mockCacheProvider.getValue('source'))
            .thenReturn(['existing_hash']);
        when(() => mockCacheProvider.setObject('source', any()))
            .thenAnswer((_) async {});

        return composeAttachUtxoBloc;
      },
      seed: () => ComposeAttachUtxoState(
        submitState: SubmitFinalizing<ComposeAttachUtxoResponse>(
          loading: false,
          error: null,
          composeTransaction: mockComposeAttachUtxoResponse,
          fee: 1000,
        ),
        feeOption: FeeOption.Medium(),
        balancesState: const BalancesState.initial(),
        feeState: const FeeState.initial(),
        xcpFeeEstimate: '',
      ),
      act: (bloc) => bloc.add(
        SignAndBroadcastTransactionEvent(password: 'password'),
      ),
      verify: (_) {
        verify(() => mockCacheProvider.getValue('source')).called(1);
        verify(() => mockCacheProvider.setObject(
              'source',
              any(
                  that: predicate<List<dynamic>>((list) =>
                      list.length == 2 &&
                      list.contains('existing_hash') &&
                      list.contains('test_hash'))),
            )).called(1);
      },
    );

    blocTest<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
      'should initialize cache when no previous hashes exist',
      build: () {
        when(() => mockSignAndBroadcastTransactionUseCase.call(
              password: any(named: 'password'),
              source: any(named: 'source'),
              rawtransaction: any(named: 'rawtransaction'),
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError'),
            )).thenAnswer((invocation) async {
          final onSuccess = invocation.namedArguments[const Symbol('onSuccess')]
              as Function(String, String);
          await onSuccess('txHex', 'test_hash');
        });

        when(() => mockWriteLocalTransactionUseCase.call(any(), any()))
            .thenAnswer((_) async {});

        // Setup cache behavior for empty initial state
        when(() => mockCacheProvider.getValue('source')).thenReturn(null);
        when(() => mockCacheProvider.setObject('source', any()))
            .thenAnswer((_) async {});

        return composeAttachUtxoBloc;
      },
      seed: () => ComposeAttachUtxoState(
        submitState: SubmitFinalizing<ComposeAttachUtxoResponse>(
          loading: false,
          error: null,
          composeTransaction: mockComposeAttachUtxoResponse,
          fee: 1000,
        ),
        feeOption: FeeOption.Medium(),
        balancesState: const BalancesState.initial(),
        feeState: const FeeState.initial(),
        xcpFeeEstimate: '',
      ),
      act: (bloc) => bloc.add(
        SignAndBroadcastTransactionEvent(password: 'password'),
      ),
      verify: (_) {
        verify(() => mockCacheProvider.getValue('source')).called(1);
        verify(() => mockCacheProvider.setObject(
              'source',
              any(
                  that: predicate<List<dynamic>>((list) =>
                      list.length == 1 && list.contains('test_hash'))),
            )).called(1);
      },
    );
  });
}
