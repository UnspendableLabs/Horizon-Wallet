import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_destroy.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_destroy/bloc/compose_destroy_bloc.dart';
import 'package:horizon/presentation/screens/compose_destroy/bloc/compose_destroy_state.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockBalanceRepository extends Mock implements BalanceRepository {}

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

class MockErrorService extends Mock implements ErrorService {}

class MockComposeDestroyResponse extends Mock
    implements ComposeDestroyResponse {
  @override
  ComposeDestroyResponseParams get params => MockComposeDestroyResponseParams();

  @override
  String get rawtransaction => "rawtransaction";
}

class MockComposeDestroyResponseParams extends Mock
    implements ComposeDestroyResponseParams {
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
  late ComposeDestroyBloc composeDestroyBloc;
  late MockBalanceRepository mockBalanceRepository;
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
  final mockComposeDestroyResponse = MockComposeDestroyResponse();

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

  final composeTransactionParams = ComposeDestroyEventParams(
    assetName: 'ASSET_NAME',
    quantity: 10,
    tag: 'test-tag',
  );

  setUpAll(() {
    registerFallbackValue(FeeOption.Medium());
    registerFallbackValue(composeTransactionParams);
    registerFallbackValue(ComposeTransactionEvent(
      params: composeTransactionParams,
      sourceAddress: 'source-address',
    ));
    registerFallbackValue(SignAndBroadcastTransactionEvent(
      password: 'password',
    ));
    registerFallbackValue(ComposeDestroyParams(
      source: 'source-address',
      asset: 'ASSET_NAME',
      quantity: 10,
      tag: 'test-tag',
    ));
  });

  setUp(() {
    mockBalanceRepository = MockBalanceRepository();
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

    composeDestroyBloc = ComposeDestroyBloc(
      balanceRepository: mockBalanceRepository,
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
    composeDestroyBloc.close();
    // Reset GetIt instance after each test
    GetIt.I.reset();
  });

  group('FetchFormData', () {
    blocTest<ComposeDestroyBloc, ComposeDestroyState>(
      'emits loading and then success states when data is fetched successfully',
      build: () {
        when(() => mockBalanceRepository.getBalancesForAddress(
              any(),
              any(),
            )).thenAnswer((_) async => [mockBalance]);
        when(() => mockGetFeeEstimatesUseCase.call())
            .thenAnswer((_) async => mockFeeEstimates);
        return composeDestroyBloc;
      },
      act: (bloc) => bloc.add(FetchFormData(
        currentAddress: 'test-address',
      )),
      expect: () => [
        composeDestroyBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          submitState: const SubmitInitial(),
        ),
        composeDestroyBloc.state.copyWith(
          balancesState: BalancesState.success([mockBalance]),
          feeState: const FeeState.success(mockFeeEstimates),
        ),
      ],
    );

    blocTest<ComposeDestroyBloc, ComposeDestroyState>(
      'emits error state when fetching balances fails',
      build: () {
        when(() => mockBalanceRepository.getBalancesForAddress(
              any(),
              any(),
            )).thenThrow(Exception('Failed to fetch balances'));
        return composeDestroyBloc;
      },
      act: (bloc) => bloc.add(FetchFormData(
        currentAddress: 'test-address',
      )),
      expect: () => [
        composeDestroyBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          submitState: const SubmitInitial(),
        ),
        composeDestroyBloc.state.copyWith(
          balancesState:
              const BalancesState.error('Exception: Failed to fetch balances'),
        ),
      ],
    );
  });

  group('ChangeFeeOption', () {
    blocTest<ComposeDestroyBloc, ComposeDestroyState>(
      'emits new state with updated fee option',
      build: () => composeDestroyBloc,
      act: (bloc) => bloc.add(ChangeFeeOption(value: FeeOption.Fast())),
      expect: () => [
        isA<ComposeDestroyState>().having(
          (state) => state.feeOption,
          'feeOption',
          isA<FeeOption.Fast>(),
        ),
      ],
    );
  });

  group('ComposeTransaction', () {
    blocTest<ComposeDestroyBloc, ComposeDestroyState>(
      'emits SubmitComposingTransaction when transaction composition succeeds',
      build: () {
        when(
            () => mockComposeTransactionUseCase
                    .call<ComposeDestroyParams, ComposeDestroyResponse>(
                  feeRate: any(named: 'feeRate'),
                  source: any(named: 'source'),
                  params: any(named: 'params'),
                  composeFn: any(named: 'composeFn'),
                )).thenAnswer((_) async => (
              mockComposeDestroyResponse,
              FakeVirtualSize(virtualSize: 100, adjustedVirtualSize: 500),
            ));
        when(() => mockComposeDestroyResponse.btcFee).thenReturn(250);
        return composeDestroyBloc;
      },
      seed: () => composeDestroyBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Medium(),
      ),
      act: (bloc) => bloc.add(ComposeTransactionEvent(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<ComposeDestroyState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitInitial>().having((s) => s.loading, 'loading', true),
        ),
        isA<ComposeDestroyState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitComposingTransaction<ComposeDestroyResponse, void>>()
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDestroyResponse)
              .having((s) => s.fee, 'fee', 250)
              .having((s) => s.feeRate, 'feeRate', 3),
        ),
      ],
    );
  });

  group('SignAndBroadcastTransaction', () {
    const password = 'test-password';
    const txHex = 'rawtransaction';
    const txHash = 'transaction-hash';
    const sourceAddress = 'source';

    blocTest<ComposeDestroyBloc, ComposeDestroyState>(
      'emits SubmitSuccess when transaction is signed and broadcasted successfully',
      build: () {
        when(() => mockSignAndBroadcastTransactionUseCase.call(
              password: password,
              source: sourceAddress,
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
              'broadcast_tx_destroy',
              properties: any(named: 'properties'),
            )).thenAnswer((_) async {});

        return composeDestroyBloc;
      },
      seed: () => composeDestroyBloc.state.copyWith(
        submitState: SubmitFinalizing<ComposeDestroyResponse>(
          loading: false,
          error: null,
          composeTransaction: mockComposeDestroyResponse,
          fee: 250,
        ),
      ),
      act: (bloc) => bloc.add(SignAndBroadcastTransactionEvent(
        password: password,
      )),
      expect: () => [
        isA<ComposeDestroyState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitFinalizing<ComposeDestroyResponse>>()
              .having((s) => s.loading, 'loading', true)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDestroyResponse)
              .having((s) => s.fee, 'fee', 250),
        ),
        isA<ComposeDestroyState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitSuccess>()
              .having((s) => s.transactionHex, 'transactionHex', txHex)
              .having((s) => s.sourceAddress, 'sourceAddress', sourceAddress),
        ),
      ],
      verify: (_) {
        verify(() => mockAnalyticsService.trackAnonymousEvent(
              'broadcast_tx_destroy',
              properties: any(named: 'properties'),
            )).called(1);
      },
    );

    blocTest<ComposeDestroyBloc, ComposeDestroyState>(
      'emits error state when signing fails',
      build: () {
        when(() => mockSignAndBroadcastTransactionUseCase.call(
              password: password,
              source: any(named: 'source'),
              rawtransaction: any(named: 'rawtransaction'),
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError'),
            )).thenAnswer((invocation) async {
          final onError =
              invocation.namedArguments[const Symbol('onError')] as Function;
          onError('Signing error');
        });
        return composeDestroyBloc;
      },
      seed: () => composeDestroyBloc.state.copyWith(
        submitState: SubmitFinalizing<ComposeDestroyResponse>(
          loading: false,
          error: null,
          composeTransaction: mockComposeDestroyResponse,
          fee: 250,
        ),
      ),
      act: (bloc) => bloc.add(SignAndBroadcastTransactionEvent(
        password: password,
      )),
      expect: () => [
        isA<ComposeDestroyState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitFinalizing<ComposeDestroyResponse>>()
              .having((s) => s.loading, 'loading', true)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDestroyResponse)
              .having((s) => s.fee, 'fee', 250),
        ),
        isA<ComposeDestroyState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitFinalizing<ComposeDestroyResponse>>()
              .having((s) => s.loading, 'loading', false)
              .having((s) => s.error, 'error', 'Signing error')
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDestroyResponse)
              .having((s) => s.fee, 'fee', 250),
        ),
      ],
    );
  });
}
