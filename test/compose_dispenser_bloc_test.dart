// import 'package:bloc_test/bloc_test.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:get_it/get_it.dart';
// import 'package:horizon/domain/entities/address.dart';
// import 'package:horizon/domain/entities/balance.dart';
// import 'package:horizon/domain/entities/compose_dispenser.dart';
// import 'package:horizon/domain/entities/compose_response.dart';
// import 'package:horizon/domain/entities/dispenser.dart';
// import 'package:horizon/domain/entities/fee_estimates.dart';
// import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
// import 'package:horizon/domain/entities/utxo.dart';
// import 'package:horizon/domain/repositories/account_repository.dart';
// import 'package:horizon/domain/repositories/address_repository.dart';
// import 'package:horizon/domain/repositories/compose_repository.dart';
// import 'package:horizon/domain/repositories/wallet_repository.dart';
// import 'package:horizon/domain/services/address_service.dart';
// import 'package:horizon/domain/services/analytics_service.dart';
// import 'package:horizon/domain/services/encryption_service.dart';
// import 'package:horizon/domain/services/error_service.dart';
// import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
// import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
// import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
// import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
// import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';

// import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:horizon/core/logging/logger.dart';
// import 'package:horizon/domain/entities/decryption_strategy.dart';

// class MockComposeRepository extends Mock implements ComposeRepository {}

// class MockAnalyticsService extends Mock implements AnalyticsService {}

// class MockFetchDispenserFormDataUseCase extends Mock
//     implements FetchDispenserFormDataUseCase {}

// class MockComposeTransactionUseCase extends Mock
//     implements ComposeTransactionUseCase {}

// class MockSignAndBroadcastTransactionUseCase extends Mock
//     implements SignAndBroadcastTransactionUseCase {}

// class MockWriteLocalTransactionUseCase extends Mock
//     implements WriteLocalTransactionUseCase {}

// class MockAccountRepository extends Mock implements AccountRepository {}

// class MockAddressRepository extends Mock implements AddressRepository {}

// class MockWalletRepository extends Mock implements WalletRepository {}

// class MockEncryptionService extends Mock implements EncryptionService {}

// class MockAddressService extends Mock implements AddressService {}

// class MockErrorService extends Mock implements ErrorService {}

// class MockComposeDispenserResponseParams extends Mock
//     implements ComposeDispenserResponseVerboseParams {
//   @override
//   String get source => "source";
// }

// class MockComposeDispenserResponseVerbose extends Mock
//     implements ComposeDispenserResponseVerbose {
//   @override
//   final MockComposeDispenserResponseParams params =
//       MockComposeDispenserResponseParams();

//   @override
//   String get rawtransaction => "rawtransaction";
// }

// class MockBalance extends Mock implements Balance {
//   @override
//   final String? utxo;

//   MockBalance({this.utxo});
// }

// class MockDispenser extends Mock implements Dispenser {}

// class MockComposeDispenserEventParams extends Mock
//     implements ComposeDispenserEventParams {}

// class MockInMemoryKeyRepository extends Mock implements InMemoryKeyRepository {}

// class MockLogger extends Mock implements Logger {}

// class FakeAddress extends Fake implements Address {
//   @override
//   final String accountUuid = "test-account-uuid";
//   @override
//   final String address = "test-address";
//   @override
//   final int index = 0;
// }

// class FakeUtxo extends Fake implements Utxo {}

// class FakeVirtualSize extends Fake implements VirtualSize {
//   @override
//   final int virtualSize;
//   @override
//   final int adjustedVirtualSize;

//   FakeVirtualSize(
//       {required this.virtualSize, required this.adjustedVirtualSize});
// }

// void main() {
//   late ComposeDispenserBloc composeDispenserBloc;
//   late MockComposeRepository mockComposeRepository;
//   late MockAnalyticsService mockAnalyticsService;
//   late MockFetchDispenserFormDataUseCase mockFetchDispenserFormDataUseCase;
//   late MockComposeTransactionUseCase mockComposeTransactionUseCase;
//   late MockSignAndBroadcastTransactionUseCase
//       mockSignAndBroadcastTransactionUseCase;
//   late MockWriteLocalTransactionUseCase mockWriteLocalTransactionUseCase;
//   late MockAccountRepository mockAccountRepository;
//   late MockAddressRepository mockAddressRepository;
//   late MockWalletRepository mockWalletRepository;
//   late MockEncryptionService mockEncryptionService;
//   late MockAddressService mockAddressService;
//   late MockErrorService mockErrorService;

//   const mockFeeEstimates = FeeEstimates(fast: 5, medium: 3, slow: 1);
//   final mockAddress = FakeAddress().address;
//   final mockBalances = [MockBalance()];
//   final mockBalancesWithUtxos = [
//     MockBalance(utxo: 'utxo'),
//     MockBalance(utxo: null)
//   ];
//   final mockDispenser = [MockDispenser()];
//   final mockComposeDispenserResponseVerbose =
//       MockComposeDispenserResponseVerbose();

//   final composeTransactionParams = ComposeDispenserEventParams(
//     asset: 'ASSET_NAME',
//     giveQuantity: 1000,
//     escrowQuantity: 500,
//     mainchainrate: 1,
//     status: 0,
//   );

//   final composeDispenserParams = ComposeDispenserParams(
//       asset: 'ASSET_NAME',
//       giveQuantity: 1000,
//       escrowQuantity: 500,
//       mainchainrate: 1,
//       source: "test-address");

//   final List<Utxo> utxos = [FakeUtxo()];

//   setUpAll(() {
//     registerFallbackValue(FakeAddress().address);
//     registerFallbackValue(composeTransactionParams);
//     registerFallbackValue(utxos);
//     registerFallbackValue(FeeOption.Medium());
//     registerFallbackValue(FormSubmitted(
//       params: composeTransactionParams,
//       sourceAddress: 'source-address',
//     ));
//     registerFallbackValue(SignAndBroadcastFormSubmitted(
//       password: 'password',
//     ));
//     registerFallbackValue(composeDispenserParams);
//   });
//   setUp(() {
//     mockComposeRepository = MockComposeRepository();
//     mockAnalyticsService = MockAnalyticsService();
//     mockFetchDispenserFormDataUseCase = MockFetchDispenserFormDataUseCase();
//     mockComposeTransactionUseCase = MockComposeTransactionUseCase();
//     mockSignAndBroadcastTransactionUseCase =
//         MockSignAndBroadcastTransactionUseCase();
//     mockWriteLocalTransactionUseCase = MockWriteLocalTransactionUseCase();
//     mockAccountRepository = MockAccountRepository();
//     mockAddressRepository = MockAddressRepository();
//     mockWalletRepository = MockWalletRepository();
//     mockEncryptionService = MockEncryptionService();
//     mockAddressService = MockAddressService();
//     mockErrorService = MockErrorService();

//     GetIt.I.registerSingleton<ErrorService>(mockErrorService);

//     composeDispenserBloc = ComposeDispenserBloc(
//       logger: MockLogger(),
//       passwordRequired: true,
//       inMemoryKeyRepository: MockInMemoryKeyRepository(),
//       fetchDispenserFormDataUseCase: mockFetchDispenserFormDataUseCase,
//       composeTransactionUseCase: mockComposeTransactionUseCase,
//       composeRepository: mockComposeRepository,
//       analyticsService: mockAnalyticsService,
//       signAndBroadcastTransactionUseCase:
//           mockSignAndBroadcastTransactionUseCase,
//       writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
//     );
//   });

//   tearDown(() {
//     composeDispenserBloc.close();
//     GetIt.I.reset();
//   });

//   group(AsyncFormDependenciesRequested, () {
//     blocTest<ComposeDispenserBloc, ComposeDispenserState>(
//       'emits loading and then success states when data is fetched successfully',
//       build: () {
//         when(() => mockFetchDispenserFormDataUseCase.call(any())).thenAnswer(
//             (_) async => (mockBalances, mockFeeEstimates, <Dispenser>[]));
//         return composeDispenserBloc;
//       },
//       act: (bloc) {
//         bloc.add(AsyncFormDependenciesRequested(currentAddress: mockAddress));
//       },
//       expect: () => [
//         composeDispenserBloc.state.copyWith(
//           feeState: const FeeState.loading(),
//           balancesState: const BalancesState.loading(),
//           submitState: const FormStep(),
//           dialogState: const DialogState.loading(),
//         ),
//         composeDispenserBloc.state.copyWith(
//           balancesState: BalancesState.success(mockBalances),
//           feeState: const FeeState.success(mockFeeEstimates),
//           dialogState: const DialogState.warning(hasOpenDispensers: false),
//           submitState: const FormStep(),
//         ),
//       ],
//     );

//     blocTest<ComposeDispenserBloc, ComposeDispenserState>(
//       'emits loading and then success states when data is fetched successfully for segwit address',
//       build: () {
//         when(() => mockFetchDispenserFormDataUseCase.call(any())).thenAnswer(
//             (_) async => (mockBalances, mockFeeEstimates, <Dispenser>[]));
//         return composeDispenserBloc;
//       },
//       act: (bloc) {
//         bloc.add(
//             AsyncFormDependenciesRequested(currentAddress: 'bc1qxxxxxxxxxxxx'));
//       },
//       expect: () => [
//         composeDispenserBloc.state.copyWith(
//           feeState: const FeeState.loading(),
//           balancesState: const BalancesState.loading(),
//           submitState: const FormStep(),
//           dialogState: const DialogState.loading(),
//         ),
//         composeDispenserBloc.state.copyWith(
//           balancesState: BalancesState.success(mockBalances),
//           feeState: const FeeState.success(mockFeeEstimates),
//           dialogState: const DialogState.warning(hasOpenDispensers: false),
//           submitState: const FormStep(),
//         ),
//       ],
//     );

//     blocTest<ComposeDispenserBloc, ComposeDispenserState>(
//       'emits dispenser warning state when dispenser already exists at the current address',
//       build: () {
//         when(() => mockFetchDispenserFormDataUseCase.call(any())).thenAnswer(
//             (_) async => (mockBalances, mockFeeEstimates, mockDispenser));
//         return composeDispenserBloc;
//       },
//       act: (bloc) {
//         bloc.add(AsyncFormDependenciesRequested(currentAddress: mockAddress));
//       },
//       expect: () => [
//         composeDispenserBloc.state.copyWith(
//           feeState: const FeeState.loading(),
//           balancesState: const BalancesState.loading(),
//           submitState: const FormStep(),
//           dialogState: const DialogState.loading(),
//         ),
//         composeDispenserBloc.state.copyWith(
//           balancesState: BalancesState.success(mockBalances),
//           feeState: const FeeState.success(mockFeeEstimates),
//           dialogState: const DialogState.warning(hasOpenDispensers: true),
//           submitState: const FormStep(),
//         ),
//       ],
//     );

//     blocTest<ComposeDispenserBloc, ComposeDispenserState>(
//       'emits error state when fetching balances fails',
//       build: () {
//         when(() => mockFetchDispenserFormDataUseCase.call(any()))
//             .thenThrow(FetchBalancesException('Failed to fetch balances'));
//         return composeDispenserBloc;
//       },
//       act: (bloc) {
//         bloc.add(AsyncFormDependenciesRequested(currentAddress: mockAddress));
//       },
//       expect: () => [
//         composeDispenserBloc.state.copyWith(
//           balancesState: const BalancesState.loading(),
//           submitState: const FormStep(),
//         ),
//         composeDispenserBloc.state.copyWith(
//           balancesState: const BalancesState.error('Failed to fetch balances'),
//         ),
//       ],
//     );

//     blocTest<ComposeDispenserBloc, ComposeDispenserState>(
//       'emits error state when fetching fee estimates fails',
//       build: () {
//         when(() => mockFetchDispenserFormDataUseCase.call(any())).thenThrow(
//             FetchFeeEstimatesException('Failed to fetch fee estimates'));
//         return composeDispenserBloc;
//       },
//       act: (bloc) {
//         bloc.add(AsyncFormDependenciesRequested(currentAddress: mockAddress));
//       },
//       expect: () => [
//         composeDispenserBloc.state.copyWith(
//           feeState: const FeeState.loading(),
//           submitState: const FormStep(),
//         ),
//         composeDispenserBloc.state.copyWith(
//           feeState: const FeeState.error('Failed to fetch fee estimates'),
//         ),
//       ],
//     );
//     blocTest<ComposeDispenserBloc, ComposeDispenserState>(
//       'emits error state when unexpected error occurs',
//       build: () {
//         when(() => mockFetchDispenserFormDataUseCase.call(any()))
//             .thenThrow(Exception('Unexpected'));
//         return composeDispenserBloc;
//       },
//       act: (bloc) {
//         bloc.add(AsyncFormDependenciesRequested(currentAddress: mockAddress));
//       },
//       expect: () => [
//         composeDispenserBloc.state.copyWith(
//           feeState: const FeeState.loading(),
//           balancesState: const BalancesState.loading(),
//           submitState: const FormStep(),
//           dialogState: const DialogState.loading(),
//         ),
//         composeDispenserBloc.state.copyWith(
//           feeState: const FeeState.error(
//               'An unexpected error occurred: Exception: Unexpected'),
//           balancesState: const BalancesState.error(
//               'An unexpected error occurred: Exception: Unexpected'),
//           dialogState: const DialogState.error(
//               'An unexpected error occurred: Exception: Unexpected'),
//         ),
//       ],
//     );
//   });
//   group('ComposeTransactionEvent', () {
//     blocTest<ComposeDispenserBloc, ComposeDispenserState>(
//       'emits SubmitComposingTransaction when transaction composition succeeds',
//       build: () {
//         when(() => mockComposeTransactionUseCase
//                 .call<ComposeDispenserParams, ComposeDispenserResponseVerbose>(
//               feeRate: any(named: 'feeRate'),
//               source: any(named: 'source'),
//               params: any(named: 'params'),
//               composeFn: any(named: 'composeFn'),
//             )).thenAnswer((_) async => mockComposeDispenserResponseVerbose);

//         when(() => mockComposeDispenserResponseVerbose.btcFee).thenReturn(250);
//         when(() => mockComposeDispenserResponseVerbose.signedTxEstimatedSize)
//             .thenReturn(SignedTxEstimatedSize(
//           virtualSize: 120,
//           adjustedVirtualSize: 155,
//           sigopsCount: 1,
//         ));

//         return composeDispenserBloc;
//       },
//       seed: () => composeDispenserBloc.state.copyWith(
//         feeState: const FeeState.success(mockFeeEstimates),
//         feeOption: FeeOption.Medium(),
//       ),
//       act: (bloc) => bloc.add(FormSubmitted(
//         params: composeTransactionParams,
//         sourceAddress: 'source-address',
//       )),
//       expect: () => [
//         isA<ComposeDispenserState>().having(
//           (state) => state.submitState,
//           'submitState',
//           isA<FormStep>().having((s) => s.loading, 'loading', true),
//         ),
//         isA<ComposeDispenserState>().having(
//           (state) => state.submitState,
//           'submitState',
//           isA<ReviewStep<ComposeDispenserResponseVerbose, void>>()
//               .having((s) => s.composeTransaction, 'composeTransaction',
//                   mockComposeDispenserResponseVerbose)
//               .having((s) => s.fee, 'fee', 250)
//               .having((s) => s.feeRate, 'feeRate', 3)
//               .having((s) => s.virtualSize, 'virtualSize', 120)
//               .having((s) => s.adjustedVirtualSize, 'adjustedVirtualSize', 155),
//         ),
//       ],
//     );

//     blocTest<ComposeDispenserBloc, ComposeDispenserState>(
//       'emits SubmitComposingTransaction when transaction composition succeeds ( Custom Fee )',
//       build: () {
//         when(() => mockComposeTransactionUseCase
//                 .call<ComposeDispenserParams, ComposeDispenserResponseVerbose>(
//               feeRate: any(named: 'feeRate'),
//               source: any(named: 'source'),
//               composeFn: any(named: 'composeFn'),
//               params: any(named: 'params'),
//             )).thenAnswer((_) async => mockComposeDispenserResponseVerbose);

//         when(() => mockComposeDispenserResponseVerbose.btcFee).thenReturn(250);

//         return composeDispenserBloc;
//       },
//       seed: () => composeDispenserBloc.state.copyWith(
//         feeState: const FeeState.success(mockFeeEstimates),
//         feeOption: FeeOption.Custom(10),
//       ),
//       act: (bloc) => bloc.add(FormSubmitted(
//         params: composeTransactionParams,
//         sourceAddress: 'source-address',
//       )),
//       expect: () => [
//         isA<ComposeDispenserState>().having(
//           (state) => state.submitState,
//           'submitState',
//           isA<FormStep>().having((s) => s.loading, 'loading', true),
//         ),
//         isA<ComposeDispenserState>().having(
//             (state) => state.submitState,
//             'submitState',
//             isA<ReviewStep<ComposeDispenserResponseVerbose, void>>()
//                 .having((s) => s.composeTransaction, 'composeTransaction',
//                     mockComposeDispenserResponseVerbose)
//                 .having((s) => s.fee, 'fee', 250)
//                 .having((s) => s.feeRate, 'feeRate', 10) // custom ,
//             ),
//       ],
//     );

//     blocTest<ComposeDispenserBloc, ComposeDispenserState>(
//       'emits SubmitInitial with error when transaction composition fails',
//       build: () {
//         when(
//             () => mockComposeTransactionUseCase.call<ComposeDispenserParams,
//                     ComposeDispenserResponseVerbose>(
//                   feeRate: any(named: 'feeRate'),
//                   source: any(named: 'source'),
//                   composeFn: any(named: 'composeFn'),
//                   params: any(named: 'params'),
//                 )).thenThrow(
//             ComposeTransactionException('Compose error', StackTrace.current));

//         return composeDispenserBloc;
//       },
//       seed: () => composeDispenserBloc.state.copyWith(
//         feeState: const FeeState.success(mockFeeEstimates),
//         feeOption: FeeOption.Medium(),
//       ),
//       act: (bloc) => bloc.add(FormSubmitted(
//         params: composeTransactionParams,
//         sourceAddress: 'source-address',
//       )),
//       expect: () => [
//         isA<ComposeDispenserState>().having(
//           (state) => state.submitState,
//           'submitState',
//           isA<FormStep>().having((s) => s.loading, 'loading', true),
//         ),
//         isA<ComposeDispenserState>().having(
//           (state) => state.submitState,
//           'submitState',
//           isA<FormStep>()
//               .having((s) => s.loading, 'loading', false)
//               .having((s) => s.error, 'error', 'Compose error'),
//         ),
//       ],
//     );
//   });
//   group(ReviewSubmitted, () {
//     const fee = 250;

//     blocTest<ComposeDispenserBloc, ComposeDispenserState>(
//       'emits SubmitFinalizing when FinalizeTransactionEvent is added',
//       build: () => composeDispenserBloc,
//       act: (bloc) => bloc.add(ReviewSubmitted(
//         composeTransaction: mockComposeDispenserResponseVerbose,
//         fee: fee,
//       )),
//       expect: () => [
//         isA<ComposeDispenserState>().having(
//           (state) => state.submitState,
//           'submitState',
//           isA<PasswordStep<ComposeDispenserResponseVerbose>>()
//               .having((s) => s.loading, 'loading', false)
//               .having((s) => s.error, 'error', null)
//               .having((s) => s.composeTransaction, 'composeTransaction',
//                   mockComposeDispenserResponseVerbose)
//               .having((s) => s.fee, 'fee', fee),
//         ),
//       ],
//     );
//   });

//   group(SignAndBroadcastFormSubmitted, () {
//     const password = 'test-password';
//     const txHex = 'rawtransaction';
//     const txHash = 'transaction-hash';
//     const sourceAddress = 'source';

//     blocTest<ComposeDispenserBloc, ComposeDispenserState>(
//       'emits SubmitSuccess when transaction is signed and broadcasted successfully',
//       build: () {
//         when(() => mockSignAndBroadcastTransactionUseCase.call(
//               source: sourceAddress,
//               rawtransaction: txHex,
//               decryptionStrategy: Password(password),
//               onSuccess: any(named: 'onSuccess'),
//               onError: any(named: 'onError'),
//             )).thenAnswer((invocation) async {
//           final onSuccess =
//               invocation.namedArguments[const Symbol('onSuccess')] as Function;
//           onSuccess(txHex, txHash);
//         });

//         when(() => mockWriteLocalTransactionUseCase.call(txHex, txHash))
//             .thenAnswer((_) async {});

//         when(() => mockAnalyticsService.trackAnonymousEvent(
//               any(),
//               properties: any(named: 'properties'),
//             )).thenAnswer((_) async {});

//         return composeDispenserBloc;
//       },
//       seed: () => composeDispenserBloc.state.copyWith(
//         submitState: PasswordStep<ComposeDispenserResponseVerbose>(
//           loading: false,
//           error: null,
//           composeTransaction: mockComposeDispenserResponseVerbose,
//           fee: 250,
//         ),
//       ),
//       act: (bloc) =>
//           bloc.add(SignAndBroadcastFormSubmitted(password: password)),
//       expect: () => [
//         isA<ComposeDispenserState>().having(
//           (state) => state.submitState,
//           'submitState',
//           isA<PasswordStep<ComposeDispenserResponseVerbose>>()
//               .having((s) => s.loading, 'loading', true)
//               .having((s) => s.error, 'error', null)
//               .having((s) => s.composeTransaction, 'composeTransaction',
//                   mockComposeDispenserResponseVerbose)
//               .having((s) => s.fee, 'fee', 250),
//         ),
//         isA<ComposeDispenserState>().having(
//           (state) => state.submitState,
//           'submitState',
//           isA<SubmitSuccess>()
//               .having((s) => s.transactionHex, 'transactionHex', txHex)
//               .having((s) => s.sourceAddress, 'sourceAddress', sourceAddress),
//         ),
//       ],
//       verify: (_) {
//         verify(() => mockAnalyticsService.trackAnonymousEvent(
//               'broadcast_tx_create_dispenser',
//               properties: any(named: 'properties'),
//             )).called(1);
//       },
//     );
//     blocTest<ComposeDispenserBloc, ComposeDispenserState>(
//       'emits SubmitFinalizing with error when transaction signing fails',
//       build: () {
//         when(() => mockSignAndBroadcastTransactionUseCase.call(
//               source: any(named: "source"),
//               rawtransaction: any(named: "rawtransaction"),
//               decryptionStrategy: Password(password),
//               onSuccess: any(named: 'onSuccess'),
//               onError: any(named: 'onError'),
//             )).thenAnswer((invocation) async {
//           final onError =
//               invocation.namedArguments[const Symbol('onError')] as Function;
//           onError('Signing error');
//         });

//         return composeDispenserBloc;
//       },
//       seed: () => composeDispenserBloc.state.copyWith(
//         submitState: PasswordStep<ComposeDispenserResponseVerbose>(
//           loading: false,
//           error: null,
//           composeTransaction: mockComposeDispenserResponseVerbose,
//           fee: 250,
//         ),
//       ),
//       act: (bloc) =>
//           bloc.add(SignAndBroadcastFormSubmitted(password: password)),
//       expect: () => [
//         isA<ComposeDispenserState>().having(
//           (state) => state.submitState,
//           'submitState',
//           isA<PasswordStep<ComposeDispenserResponseVerbose>>()
//               .having((s) => s.loading, 'loading', true)
//               .having((s) => s.error, 'error', null)
//               .having((s) => s.composeTransaction, 'composeTransaction',
//                   mockComposeDispenserResponseVerbose)
//               .having((s) => s.fee, 'fee', 250),
//         ),
//         isA<ComposeDispenserState>().having(
//           (state) => state.submitState,
//           'submitState',
//           isA<PasswordStep<ComposeDispenserResponseVerbose>>()
//               .having((s) => s.loading, 'loading', false)
//               .having((s) => s.error, 'error', 'Signing error')
//               .having((s) => s.composeTransaction, 'composeTransaction',
//                   mockComposeDispenserResponseVerbose)
//               .having((s) => s.fee, 'fee', 250),
//         ),
//       ],
//     );

//     // Successful Sign and Broadcast
//   });
// }
