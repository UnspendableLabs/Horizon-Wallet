import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:formz/formz.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/forms/open_order_form/open_order_form_bloc.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_order.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';

class MockOnFormCancelled extends Mock {
  void call();
}

class MockOnFormSubmitted extends Mock {
  void call(SubmitArgs args);
}

class MockOnSubmitSuccess extends Mock {
  void call(OnSubmitSuccessArgs args);
}

class MockComposeTransactionUseCase extends Mock
    implements ComposeTransactionUseCase {}

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockAssetRepository extends Mock implements AssetRepository {}

class MockComposeRepository extends Mock implements ComposeRepository {}

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

class FakeAsset extends Fake implements Asset {
  @override
  final String asset;
  @override
  final String? assetLongname;
  @override
  final String owner;
  @override
  final String? issuer;
  @override
  final bool divisible;
  @override
  final bool locked;

  FakeAsset({
    required this.asset,
    this.assetLongname,
    required this.owner,
    this.issuer,
    required this.divisible,
    required this.locked,
  });
}

class FakeComposeOrderResponse extends Fake implements ComposeOrderResponse {}

class FakeAssetInfo extends Fake implements AssetInfo {
  @override
  final String assetLongname;
  @override
  final String? issuer;
  @override
  final bool divisible;

  FakeAssetInfo({
    this.assetLongname = "test_asset_longname",
    this.issuer,
    required this.divisible,
  });
}

class FakeBalance extends Fake implements Balance {
  @override
  final String asset;
  @override
  final int quantity;
  @override
  final String quantityNormalized;
  @override
  final String address;
  @override
  final AssetInfo assetInfo;

  FakeBalance({
    required this.asset,
    required this.quantity,
    required this.quantityNormalized,
    required this.address,
    required this.assetInfo,
  });
}

void main() {
  late OpenOrderFormBloc bloc;
  late MockBalanceRepository balanceRepository;
  late MockAssetRepository assetRepository;
  late MockComposeRepository composeRepository;
  late MockGetFeeEstimatesUseCase getFeeEstimatesUseCase;
  late MockComposeTransactionUseCase composeTransactionUseCase;
  late MockOnFormCancelled onFormCancelled;
  late MockOnSubmitSuccess onSubmitSuccess;
  const testAddress = 'test_address';

  setUpAll(() {
    registerFallbackValue((0, 0, 0)); // Fallback for (int, int, int)
  });

  setUp(() {
    composeTransactionUseCase = MockComposeTransactionUseCase();
    balanceRepository = MockBalanceRepository();
    assetRepository = MockAssetRepository();
    getFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();
    composeRepository = MockComposeRepository();
    onFormCancelled = MockOnFormCancelled();
    onSubmitSuccess = MockOnSubmitSuccess();
    bloc = OpenOrderFormBloc(
        assetRepository: assetRepository,
        balanceRepository: balanceRepository,
        composeRepository: composeRepository,
        currentAddress: testAddress,
        getFeeEstimatesUseCase: getFeeEstimatesUseCase,
        composeTransactionUseCase: composeTransactionUseCase,
        onFormCancelled: onFormCancelled.call,
        onSubmitSuccess: onSubmitSuccess.call);
  });

  tearDown(() {
    bloc.close();
  });

  blocTest<OpenOrderFormBloc, FormStateModel>(
    'emits [Loading(), Success()] when InitializeForm is added and repository returns balances',
    build: () {
      when(() => getFeeEstimatesUseCase.call(targets: any(named: 'targets')))
          .thenAnswer(
              (_) async => FeeEstimates(fast: 50, medium: 30, slow: 10));

      when(() => balanceRepository.getBalancesForAddress(any())).thenAnswer(
        (_) async => [
          FakeBalance(
              address: testAddress,
              asset: 'ASSET1',
              quantity: 100,
              quantityNormalized: "100",
              assetInfo: FakeAssetInfo(divisible: false)),
          FakeBalance(
              address: testAddress,
              asset: 'ASSET2',
              quantity: 200,
              quantityNormalized: "20000000000",
              assetInfo: FakeAssetInfo(divisible: true)),
        ],
      );
      return bloc;
    },
    act: (bloc) => bloc.add(InitializeForm()),
    expect: () => [
      isA<FormStateModel>().having(
        (s) => s.giveAssets,
        'giveAssets',
        isA<Loading<List<Balance>>>(),
      ),
      isA<FormStateModel>().having(
          (s) => s.giveAssets, 'giveAssets', isA<Success<List<Balance>>>()),
    ],
    verify: (_) {
      verify(() => balanceRepository.getBalancesForAddress(testAddress))
          .called(1);
    },
  );



  blocTest<OpenOrderFormBloc, FormStateModel>(
    'emits Loading and then Success when GetAssetChanged is added and asset exists',
    build: () {
      when(() => assetRepository.getAssetVerbose('ASSET2')).thenAnswer(
        (_) async => FakeAsset(
          asset: 'ASSET2',
          owner: 'owner_address',
          divisible: true,
          locked: false,
        ),
      );
      return bloc;
    },
    seed: () {
      // Setting initial state with getAsset and getAssets
      return bloc.state.copyWith(
        getAsset: const GetAssetInput.dirty('ASSET1'),
        getQuantity: const GetQuantityInput.dirty('50'),
      );
    },
    act: (bloc) => bloc.add(const GetAssetChanged('ASSET2')),
    expect: () => [
      isA<FormStateModel>()
          .having((state) => state.getQuantity.value, 'getQuantity.value', '50')
          .having((state) => state.getAsset.value, 'getAsset.value', 'ASSET2')
          .having((state) => state.getAssetValidationStatus,
              'getAssetValidationStatus', isA<Loading>()),
      isA<FormStateModel>()
          .having((state) => state.getAssetValidationStatus,
              'getAssetValidationStatus', isA<Success<Asset>>())
          .having(
              (state) =>
                  (state.getAssetValidationStatus as Success<Asset>).data.asset,
              'asset',
              'ASSET2')
          .having((state) => state.getQuantity.isDivisible,
              'getQuantity.isDivisible', true),
    ],
    verify: (_) {
      verify(() => assetRepository.getAssetVerbose('ASSET2')).called(1);
    },
  );

  blocTest<OpenOrderFormBloc, FormStateModel>(
    'emits Loading and then Failure when GetAssetChanged is added and asset does not exist',
    build: () {
      when(() => assetRepository.getAssetVerbose('UNKNOWN'))
          .thenThrow(Exception('Not found'));
      return bloc;
    },
    act: (bloc) => bloc.add(const GetAssetChanged('UNKNOWN')),
    expect: () => [
      isA<FormStateModel>()
          .having((state) => state.getAsset.value, 'getAsset.value', 'UNKNOWN')
          .having((state) => state.getAssetValidationStatus,
              'getAssetValidationStatus', isA<Loading>()),
      isA<FormStateModel>()
          .having((state) => state.getAssetValidationStatus,
              'getAssetValidationStatus', isA<Failure>())
          .having(
              (state) => (switch (state.getAssetValidationStatus) {
                    Failure(errorMessage: var message) => message,
                    _ => null
                  }),
              'message',
              'Asset not found'),
    ],
    verify: (_) {
      verify(() => assetRepository.getAssetVerbose('UNKNOWN')).called(1);
    },
  );

  blocTest<OpenOrderFormBloc, FormStateModel>(
    'updates giveQuantity when GiveQuantityChanged is added',
    build: () => bloc,
    seed: () {
      // Setting initial state with giveAsset and giveAssets
      return bloc.state.copyWith(
        giveAsset: const GiveAssetInput.dirty('ASSET1'),
        giveAssets: Success([
          FakeBalance(
            asset: 'ASSET1',
            quantity: 100,
            quantityNormalized: '100',
            address: testAddress,
            assetInfo: FakeAssetInfo(divisible: false),
          ),
        ]),
      );
    },
    act: (bloc) => bloc.add(const GiveQuantityChanged('50')),
    expect: () => [
      isA<FormStateModel>()
          .having(
              (state) => state.giveQuantity.value, 'giveQuantity.value', '50')
          .having((state) => state.giveQuantity.balance, 'giveQuantity.balance',
              100)
          .having((state) => state.giveQuantity.isDivisible,
              'giveQuantity.isDivisible', false)
          .having((state) => state.errorMessage, 'errorMessage', isNull),
    ],
  );

  blocTest<OpenOrderFormBloc, FormStateModel>(
    'updates giveQuantity with validation error when GiveQuantityChanged is added with invalid input',
    build: () => bloc,
    seed: () {
      // Setting initial state with giveAsset and giveAssets
      return bloc.state.copyWith(
        giveAsset: const GiveAssetInput.dirty('ASSET1'),
        giveAssets: Success([
          FakeBalance(
            asset: 'ASSET1',
            quantity: 100,
            quantityNormalized: '100',
            address: testAddress,
            assetInfo: FakeAssetInfo(divisible: false),
          ),
        ]),
      );
    },
    act: (bloc) =>
        bloc.add(const GiveQuantityChanged('150')), // Exceeds balance
    expect: () => [
      isA<FormStateModel>()
          .having(
              (state) => state.giveQuantity.value, 'giveQuantity.value', '150')
          .having((state) => state.giveQuantity.error, 'giveQuantity.error',
              GiveQuantityValidationError.exceedsBalance)
          .having((state) => state.errorMessage, 'errorMessage', isNull),
    ],
  );

  blocTest<OpenOrderFormBloc, FormStateModel>(
    'accepts decimal input for giveQuantity when giveAsset is divisible',
    build: () => bloc,
    seed: () {
      // Setting up initial state with a divisible giveAsset
      return bloc.state.copyWith(
        giveAsset: const GiveAssetInput.dirty('ASSET_DIV'),
        giveAssets: Success([
          FakeBalance(
            asset: 'ASSET_DIV',
            quantity:
                100000000, // Assume quantity is represented in satoshi-like units
            quantityNormalized: '1',
            address: testAddress,
            assetInfo: FakeAssetInfo(divisible: true),
          ),
        ]),
        giveQuantity:
            const GiveQuantityInput.pure(balance: 100000000, isDivisible: true),
      );
    },
    act: (bloc) =>
        bloc.add(const GiveQuantityChanged('0.5')), // Valid decimal input
    expect: () => [
      isA<FormStateModel>()
          .having(
              (state) => state.giveQuantity.value, 'giveQuantity.value', '0.5')
          .having((state) => state.giveQuantity.isDivisible,
              'giveQuantity.isDivisible', true)
          .having((state) => state.giveQuantity.isValid, 'giveQuantity', true),
    ],
  );

  blocTest<OpenOrderFormBloc, FormStateModel>(
    'does not accept decimal input for giveQuantity when giveAsset is not divisible',
    build: () => bloc,
    seed: () {
      // Setting up initial state with a divisible giveAsset
      return bloc.state.copyWith(
        giveAsset: const GiveAssetInput.dirty('ASSET_DIV'),
        giveAssets: Success([
          FakeBalance(
            asset: 'ASSET_DIV',
            quantity:
                100000000, // Assume quantity is represented in satoshi-like units
            quantityNormalized: '1',
            address: testAddress,
            assetInfo: FakeAssetInfo(divisible: false),
          ),
        ]),
        giveQuantity: const GiveQuantityInput.pure(
            balance: 100000000, isDivisible: false),
      );
    },
    act: (bloc) =>
        bloc.add(const GiveQuantityChanged('0.5')), // Valid decimal input
    expect: () => [
      isA<FormStateModel>()
          .having(
              (state) => state.giveQuantity.value, 'giveQuantity.value', '0.5')
          .having((state) => state.giveQuantity.isDivisible,
              'giveQuantity.isDivisible', false)
          .having((state) => state.giveQuantity.isValid, 'giveQuantity', false),
    ],
  );

  blocTest<OpenOrderFormBloc, FormStateModel>(
    'updates getQuantity when GetQuantityChanged is added',
    build: () => bloc,
    seed: () {
      // Assume getAssetValidationStatus is success and asset is divisible
      return bloc.state.copyWith(
        getAssetValidationStatus: Success(
          FakeAsset(
            asset: 'ASSET2',
            owner: 'owner_address',
            divisible: true,
            locked: false,
          ),
        ),
      );
    },
    act: (bloc) => bloc.add(const GetQuantityChanged('25.5')),
    expect: () => [
      isA<FormStateModel>()
          .having(
              (state) => state.getQuantity.value, 'getQuantity.value', '25.5')
          .having((state) => state.getQuantity.isDivisible,
              'getQuantity.isDivisible', true)
          .having((state) => state.errorMessage, 'errorMessage', isNull),
    ],
  );

  blocTest<OpenOrderFormBloc, FormStateModel>(
    'updates getQuantity with validation error when GetQuantityChanged is added with invalid input',
    build: () => bloc,
    seed: () {
      // Assume getAssetValidationStatus is success and asset is divisible
      return bloc.state.copyWith(
        getAssetValidationStatus: Success(
          FakeAsset(
            asset: 'ASSET2',
            owner: 'owner_address',
            divisible: true,
            locked: false,
          ),
        ),
      );
    },
    act: (bloc) => bloc.add(const GetQuantityChanged('-10')), // Negative number
    expect: () => [
      isA<FormStateModel>()
          .having(
              (state) => state.getQuantity.value, 'getQuantity.value', '-10')
          .having((state) => state.getQuantity.error, 'getQuantity.error',
              GetQuantityValidationError.invalid)
          .having((state) => state.errorMessage, 'errorMessage', isNull),
    ],
  );

  blocTest<OpenOrderFormBloc, FormStateModel>(
    'FormSubmitted succcess',
    build: () {
      when(() => getFeeEstimatesUseCase.call(targets: any(named: 'targets')))
          .thenAnswer(
              (_) async => FeeEstimates(fast: 50, medium: 30, slow: 10));

      when(() => composeTransactionUseCase
                  .call<ComposeOrderParams, ComposeOrderResponse>(
                source: testAddress,
                feeRate: 30,
                params: ComposeOrderParams(
                  source: testAddress,
                  giveQuantity: 5,
                  giveAsset: 'ASSET1',
                  getQuantity: (2.5 * 100000000).toInt(),
                  getAsset: 'ASSET2',
                ),
                composeFn: any(named: 'composeFn'),
              ))
          .thenAnswer(
              (_) async => (FakeComposeOrderResponse(), VirtualSize(100, 100)));

      when(() => balanceRepository.getBalancesForAddress(any())).thenAnswer(
        (_) async => [
          FakeBalance(
            address: testAddress,
            asset: 'ASSET1',
            quantity: 100000000,
            quantityNormalized: "1",
            assetInfo: FakeAssetInfo(divisible: false),
          ),
        ],
      );

      when(() => assetRepository.getAssetVerbose(any())).thenAnswer(
        (_) async => FakeAsset(
          asset: 'ASSET2',
          owner: 'owner_address',
          divisible: true,
          locked: false,
        ),
      );

      return bloc;
    },
    seed: () {
      // Initial state with getAsset and giveAsset as divisible assets
      return bloc.state.copyWith(
        giveAsset: const GiveAssetInput.dirty('ASSET1'),
        giveQuantity: const GiveQuantityInput.dirty('5', isDivisible: false),
        getAsset: const GetAssetInput.dirty('ASSET2'),
        getQuantity: const GetQuantityInput.dirty('2.5', isDivisible: true),
        submissionStatus: FormzSubmissionStatus.initial,
        feeOption: FeeOption.Medium(),
        feeEstimates: Success(FeeEstimates(fast: 50, medium: 30, slow: 10)),
      );
    },
    act: (bloc) => bloc.add(FormSubmitted()),
    expect: () => [
      isA<FormStateModel>().having(
        (state) => state.submissionStatus,
        'submissionStatus',
        FormzSubmissionStatus.inProgress,
      ),
      isA<FormStateModel>().having(
        (state) => state.submissionStatus,
        'submissionStatus',
        FormzSubmissionStatus.success,
      ),
    ],
    verify: (_) {
      // Retrieve and check denormalized values
      verify(() => composeTransactionUseCase
              .call<ComposeOrderParams, ComposeOrderResponse>(
            source: testAddress,
            feeRate: 30,
            params: ComposeOrderParams(
              source: testAddress,
              giveQuantity: 5,
              giveAsset: 'ASSET1',
              getQuantity: (2.5 * 100000000).toInt(),
              getAsset: 'ASSET2',
            ),
            composeFn: composeRepository.composeOrder,
          )).called(1);
    },
  );
}
