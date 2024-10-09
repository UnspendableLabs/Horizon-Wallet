import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/presentation/screens/compose_dispenser/bloc/compose_dispenser_bloc.dart';
import 'package:horizon/presentation/screens/compose_dispenser/bloc/compose_dispenser_state.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/screens/compose_dispenser/usecase/fetch_form_data.dart';
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

class MockFetchDispenserFormDataUseCase extends Mock
    implements FetchDispenserFormDataUseCase {}

class MockComposeTransactionUseCase extends Mock
    implements ComposeTransactionUseCase {}

class MockSignAndBroadcastTransactionUseCase extends Mock
    implements SignAndBroadcastTransactionUseCase {}

class MockWriteLocalTransactionUseCase extends Mock
    implements WriteLocalTransactionUseCase {}

class MockComposeDispenserVerbose extends Mock
    implements ComposeDispenserResponseVerbose {}

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
  late ComposeDispenserBloc composeDispenserBloc;
  late MockComposeRepository mockComposeRepository;
  late MockAnalyticsService mockAnalyticsService;
  late MockFetchDispenserFormDataUseCase mockFetchDispenserFormDataUseCase;
  late MockComposeTransactionUseCase mockComposeTransactionUseCase;
  late MockSignAndBroadcastTransactionUseCase
      mockSignAndBroadcastTransactionUseCase;
  late MockWriteLocalTransactionUseCase mockWriteLocalTransactionUseCase;

  const mockFeeEstimates = FeeEstimates(fast: 5, medium: 3, slow: 1);
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
      source: "test-address");

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
  });
  setUp(() {
    mockComposeRepository = MockComposeRepository();
    mockAnalyticsService = MockAnalyticsService();
    mockFetchDispenserFormDataUseCase = MockFetchDispenserFormDataUseCase();
    mockComposeTransactionUseCase = MockComposeTransactionUseCase();
    mockSignAndBroadcastTransactionUseCase =
        MockSignAndBroadcastTransactionUseCase();
    mockWriteLocalTransactionUseCase = MockWriteLocalTransactionUseCase();

    composeDispenserBloc = ComposeDispenserBloc(
      fetchDispenserFormDataUseCase: mockFetchDispenserFormDataUseCase,
      composeTransactionUseCase: mockComposeTransactionUseCase,
      composeRepository: mockComposeRepository,
      analyticsService: mockAnalyticsService,
      signAndBroadcastTransactionUseCase:
          mockSignAndBroadcastTransactionUseCase,
      writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
    );
  });

  tearDown(() {
    composeDispenserBloc.close();
  });

  group(FetchFormData, () {
    blocTest<ComposeDispenserBloc, ComposeDispenserState>(
      'emits loading and then success states when data is fetched successfully',
      build: () {
        when(() => mockFetchDispenserFormDataUseCase.call(any()))
            .thenAnswer((_) async => (mockBalances, mockFeeEstimates));
        return composeDispenserBloc;
      },
      act: (bloc) {
        bloc.add(FetchFormData(currentAddress: mockAddress));
      },
      expect: () => [
        composeDispenserBloc.state.copyWith(
          feeState: const FeeState.loading(),
          balancesState: const BalancesState.loading(),
          submitState: const SubmitInitial(),
        ),
        composeDispenserBloc.state.copyWith(
          balancesState: BalancesState.success(mockBalances),
          feeState: const FeeState.success(mockFeeEstimates),
        ),
      ],
    );

    blocTest<ComposeDispenserBloc, ComposeDispenserState>(
      'emits error state when fetching balances fails',
      build: () {
        when(() => mockFetchDispenserFormDataUseCase.call(any()))
            .thenThrow(FetchBalancesException('Failed to fetch balances'));
        return composeDispenserBloc;
      },
      act: (bloc) {
        bloc.add(FetchFormData(currentAddress: mockAddress));
      },
      expect: () => [
        composeDispenserBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          submitState: const SubmitInitial(),
        ),
        composeDispenserBloc.state.copyWith(
          balancesState: const BalancesState.error('Failed to fetch balances'),
        ),
      ],
    );

    blocTest<ComposeDispenserBloc, ComposeDispenserState>(
      'emits error state when fetching fee estimates fails',
      build: () {
        when(() => mockFetchDispenserFormDataUseCase.call(any())).thenThrow(
            FetchFeeEstimatesException('Failed to fetch fee estimates'));
        return composeDispenserBloc;
      },
      act: (bloc) {
        bloc.add(FetchFormData(currentAddress: mockAddress));
      },
      expect: () => [
        composeDispenserBloc.state.copyWith(
          feeState: const FeeState.loading(),
          submitState: const SubmitInitial(),
        ),
        composeDispenserBloc.state.copyWith(
          feeState: const FeeState.error('Failed to fetch fee estimates'),
        ),
      ],
    );
    blocTest<ComposeDispenserBloc, ComposeDispenserState>(
      'emits error state when unexpected error occurs',
      build: () {
        when(() => mockFetchDispenserFormDataUseCase.call(any()))
            .thenThrow(Exception('Unexpected'));
        return composeDispenserBloc;
      },
      act: (bloc) {
        bloc.add(FetchFormData(currentAddress: mockAddress));
      },
      expect: () => [
        composeDispenserBloc.state.copyWith(
          feeState: const FeeState.loading(),
          balancesState: const BalancesState.loading(),
          submitState: const SubmitInitial(),
        ),
        composeDispenserBloc.state.copyWith(
          feeState: const FeeState.error(
              'An unexpected error occurred: Exception: Unexpected'),
          balancesState: const BalancesState.error(
              'An unexpected error occurred: Exception: Unexpected'),
        ),
      ],
    );
  });
  group('ComposeTransactionEvent', () {
    blocTest<ComposeDispenserBloc, ComposeDispenserState>;

    blocTest<ComposeDispenserBloc, ComposeDispenserState>(
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

        return composeDispenserBloc;
      },
      seed: () => composeDispenserBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Medium(),
      ),
      act: (bloc) => bloc.add(ComposeTransactionEvent(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<ComposeDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitInitial>().having((s) => s.loading, 'loading', true),
        ),
        isA<ComposeDispenserState>().having(
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

    blocTest<ComposeDispenserBloc, ComposeDispenserState>(
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

        return composeDispenserBloc;
      },
      seed: () => composeDispenserBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Custom(10),
      ),
      act: (bloc) => bloc.add(ComposeTransactionEvent(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<ComposeDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitInitial>().having((s) => s.loading, 'loading', true),
        ),
        isA<ComposeDispenserState>().having(
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

    blocTest<ComposeDispenserBloc, ComposeDispenserState>(
      'emits SubmitInitial with error when transaction composition fails',
      build: () {
        when(() => mockComposeTransactionUseCase
                .call<ComposeDispenserParams, ComposeDispenserResponseVerbose>(
              feeRate: any(named: 'feeRate'),
              source: any(named: 'source'),
              composeFn: any(named: 'composeFn'),
              params: any(named: 'params'),
            )).thenThrow(ComposeTransactionException('Compose error'));

        return composeDispenserBloc;
      },
      seed: () => composeDispenserBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Medium(),
      ),
      act: (bloc) => bloc.add(ComposeTransactionEvent(
        params: composeTransactionParams,
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<ComposeDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitInitial>().having((s) => s.loading, 'loading', true),
        ),
        isA<ComposeDispenserState>().having(
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

    blocTest<ComposeDispenserBloc, ComposeDispenserState>(
      'emits SubmitFinalizing when FinalizeTransactionEvent is added',
      build: () => composeDispenserBloc,
      act: (bloc) => bloc.add(FinalizeTransactionEvent(
        composeTransaction: mockComposeDispenserVerbose,
        fee: fee,
      )),
      expect: () => [
        isA<ComposeDispenserState>().having(
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

    blocTest<ComposeDispenserBloc, ComposeDispenserState>(
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
          onSuccess(txHex, txHash, sourceAddress, 'destination-address', 1000,
              'ASSET_NAME');
        });

        when(() => mockWriteLocalTransactionUseCase.call(txHex, txHash))
            .thenAnswer((_) async {});

        when(() => mockAnalyticsService.trackEvent(any()))
            .thenAnswer((_) async {});

        return composeDispenserBloc;
      },
      seed: () => composeDispenserBloc.state.copyWith(
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
        isA<ComposeDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitFinalizing<ComposeDispenserResponseVerbose>>()
              .having((s) => s.loading, 'loading', true)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDispenserVerbose)
              .having((s) => s.fee, 'fee', 250),
        ),
        isA<ComposeDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitSuccess>()
              .having((s) => s.transactionHex, 'transactionHex', txHex)
              .having((s) => s.sourceAddress, 'sourceAddress', sourceAddress),
        ),
      ],
      verify: (_) {
        verify(() => mockAnalyticsService.trackEvent('broadcast_tx_dispenser'))
            .called(1);
      },
    );
    blocTest<ComposeDispenserBloc, ComposeDispenserState>(
      'emits SubmitFinalizing with error when transaction signing fails',
      build: () {
        when(() => mockSignAndBroadcastTransactionUseCase.call(
              password: any(named: 'password'),
              extractParams: any(named: 'extractParams'),
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError'),
            )).thenAnswer((invocation) async {
          final onError =
              invocation.namedArguments[const Symbol('onError')] as Function;
          onError('Signing error');
        });

        return composeDispenserBloc;
      },
      seed: () => composeDispenserBloc.state.copyWith(
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
        isA<ComposeDispenserState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitFinalizing<ComposeDispenserResponseVerbose>>()
              .having((s) => s.loading, 'loading', true)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDispenserVerbose)
              .having((s) => s.fee, 'fee', 250),
        ),
        isA<ComposeDispenserState>().having(
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

    // Successful Sign and Broadcast
  });
}
