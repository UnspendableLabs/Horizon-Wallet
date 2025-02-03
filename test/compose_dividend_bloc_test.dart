import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_dividend.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_dividend/bloc/compose_dividend_bloc.dart';
import 'package:horizon/presentation/screens/compose_dividend/bloc/compose_dividend_state.dart';
import 'package:horizon/presentation/screens/compose_dividend/usecase/fetch_form_data.dart';
import 'package:mocktail/mocktail.dart';

import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';

// Mock classes
class MockComposeRepository extends Mock implements ComposeRepository {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockFetchDividendFormDataUseCase extends Mock
    implements FetchDividendFormDataUseCase {}

class MockComposeTransactionUseCase extends Mock
    implements ComposeTransactionUseCase {}

class MockSignAndBroadcastTransactionUseCase extends Mock
    implements SignAndBroadcastTransactionUseCase {}

class MockWriteLocalTransactionUseCase extends Mock
    implements WriteLocalTransactionUseCase {}

class MockComposeDividendResponse extends Mock
    implements ComposeDividendResponse {}

class MockLogger extends Mock implements Logger {}

class MockComposeDividendResponseParams extends Mock
    implements ComposeDividendResponseParams {}

class MockErrorService extends Mock implements ErrorService {}

class MockInMemoryKeyRepository extends Mock implements InMemoryKeyRepository {}

class FakeVirtualSize extends Fake implements VirtualSize {
  @override
  final int virtualSize;
  @override
  final int adjustedVirtualSize;

  FakeVirtualSize(
      {required this.virtualSize, required this.adjustedVirtualSize});
}

void main() {
  late ComposeDividendBloc composeDividendBloc;
  late MockComposeRepository mockComposeRepository;
  late MockAnalyticsService mockAnalyticsService;
  late MockFetchDividendFormDataUseCase mockFetchDividendFormDataUseCase;
  late MockComposeTransactionUseCase mockComposeTransactionUseCase;
  late MockSignAndBroadcastTransactionUseCase
      mockSignAndBroadcastTransactionUseCase;
  late MockWriteLocalTransactionUseCase mockWriteLocalTransactionUseCase;
  late MockLogger mockLogger;
  late MockErrorService mockErrorService;
  late MockInMemoryKeyRepository mockInMemoryKeyRepository;

  const mockFeeEstimates = FeeEstimates(fast: 5, medium: 3, slow: 1);
  final mockBalance = Balance(
    asset: 'DIVIDEND_ASSET',
    quantity: 100,
    address: 'ADDRESS',
    quantityNormalized: '100',
    assetInfo: const AssetInfo(
      divisible: true,
      assetLongname: 'DIVIDEND_ASSET_LONG_NAME',
    ),
  );

  final mockComposeDividendResponse = MockComposeDividendResponse();

  final composeTransactionParams = ComposeDividendParams(
    source: 'source-address',
    asset: 'ASSET_NAME',
    quantityPerUnit: 100,
    dividendAsset: 'DIVIDEND_ASSET',
  );

  setUpAll(() {
    registerFallbackValue(FeeOption.Medium());
    registerFallbackValue(composeTransactionParams);
    registerFallbackValue(SignAndBroadcastFormSubmitted(password: 'password'));
  });

  setUp(() {
    mockComposeRepository = MockComposeRepository();
    mockAnalyticsService = MockAnalyticsService();
    mockFetchDividendFormDataUseCase = MockFetchDividendFormDataUseCase();
    mockComposeTransactionUseCase = MockComposeTransactionUseCase();
    mockSignAndBroadcastTransactionUseCase =
        MockSignAndBroadcastTransactionUseCase();
    mockWriteLocalTransactionUseCase = MockWriteLocalTransactionUseCase();
    mockLogger = MockLogger();
    mockErrorService = MockErrorService();
    mockInMemoryKeyRepository = MockInMemoryKeyRepository();

    // Register the ErrorService mock with GetIt
    GetIt.I.registerSingleton<ErrorService>(mockErrorService);

    composeDividendBloc = ComposeDividendBloc(
      passwordRequired: true,
      inMemoryKeyRepository: mockInMemoryKeyRepository,
      fetchDividendFormDataUseCase: mockFetchDividendFormDataUseCase,
      composeTransactionUseCase: mockComposeTransactionUseCase,
      composeRepository: mockComposeRepository,
      analyticsService: mockAnalyticsService,
      signAndBroadcastTransactionUseCase:
          mockSignAndBroadcastTransactionUseCase,
      writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
      logger: mockLogger,
    );
  });

  tearDown(() {
    composeDividendBloc.close();
    // Reset GetIt instance after each test
    GetIt.I.reset();
  });

  group('FetchFormData', () {
    const mockAsset = Asset(
      asset: 'ASSET_NAME',
      assetLongname: 'Asset Long Name',
      description: 'Test Asset',
    );

    blocTest<ComposeDividendBloc, ComposeDividendState>(
      'emits loading and then success states when data is fetched successfully',
      build: () {
        when(() => mockFetchDividendFormDataUseCase.call(any(), any()))
            .thenAnswer((_) async =>
                ([mockBalance], mockAsset, mockFeeEstimates, 20000000));
        return composeDividendBloc;
      },
      act: (bloc) {
        bloc.add(AsyncFormDependenciesRequested(
            currentAddress: 'test-address', assetName: 'ASSET_NAME'));
      },
      expect: () => [
        composeDividendBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          submitState: const FormStep(),
          assetState: const AssetState.loading(),
          dividendXcpFeeState: const DividendXcpFeeState.loading(),
        ),
        composeDividendBloc.state.copyWith(
          balancesState: BalancesState.success([mockBalance]),
          feeState: const FeeState.success(mockFeeEstimates),
          assetState: const AssetState.success(mockAsset),
          dividendXcpFeeState: const DividendXcpFeeState.success(20000000),
        ),
      ],
    );

    blocTest<ComposeDividendBloc, ComposeDividendState>(
      'emits error states when fetching fails',
      build: () {
        when(() => mockFetchDividendFormDataUseCase.call(any(), any()))
            .thenThrow(Exception('Test error'));
        return composeDividendBloc;
      },
      act: (bloc) {
        bloc.add(AsyncFormDependenciesRequested(
            currentAddress: 'test-address', assetName: 'ASSET_NAME'));
      },
      expect: () => [
        composeDividendBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          submitState: const FormStep(),
          assetState: const AssetState.loading(),
        ),
        composeDividendBloc.state.copyWith(
          balancesState: const BalancesState.error(
            'An unexpected error occurred: Exception: Test error',
          ),
          feeState: const FeeState.error(
            'An unexpected error occurred: Exception: Test error',
          ),
          assetState: const AssetState.error(
            'An unexpected error occurred: Exception: Test error',
          ),
        ),
      ],
    );
  });

  group('SignAndBroadcastTransactionEvent', () {
    const password = 'test-password';
    const txHex = 'rawtransaction';
    const txHash = 'transaction-hash';
    const sourceAddress = 'source-address';

    late MockComposeDividendResponse mockComposeDividendResponse;
    late MockComposeDividendResponseParams mockParams;

    setUp(() {
      mockComposeDividendResponse = MockComposeDividendResponse();
      mockParams = MockComposeDividendResponseParams();

      // Setup the mock response params
      when(() => mockComposeDividendResponse.params).thenReturn(mockParams);
      when(() => mockParams.source).thenReturn(sourceAddress);
      when(() => mockComposeDividendResponse.rawtransaction).thenReturn(txHex);
    });

    blocTest<ComposeDividendBloc, ComposeDividendState>(
      'emits SubmitSuccess when transaction is signed and broadcasted successfully',
      build: () {
        when(() => mockSignAndBroadcastTransactionUseCase.call(
              source: sourceAddress,
              rawtransaction: txHex,
              decryptionStrategy: Password(password),
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError'),
            )).thenAnswer((invocation) async {
          final onSuccess =
              invocation.namedArguments[const Symbol('onSuccess')] as Function;
          onSuccess(txHex, txHash);
        });

        when(() => mockWriteLocalTransactionUseCase.call(txHex, txHash))
            .thenAnswer((_) async {});
        when(() => mockAnalyticsService.trackAnonymousEvent(
              'broadcast_tx_dividend',
              properties: any(named: 'properties'),
            )).thenAnswer((_) async {});

        return composeDividendBloc;
      },
      seed: () => composeDividendBloc.state.copyWith(
        submitState: PasswordStep<ComposeDividendResponse>(
          loading: false,
          error: null,
          composeTransaction: mockComposeDividendResponse,
          fee: 250,
        ),
      ),
      act: (bloc) =>
          bloc.add(SignAndBroadcastFormSubmitted(password: password)),
      expect: () => [
        isA<ComposeDividendState>().having(
          (state) => state.submitState,
          'submitState',
          isA<PasswordStep<ComposeDividendResponse>>()
              .having((s) => s.loading, 'loading', true)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDividendResponse)
              .having((s) => s.fee, 'fee', 250),
        ),
        isA<ComposeDividendState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitSuccess>()
              .having((s) => s.transactionHex, 'transactionHex', txHex)
              .having((s) => s.sourceAddress, 'sourceAddress', sourceAddress),
        ),
      ],
      verify: (_) {
        verify(() => mockAnalyticsService.trackAnonymousEvent(
              'broadcast_tx_dividend',
              properties: any(named: 'properties'),
            )).called(1);
      },
    );
  });

  group('ComposeTransactionEvent', () {
    blocTest<ComposeDividendBloc, ComposeDividendState>(
      'emits success state when transaction is composed successfully',
      build: () {
        when(() => mockComposeTransactionUseCase
                .call<ComposeDividendParams, ComposeDividendResponse>(
              feeRate: any(named: 'feeRate'),
              source: any(named: 'source'),
              params: any(named: 'params'),
              composeFn: any(named: 'composeFn'),
            )).thenAnswer((_) async => mockComposeDividendResponse);

        when(() => mockComposeDividendResponse.btcFee).thenReturn(250);
        when(() => mockComposeDividendResponse.signedTxEstimatedSize)
            .thenReturn(SignedTxEstimatedSize(
          virtualSize: 120,
          adjustedVirtualSize: 155,
          sigopsCount: 1,
        ));

        return composeDividendBloc;
      },
      seed: () => composeDividendBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
        feeOption: FeeOption.Medium(),
      ),
      act: (bloc) => bloc.add(FormSubmitted(
        params: ComposeDividendEventParams(
          assetName: composeTransactionParams.asset,
          quantityPerUnit: composeTransactionParams.quantityPerUnit,
          dividendAsset: composeTransactionParams.dividendAsset,
        ),
        sourceAddress: 'source-address',
      )),
      expect: () => [
        isA<ComposeDividendState>().having(
          (state) => state.submitState,
          'submitState',
          isA<FormStep>().having((s) => s.loading, 'loading', true),
        ),
        isA<ComposeDividendState>().having(
          (state) => state.submitState,
          'submitState',
          isA<ReviewStep<ComposeDividendResponse, void>>()
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeDividendResponse)
              .having((s) => s.fee, 'fee', 250)
              .having((s) => s.feeRate, 'feeRate', 3)
              .having((s) => s.virtualSize, 'virtualSize', 120)
              .having((s) => s.adjustedVirtualSize, 'adjustedVirtualSize', 155),
        ),
      ],
    );

    blocTest<ComposeDividendBloc, ComposeDividendState>(
      'emits error state when transaction composition fails',
      build: () {
        when(() => mockComposeTransactionUseCase
                    .call<ComposeDividendParams, ComposeDividendResponse>(
                  feeRate: any(named: 'feeRate'),
                  source: any(named: 'source'),
                  params: any(named: 'params'),
                  composeFn: any(named: 'composeFn'),
                ))
            .thenThrow(
                ComposeTransactionException('Failed to compose transaction'));

        return composeDividendBloc;
      },
      seed: () => composeDividendBloc.state.copyWith(
        feeState: const FeeState.success(mockFeeEstimates),
      ),
      act: (bloc) => bloc.add(
        FormSubmitted(
          sourceAddress: 'source-address',
          params: ComposeDividendEventParams(
            assetName: composeTransactionParams.asset,
            quantityPerUnit: composeTransactionParams.quantityPerUnit,
            dividendAsset: composeTransactionParams.dividendAsset,
          ),
        ),
      ),
      expect: () => [
        isA<ComposeDividendState>().having(
          (state) => state.submitState,
          'submitState',
          isA<FormStep>()
              .having((s) => s.loading, 'loading', true)
              .having((s) => s.error, 'error', null),
        ),
        isA<ComposeDividendState>().having(
          (state) => state.submitState,
          'submitState',
          isA<FormStep>()
              .having((s) => s.loading, 'loading', false)
              .having((s) => s.error, 'error', 'Failed to compose transaction'),
        ),
      ],
    );
  });
}
