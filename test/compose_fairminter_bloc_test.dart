import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/compose_fairminter.dart';
import 'package:horizon/domain/entities/fairminter.dart';
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
import 'package:horizon/presentation/screens/compose_fairminter/bloc/compose_fairminter_bloc.dart';
import 'package:horizon/presentation/screens/compose_fairminter/bloc/compose_fairminter_state.dart';
import 'package:horizon/presentation/screens/compose_fairminter/usecase/fetch_form_data.dart';
import 'package:mocktail/mocktail.dart';

class MockComposeRepository extends Mock implements ComposeRepository {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockLogger extends Mock implements Logger {}

class MockFetchFairminterFormDataUseCase extends Mock
    implements FetchFairminterFormDataUseCase {}

class MockComposeTransactionUseCase extends Mock
    implements ComposeTransactionUseCase {}

class MockSignAndBroadcastTransactionUseCase extends Mock
    implements SignAndBroadcastTransactionUseCase {}

class MockWriteLocalTransactionUseCase extends Mock
    implements WriteLocalTransactionUseCase {}

class MockBlockRepository extends Mock implements BlockRepository {}

class MockErrorService extends Mock implements ErrorService {}

class MockComposeFairminterResponse extends Mock
    implements ComposeFairminterResponse {
  @override
  final MockComposeFairminterParams params = MockComposeFairminterParams();

  @override
  String get rawtransaction => "rawtransaction";
}

class MockComposeFairminterParams extends Mock
    implements ComposeFairminterParams {
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
  late ComposeFairminterBloc composeFairminterBloc;
  late MockComposeRepository mockComposeRepository;
  late MockAnalyticsService mockAnalyticsService;
  late MockLogger mockLogger;
  late MockFetchFairminterFormDataUseCase mockFetchFairminterFormDataUseCase;
  late MockComposeTransactionUseCase mockComposeTransactionUseCase;
  late MockSignAndBroadcastTransactionUseCase
      mockSignAndBroadcastTransactionUseCase;
  late MockWriteLocalTransactionUseCase mockWriteLocalTransactionUseCase;
  late MockBlockRepository mockBlockRepository;
  late MockErrorService mockErrorService;

  const mockFeeEstimates = FeeEstimates(fast: 5, medium: 3, slow: 1);
  final mockComposeFairminterResponseVerbose = MockComposeFairminterResponse();

  final composeTransactionParams = ComposeFairminterEventParams(
    asset: 'TEST_ASSET',
    maxMintPerTx: 1000,
    hardCap: 10000,
    divisible: true,
    startBlock: 100,
    isLocked: true,
  );

  setUpAll(() {
    registerFallbackValue(ComposeFairminterParams(
      source: 'source',
      asset: 'TEST_ASSET',
      maxMintPerTx: 1000,
      hardCap: 10000,
      divisible: true,
      startBlock: 100,
      lockQuantity: true,
    ));
    registerFallbackValue(FeeOption.Medium());
    registerFallbackValue(ComposeTransactionEvent(
      params: composeTransactionParams,
      sourceAddress: 'source-address',
    ));
    registerFallbackValue(SignAndBroadcastTransactionEvent(
      password: 'password',
    ));
  });

  setUp(() {
    mockComposeRepository = MockComposeRepository();
    mockAnalyticsService = MockAnalyticsService();
    mockLogger = MockLogger();
    mockFetchFairminterFormDataUseCase = MockFetchFairminterFormDataUseCase();
    mockComposeTransactionUseCase = MockComposeTransactionUseCase();
    mockSignAndBroadcastTransactionUseCase =
        MockSignAndBroadcastTransactionUseCase();
    mockWriteLocalTransactionUseCase = MockWriteLocalTransactionUseCase();
    mockBlockRepository = MockBlockRepository();
    mockErrorService = MockErrorService();

    GetIt.I.registerSingleton<ErrorService>(mockErrorService);

    composeFairminterBloc = ComposeFairminterBloc(
      logger: mockLogger,
      fetchFairminterFormDataUseCase: mockFetchFairminterFormDataUseCase,
      composeTransactionUseCase: mockComposeTransactionUseCase,
      composeRepository: mockComposeRepository,
      analyticsService: mockAnalyticsService,
      signAndBroadcastTransactionUseCase:
          mockSignAndBroadcastTransactionUseCase,
      writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
      blockRepository: mockBlockRepository,
    );
  });

  tearDown(() {
    composeFairminterBloc.close();
    GetIt.I.reset();
  });

  group('FetchFormData', () {
    blocTest<ComposeFairminterBloc, ComposeFairminterState>(
      'emits loading and then success states when data is fetched successfully',
      build: () {
        when(() => mockFetchFairminterFormDataUseCase.call(any())).thenAnswer(
            (_) async => (
                  List<Asset>.empty(),
                  mockFeeEstimates,
                  List<Fairminter>.empty()
                ));
        return composeFairminterBloc;
      },
      act: (bloc) {
        bloc.add(FetchFormData(currentAddress: 'test-address'));
      },
      expect: () => [
        composeFairminterBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          assetState: const AssetState.loading(),
          submitState: const SubmitInitial(),
          fairmintersState: const FairmintersState.loading(),
        ),
        composeFairminterBloc.state.copyWith(
          balancesState: const BalancesState.success([]),
          feeState: const FeeState.success(mockFeeEstimates),
          assetState: const AssetState.success([]),
          fairmintersState: const FairmintersState.success([]),
        ),
      ],
    );

    blocTest<ComposeFairminterBloc, ComposeFairminterState>(
      'emits error state when fetching fee estimates fails',
      build: () {
        when(() => mockFetchFairminterFormDataUseCase.call(any())).thenThrow(
            FetchFeeEstimatesException('Failed to fetch fee estimates'));
        return composeFairminterBloc;
      },
      act: (bloc) {
        bloc.add(FetchFormData(currentAddress: 'test-address'));
      },
      expect: () => [
        composeFairminterBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          assetState: const AssetState.loading(),
          submitState: const SubmitInitial(),
        ),
        composeFairminterBloc.state.copyWith(
          feeState: const FeeState.error('Failed to fetch fee estimates'),
        ),
      ],
    );
  });

  group('SignAndBroadcastTransactionEvent', () {
    const password = 'test-password';
    const txHex = 'rawtransaction';
    const txHash = 'transaction-hash';

    blocTest<ComposeFairminterBloc, ComposeFairminterState>(
      'emits SubmitSuccess when transaction is signed and broadcasted successfully',
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
          onSuccess(txHex, txHash);
        });

        when(() => mockWriteLocalTransactionUseCase.call(txHex, txHash))
            .thenAnswer((_) async {});

        when(() => mockAnalyticsService.trackAnonymousEvent(
              'broadcast_tx_fairminter',
              properties: any(named: 'properties'),
            )).thenAnswer((_) async {});

        return composeFairminterBloc;
      },
      seed: () => composeFairminterBloc.state.copyWith(
        submitState: SubmitFinalizing<ComposeFairminterResponse>(
          loading: false,
          error: null,
          composeTransaction: mockComposeFairminterResponseVerbose,
          fee: 250,
        ),
      ),
      act: (bloc) =>
          bloc.add(SignAndBroadcastTransactionEvent(password: password)),
      expect: () => [
        isA<ComposeFairminterState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitFinalizing<ComposeFairminterResponse>>()
              .having((s) => s.loading, 'loading', true)
              .having((s) => s.error, 'error', null)
              .having((s) => s.composeTransaction, 'composeTransaction',
                  mockComposeFairminterResponseVerbose)
              .having((s) => s.fee, 'fee', 250),
        ),
        isA<ComposeFairminterState>().having(
          (state) => state.submitState,
          'submitState',
          isA<SubmitSuccess>()
              .having((s) => s.transactionHex, 'transactionHex', txHex)
              .having((s) => s.sourceAddress, 'sourceAddress', 'source'),
        ),
      ],
      verify: (_) {
        verify(() => mockAnalyticsService.trackAnonymousEvent(
              'broadcast_tx_fairminter',
              properties: any(named: 'properties'),
            )).called(1);
      },
    );
  });

  group('FetchFormData with Fairminter filtering', () {
    final mockAssets = [
      const Asset(asset: 'VALID', assetLongname: 'VALID.ASSET'),
      const Asset(asset: 'LOCKED', assetLongname: 'LOCKED.ASSET'),
      const Asset(asset: 'OPEN', assetLongname: 'OPEN.ASSET'),
      const Asset(asset: 'INVALID', assetLongname: 'INVALID.ASSET'),
      const Asset(asset: 'UNRELATED', assetLongname: 'UNRELATED.ASSET'),
    ];

    final mockFairminters = [
      const Fairminter(
        status: 'closed',
        asset: 'VALID',
        assetLongname: 'VALID.ASSET',
        txHash: 'tx-hash',
        txIndex: 0,
        source: 'source',
        quantityByPrice: 1000,
        hardCap: 10000,
        maxMintPerTx: 1000,
        premintQuantity: 0,
        startBlock: 100,
        endBlock: 200,
        mintedAssetCommissionInt: 0,
        softCap: 1000,
        softCapDeadlineBlock: 100,
      ),
      const Fairminter(
        status: 'closed',
        asset: 'LOCKED',
        assetLongname: 'LOCKED.ASSET',
        lockQuantity: true, // This one should be invalid due to being locked
        txHash: 'tx-hash',
        txIndex: 0,
        source: 'source',
        quantityByPrice: 1000,
        hardCap: 10000,
        maxMintPerTx: 1000,
        premintQuantity: 0,
        startBlock: 100,
        endBlock: 200,
        mintedAssetCommissionInt: 0,
        softCap: 1000,
        softCapDeadlineBlock: 100,
      ),
      const Fairminter(
        status: 'open',
        asset: 'OPEN',
        assetLongname: 'OPEN.ASSET',
        txHash: 'tx-hash',
        txIndex: 0,
        source: 'source',
        quantityByPrice: 1000,
        hardCap: 10000,
        maxMintPerTx: 1000,
        premintQuantity: 0,
        startBlock: 100,
        endBlock: 200,
        mintedAssetCommissionInt: 0,
        softCap: 1000,
        softCapDeadlineBlock: 100,
      ),
      const Fairminter(
        status:
            'invalid: Hard cap of asset `INVALID.ASSET` is already reached.',
        asset: null,
        assetLongname: null,
        txHash: 'tx-hash',
        txIndex: 0,
        source: 'source',
        quantityByPrice: 1000,
        hardCap: 10000,
        maxMintPerTx: 1000,
        premintQuantity: 0,
        startBlock: 100,
        endBlock: 200,
        mintedAssetCommissionInt: 0,
        softCap: 1000,
        softCapDeadlineBlock: 100,
      ),
    ];

    blocTest<ComposeFairminterBloc, ComposeFairminterState>(
      'correctly filters assets based on fairminter status',
      build: () {
        when(() => mockFetchFairminterFormDataUseCase.call(any())).thenAnswer(
          (_) async => (
            mockAssets,
            mockFeeEstimates,
            mockFairminters,
          ),
        );
        return composeFairminterBloc;
      },
      act: (bloc) {
        bloc.add(FetchFormData(currentAddress: 'test-address'));
      },
      expect: () => [
        composeFairminterBloc.state.copyWith(
          balancesState: const BalancesState.loading(),
          feeState: const FeeState.loading(),
          assetState: const AssetState.loading(),
          submitState: const SubmitInitial(),
          fairmintersState: const FairmintersState.loading(),
        ),
        composeFairminterBloc.state.copyWith(
          balancesState: const BalancesState.success([]),
          feeState: const FeeState.success(mockFeeEstimates),
          assetState: AssetState.success(mockAssets
              .where((asset) =>
                  asset.asset == 'VALID' || asset.asset == 'UNRELATED')
              .toList()),
          fairmintersState: FairmintersState.success(mockFairminters),
        ),
      ],
      verify: (_) {
        final state = composeFairminterBloc.state;
        final assets = (state.assetState as dynamic).assets;

        expect(assets.length, 2,
            reason: 'Should only have valid and unrelated assets');

        expect(assets.any((asset) => asset.asset == 'VALID'), true,
            reason: 'Should include asset with closed fairminter');

        expect(assets.any((asset) => asset.asset == 'LOCKED'), false,
            reason: 'Should exclude asset with closed but locked fairminter');

        expect(assets.any((asset) => asset.asset == 'UNRELATED'), true,
            reason: 'Should include asset with no fairminter');

        expect(assets.any((asset) => asset.asset == 'OPEN'), false,
            reason: 'Should exclude asset with open fairminter');

        expect(assets.any((asset) => asset.asset == 'INVALID'), false,
            reason: 'Should exclude asset parsed from invalid status message');
      },
    );
  });
}
