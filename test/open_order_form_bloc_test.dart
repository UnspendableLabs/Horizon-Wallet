import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:formz/formz.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/forms/open_order_form/open_order_form_bloc.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/asset_info.dart';

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockAssetRepository extends Mock implements AssetRepository {}

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
  const testAddress = 'test_address';

  setUp(() {
    balanceRepository = MockBalanceRepository();
    assetRepository = MockAssetRepository();
    bloc = OpenOrderFormBloc(
      assetRepository: assetRepository,
      balanceRepository: balanceRepository,
      currentAddress: testAddress,
    );
  });

  tearDown(() {
    bloc.close();
  });

  blocTest<OpenOrderFormBloc, FormStateModel>(
    'emits [Loading(), Success()] when LoadGiveAssets is added and repository returns balances',
    build: () {
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
    act: (bloc) => bloc.add(LoadGiveAssets()),
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
    'emits [Loading(), Failure()] when LoadGiveAssets is added and repository throws an exception',
    build: () {
      when(() => balanceRepository.getBalancesForAddress(any()))
          .thenThrow(Exception('Error'));
      return bloc;
    },
    act: (bloc) => bloc.add(LoadGiveAssets()),
    expect: () => [
      isA<FormStateModel>().having(
        (s) => s.giveAssets,
        'giveAssets',
        isA<Loading<List<Balance>>>(),
      ),
      isA<FormStateModel>().having(
          (s) => s.giveAssets, 'giveAssets', isA<Failure<List<Balance>>>()),
    ],
    verify: (_) {
      verify(() => balanceRepository.getBalancesForAddress(testAddress))
          .called(1);
    },
  );

  blocTest<OpenOrderFormBloc, FormStateModel>(
    'updates giveAsset and resets giveQuantity and getAsset when GiveAssetChanged is added',
    build: () => bloc,
    seed: () {
      // Setting initial state with giveAsset and giveAssets
      return bloc.state.copyWith(
        giveAsset: const GiveAssetInput.dirty('ASSET1'),
        giveQuantity: const GiveQuantityInput.dirty('50'),
      );
    },
    act: (bloc) => bloc.add(const GiveAssetChanged('ASSET2')),
    expect: () => [
      isA<FormStateModel>()
          .having((state) => state.giveAsset.value, 'giveAsset.value', 'ASSET2')
          .having((state) => state.giveQuantity.value, 'giveQuantity.value', '')
          .having((state) => state.getAsset.value, 'getAsset.value', '')
          .having((state) => state.errorMessage, 'errorMessage', isNull),
    ],
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
          .having((state) => state.getQuantity.value, 'getQuantity.value', '')
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
          .having((state) => state.giveQuantity.isValid, 'giveQuantity',
              true),
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
        giveQuantity:
            const GiveQuantityInput.pure(balance: 100000000, isDivisible: false),
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
          .having((state) => state.giveQuantity.isValid, 'giveQuantity',
              false),
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

  // blocTest<OpenOrderFormBloc, FormStateModel>(
  //   'emits inProgress and then success when FormSubmitted is added and submission succeeds',
  //   build: () => bloc,
  //   act: (bloc) => bloc.add(FormSubmitted()),
  //   expect: () => [
  //     isA<FormStateModel>().having(
  //       (state) => state.submissionStatus,
  //       'submissionStatus',
  //       FormzSubmissionStatus.inProgress,
  //     ),
  //     isA<FormStateModel>().having(
  //       (state) => state.submissionStatus,
  //       'submissionStatus',
  //       FormzSubmissionStatus.success,
  //     ),
  //   ],
  // );

  // blocTest<OpenOrderFormBloc, FormStateModel>(
  //   'emits inProgress and then failure when FormSubmitted is added and submission fails',
  //   build: () {
  //     // Override the _onFormSubmitted method to simulate an exception
  //     return OpenOrderFormBloc(
  //       assetRepository: assetRepository,
  //       balanceRepository: balanceRepository,
  //       currentAddress: testAddress,
  //     )..on<FormSubmitted>(
  //         (event, emit) async {
  //           emit(state.copyWith(
  //               submissionStatus: FormzSubmissionStatus.inProgress));
  //           // Simulate an exception
  //           emit(state.copyWith(
  //             submissionStatus: FormzSubmissionStatus.failure,
  //             errorMessage: 'Form submission failed',
  //           ));
  //         },
  //       );
  //   },
  //   act: (bloc) => bloc.add(FormSubmitted()),
  //   expect: () => [
  //     isA<FormStateModel>().having(
  //       (state) => state.submissionStatus,
  //       'submissionStatus',
  //       FormzSubmissionStatus.inProgress,
  //     ),
  //     isA<FormStateModel>()
  //         .having((state) => state.submissionStatus, 'submissionStatus',
  //             FormzSubmissionStatus.failure)
  //         .having((state) => state.errorMessage, 'errorMessage',
  //             'Form submission failed'),
  //   ],
  // );
}
