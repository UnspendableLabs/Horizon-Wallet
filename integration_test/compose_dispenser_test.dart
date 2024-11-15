import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/dispenser.dart';
import 'package:integration_test/integration_test.dart';

import 'package:mocktail/mocktail.dart';

import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/screens/compose_dispenser/view/compose_dispenser_page.dart';
import "package:horizon/presentation/screens/compose_dispenser/bloc/compose_dispenser_bloc.dart";
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_dispenser/usecase/fetch_form_data.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/shell/bloc/shell_state.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_virtual_size_usecase.dart';

import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/compose_response.dart';

class FakeVirtualSize extends Fake implements VirtualSize {
  @override
  final int virtualSize;
  @override
  final int adjustedVirtualSize;

  FakeVirtualSize(
      {required this.virtualSize, required this.adjustedVirtualSize});
}

class FakeComposeDispenserResponseVerbose extends Fake
    implements ComposeDispenserResponseVerbose {
  final int _btcFee;

  FakeComposeDispenserResponseVerbose({required int btcFee}) : _btcFee = btcFee;

  @override
  int get btcFee => _btcFee;
}

class MockComposeTransactionUseCase extends Mock
    implements ComposeTransactionUseCase {}

class MockFetchDispenserFormDataUseCase extends Mock
    implements FetchDispenserFormDataUseCase {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockComposeRepository extends Mock implements ComposeRepository {}

class MockUtxoRepository extends Mock implements UtxoRepository {}

class MockDashboardActivityFeedBloc extends Mock
    implements DashboardActivityFeedBloc {}

class MockGetVirtualSizeUseCase extends Mock implements GetVirtualSizeUseCase {}

class MockShellStateCubit extends Mock implements ShellStateCubit {
  @override
  ShellState get state => ShellState.success(ShellStateSuccess.withAccount(
        accounts: [],
        redirect: false,
        wallet: const Wallet(
          name: 'Test Wallet',
          uuid: 'test-wallet-uuid',
          publicKey: '',
          encryptedPrivKey: '',
          chainCodeHex: '',
        ),
        currentAccountUuid: 'test-account-uuid',
        addresses: [],
        currentAddress: const Address(
          address: 'test-address',
          accountUuid: 'test-account-uuid',
          index: 0,
        ),
      ));
}

class MockSignAndBroadcastTransactionUseCase extends Mock
    implements SignAndBroadcastTransactionUseCase {}

class MockWriteLocalTransactionUseCase extends Mock
    implements WriteLocalTransactionUseCase {}

class FakeComposeDispenserParams extends Fake
    implements ComposeDispenserParams {}

class FakeAssetInfo extends Fake implements AssetInfo {
  final bool _divisible;
  final String _assetLongname;

  FakeAssetInfo({required bool divisible, required String assetLongname})
      : _divisible = divisible,
        _assetLongname = assetLongname;

  @override
  bool get divisible => _divisible;

  @override
  String get assetLongname => _assetLongname;
}

class FakeAddress extends Fake implements Address {
  @override
  String get address => 'test-address';

  @override
  String get accountUuid => 'test-account-uuid';

  @override
  int get index => 0;
}

class FakeUtxo extends Fake implements Utxo {}

class FakeComposeFunction<T extends ComposeResponse> extends Fake {
  Future<T> call(int fee, List<Utxo> inputsSet) async {
    throw UnimplementedError("asdfasfd");
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late ComposeDispenserBloc composeDispenserBloc;
  late MockDashboardActivityFeedBloc mockDashboardActivityFeedBloc;

  late ComposeTransactionUseCase mockComposeTransactionUseCase;
  late MockFetchDispenserFormDataUseCase mockFetchDispenserFormDataUseCase;
  late MockSignAndBroadcastTransactionUseCase
      mockSignAndBroadcastTransactionUseCase;
  late MockAnalyticsService mockAnalyticsService;
  late MockComposeRepository mockComposeRepository;
  late MockWriteLocalTransactionUseCase mockWriteLocalTransactionUseCase;
  late MockGetVirtualSizeUseCase mockGetVirtualSizeUseCase;
  late MockUtxoRepository mockUtxoRepository;

  setUpAll(() {
    registerFallbackValue(FakeAddress().address);
    registerFallbackValue(
        FakeComposeFunction<ComposeDispenserResponseVerbose>());
    registerFallbackValue(FakeComposeDispenserParams());
  });

  setUp(() {
    mockGetVirtualSizeUseCase = MockGetVirtualSizeUseCase();
    mockUtxoRepository = MockUtxoRepository();
    mockComposeTransactionUseCase = MockComposeTransactionUseCase();
    mockFetchDispenserFormDataUseCase = MockFetchDispenserFormDataUseCase();
    mockSignAndBroadcastTransactionUseCase =
        MockSignAndBroadcastTransactionUseCase();
    mockAnalyticsService = MockAnalyticsService();
    mockComposeRepository = MockComposeRepository();
    mockWriteLocalTransactionUseCase = MockWriteLocalTransactionUseCase();

    composeDispenserBloc = ComposeDispenserBloc(
      signAndBroadcastTransactionUseCase:
          mockSignAndBroadcastTransactionUseCase,
      composeTransactionUseCase: mockComposeTransactionUseCase,
      fetchDispenserFormDataUseCase: mockFetchDispenserFormDataUseCase,
      analyticsService: mockAnalyticsService,
      composeRepository: mockComposeRepository,
      writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
    );

    mockDashboardActivityFeedBloc = MockDashboardActivityFeedBloc();
  });

  tearDown(() async {
    await composeDispenserBloc.close();
  });

  group('Form Validations', () {
    testWidgets('renders correct fields', (WidgetTester tester) async {
      // Mock dependencies
      when(() => mockFetchDispenserFormDataUseCase.call(any()))
          .thenAnswer((_) async => (
                [
                  Balance(
                    address: "test-address",
                    asset: 'ASSET1_DIVISIBLE',
                    quantity: 100000000,
                    quantityNormalized: '1.0',
                    assetInfo: FakeAssetInfo(
                        divisible: true, assetLongname: "ASSET1_DIVISIBLE"),
                  ),
                  Balance(
                    address: "test-address",
                    asset: 'ASSET2_NOT_DIVISIBLE',
                    quantity: 10,
                    quantityNormalized: '10',
                    assetInfo: FakeAssetInfo(
                        divisible: false,
                        assetLongname: "ASSET2_NOT_DIVISIBLE"),
                  ),
                ],
                const FeeEstimates(fast: 10, medium: 5, slow: 2),
                <Dispenser>[],
              ));

      when(() => mockWriteLocalTransactionUseCase.call(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockAnalyticsService.trackEvent(any()))
          .thenAnswer((_) async {});

      // Instantiate ComposeDispenserBloc with mocks
      final composeDispenserBloc = ComposeDispenserBloc(
        fetchDispenserFormDataUseCase: mockFetchDispenserFormDataUseCase,
        composeTransactionUseCase: mockComposeTransactionUseCase,
        composeRepository: mockComposeRepository,
        analyticsService: mockAnalyticsService,
        signAndBroadcastTransactionUseCase:
            mockSignAndBroadcastTransactionUseCase,
        writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
      );

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<ComposeDispenserBloc>.value(
                    value: composeDispenserBloc),
                BlocProvider<DashboardActivityFeedBloc>.value(
                    value: mockDashboardActivityFeedBloc),
              ],
              child: ComposeDispenserPage(
                address: FakeAddress().address,
                dashboardActivityFeedBloc: mockDashboardActivityFeedBloc,
              ),
            ),
          ),
        ),
      );

      // Dispatch the FetchFormData event
      composeDispenserBloc
          .add(FetchFormData(currentAddress: FakeAddress().address));

      // Allow time for the Bloc to process and the UI to rebuild
      await tester.pumpAndSettle();

      // Verify that the widgets are present
      expect(find.byKey(const Key('give_quantity_input_ASSET1_DIVISIBLE')),
          findsOneWidget);
      expect(find.byKey(const Key('escrow_quantity_input_ASSET1_DIVISIBLE')),
          findsOneWidget);
      expect(find.byKey(const Key('price_per_unit_input')), findsOneWidget);

      final assetDropdown = find.byKey(const Key("asset_dropdown"));
      expect(assetDropdown, findsOneWidget);

      await tester.tap(assetDropdown);
      await tester.pumpAndSettle();

      // it will find multiple because selected value
      // and option are rendered at once
      expect(find.text('ASSET1_DIVISIBLE'), findsWidgets);
      expect(find.text('ASSET2_NOT_DIVISIBLE'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets(
        'displays warning if a dispenser already exists at the current address',
        (WidgetTester tester) async {
      // Mock dependencies
      when(() => mockFetchDispenserFormDataUseCase.call(any()))
          .thenAnswer((_) async => (
                [
                  Balance(
                    address: "test-address",
                    asset: 'ASSET1_DIVISIBLE',
                    quantity: 100000000,
                    quantityNormalized: '1.0',
                    assetInfo: FakeAssetInfo(
                        divisible: true, assetLongname: "ASSET1_DIVISIBLE"),
                  ),
                  Balance(
                    address: "test-address",
                    asset: 'ASSET2_NOT_DIVISIBLE',
                    quantity: 10,
                    quantityNormalized: '10',
                    assetInfo: FakeAssetInfo(
                        divisible: false,
                        assetLongname: "ASSET2_NOT_DIVISIBLE"),
                  ),
                ],
                const FeeEstimates(fast: 10, medium: 5, slow: 2),
                [
                  Dispenser(
                    asset: 'ASSET1_DIVISIBLE',
                    txHash: 'test-tx-hash',
                    txIndex: 0,
                    blockIndex: 0,
                    source: 'test-source',
                    status: 0,
                    dispenseCount: 1,
                    giveQuantity: 100000000,
                    escrowQuantity: 100000000,
                    satoshirate: 100000000,
                    giveRemaining: 100000000,
                    confirmed: true,
                    origin: 'test-origin',
                    giveQuantityNormalized: '1.0',
                    giveRemainingNormalized: '1.0',
                    escrowQuantityNormalized: '1.0',
                    satoshirateNormalized: '1.0',
                    assetInfo: FakeAssetInfo(
                        divisible: true, assetLongname: "ASSET1_DIVISIBLE"),
                  ),
                ],
              ));

      when(() => mockWriteLocalTransactionUseCase.call(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockAnalyticsService.trackEvent(any()))
          .thenAnswer((_) async {});

      // Instantiate ComposeDispenserBloc with mocks
      final composeDispenserBloc = ComposeDispenserBloc(
        fetchDispenserFormDataUseCase: mockFetchDispenserFormDataUseCase,
        composeTransactionUseCase: mockComposeTransactionUseCase,
        composeRepository: mockComposeRepository,
        analyticsService: mockAnalyticsService,
        signAndBroadcastTransactionUseCase:
            mockSignAndBroadcastTransactionUseCase,
        writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
      );

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<ComposeDispenserBloc>.value(
                    value: composeDispenserBloc),
                BlocProvider<DashboardActivityFeedBloc>.value(
                    value: mockDashboardActivityFeedBloc),
              ],
              child: ComposeDispenserPage(
                address: 'bc1qxxxxxxxxx',
                dashboardActivityFeedBloc: mockDashboardActivityFeedBloc,
              ),
            ),
          ),
        ),
      );

      // Dispatch the FetchFormData event
      composeDispenserBloc
          .add(FetchFormData(currentAddress: FakeAddress().address));

      // Allow time for the Bloc to process and the UI to rebuild
      await tester.pumpAndSettle();

      // Verify that the widgets are present
      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.text('Create Dispenser on a new address'), findsOneWidget);
      expect(find.text('Continue with existing address'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('respects asset divisibility', (WidgetTester tester) async {
      // Mock dependencies
      when(() => mockFetchDispenserFormDataUseCase.call(any()))
          .thenAnswer((_) async => (
                [
                  Balance(
                    address: "test-address",
                    asset: 'ASSET1_DIVISIBLE',
                    quantity: 100000000,
                    quantityNormalized: '1.0',
                    assetInfo: FakeAssetInfo(
                        divisible: true, assetLongname: "ASSET1_DIVISIBLE"),
                  ),
                  Balance(
                    address: "test-address",
                    asset: 'ASSET2_NOT_DIVISIBLE',
                    quantity: 10,
                    quantityNormalized: '10',
                    assetInfo: FakeAssetInfo(
                        divisible: false,
                        assetLongname: "ASSET2_NOT_DIVISIBLE"),
                  ),
                ],
                const FeeEstimates(fast: 10, medium: 5, slow: 2),
                <Dispenser>[],
              ));

      when(() => mockWriteLocalTransactionUseCase.call(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockAnalyticsService.trackEvent(any()))
          .thenAnswer((_) async {});

      // Instantiate ComposeDispenserBloc with mocks
      final composeDispenserBloc = ComposeDispenserBloc(
        fetchDispenserFormDataUseCase: mockFetchDispenserFormDataUseCase,
        composeTransactionUseCase: mockComposeTransactionUseCase,
        composeRepository: mockComposeRepository,
        analyticsService: mockAnalyticsService,
        signAndBroadcastTransactionUseCase:
            mockSignAndBroadcastTransactionUseCase,
        writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
      );

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<ComposeDispenserBloc>.value(
                    value: composeDispenserBloc),
                BlocProvider<DashboardActivityFeedBloc>.value(
                    value: mockDashboardActivityFeedBloc),
              ],
              child: ComposeDispenserPage(
                address: FakeAddress().address,
                dashboardActivityFeedBloc: mockDashboardActivityFeedBloc,
              ),
            ),
          ),
        ),
      );

      // Dispatch the FetchFormData event
      composeDispenserBloc
          .add(FetchFormData(currentAddress: FakeAddress().address));

      // Allow time for the Bloc to process and the UI to rebuild
      await tester.pumpAndSettle();

      // Test with divisible asset
      await tester.enterText(
          find.byKey(const Key('give_quantity_input_ASSET1_DIVISIBLE')),
          '0.25');
      await tester.pumpAndSettle();
      expect(find.text('0.25'), findsOneWidget); // Ensure input was accepted

      await tester.enterText(
          find.byKey(const Key('escrow_quantity_input_ASSET1_DIVISIBLE')),
          '0.5');
      await tester.pumpAndSettle();
      expect(find.text('0.5'), findsOneWidget); // Ensure input was accepted

      // Change to non-divisible asset
      final assetDropdown = find.byKey(const Key('asset_dropdown'));
      await tester.tap(assetDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('ASSET2_NOT_DIVISIBLE').last);
      await tester.pumpAndSettle();

      // Verify that 'ASSET2_NOT_DIVISIBLE' is selected
      expect(find.text('ASSET2_NOT_DIVISIBLE'), findsWidgets);

      // Test with non-divisible asset
      await tester.enterText(
          find.byKey(const Key('give_quantity_input_ASSET2_NOT_DIVISIBLE')),
          '0.25');
      await tester.pumpAndSettle();
      expect(find.text('0.25'), findsNothing);
      expect(find.text('025'),
          findsOneWidget); // Non-divisible assets should not accept decimals

      await tester.enterText(
          find.byKey(const Key('escrow_quantity_input_ASSET2_NOT_DIVISIBLE')),
          '0.5');
      await tester.pumpAndSettle();
      expect(find.text('0.5'), findsNothing);

      expect(find.text('025'), findsOneWidget); // Ensure input was accepted
      expect(find.text('05'), findsOneWidget); // Ensure input was accepted

      // Switch back to the divisible asset
      await tester.tap(assetDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('ASSET1_DIVISIBLE').last);
      await tester.pumpAndSettle();

      // Confirm that inputs accept decimals again
      await tester.enterText(
          find.byKey(const Key('give_quantity_input_ASSET1_DIVISIBLE')),
          '0.25');
      await tester.pumpAndSettle();
      expect(find.text('0.25'), findsOneWidget); // Ensure input was accepted

      await tester.enterText(
          find.byKey(const Key('escrow_quantity_input_ASSET1_DIVISIBLE')),
          '0.5');
      await tester.pumpAndSettle();
      expect(find.text('0.5'), findsOneWidget); // Ensure input was accepted
    });

    testWidgets('respects asset balance', (WidgetTester tester) async {
      // Mock dependencies
      when(() => mockFetchDispenserFormDataUseCase.call(any()))
          .thenAnswer((_) async => (
                [
                  Balance(
                    address: "test-address",
                    asset: 'ASSET1_DIVISIBLE',
                    quantity: 100000000,
                    quantityNormalized: '1.0',
                    assetInfo: FakeAssetInfo(
                        divisible: true, assetLongname: "ASSET1_DIVISIBLE"),
                  ),
                  Balance(
                    address: "test-address",
                    asset: 'ASSET2_NOT_DIVISIBLE',
                    quantity: 10,
                    quantityNormalized: '10',
                    assetInfo: FakeAssetInfo(
                        divisible: false,
                        assetLongname: "ASSET2_NOT_DIVISIBLE"),
                  ),
                ],
                const FeeEstimates(fast: 10, medium: 5, slow: 2),
                <Dispenser>[],
              ));

      when(() => mockWriteLocalTransactionUseCase.call(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockAnalyticsService.trackEvent(any()))
          .thenAnswer((_) async {});

      // Instantiate ComposeDispenserBloc with mocks
      final composeDispenserBloc = ComposeDispenserBloc(
        fetchDispenserFormDataUseCase: mockFetchDispenserFormDataUseCase,
        composeTransactionUseCase: mockComposeTransactionUseCase,
        composeRepository: mockComposeRepository,
        analyticsService: mockAnalyticsService,
        signAndBroadcastTransactionUseCase:
            mockSignAndBroadcastTransactionUseCase,
        writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
      );

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<ComposeDispenserBloc>.value(
                    value: composeDispenserBloc),
                BlocProvider<DashboardActivityFeedBloc>.value(
                    value: mockDashboardActivityFeedBloc),
              ],
              child: ComposeDispenserPage(
                address: FakeAddress().address,
                dashboardActivityFeedBloc: mockDashboardActivityFeedBloc,
              ),
            ),
          ),
        ),
      );

      // Dispatch the FetchFormData event
      composeDispenserBloc
          .add(FetchFormData(currentAddress: FakeAddress().address));

      // Allow time for the Bloc to process and the UI to rebuild
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('give_quantity_input_ASSET1_DIVISIBLE')), '1.1');
      await tester.pumpAndSettle();
      expect(find.text('1.1'), findsOneWidget); // Ensure input was accepted

      await tester.enterText(
          find.byKey(const Key('escrow_quantity_input_ASSET1_DIVISIBLE')),
          '1.2');

      await tester.pumpAndSettle();

      expect(find.text('1.2'), findsOneWidget); // Ensure input was accepted
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));

      await tester.pumpAndSettle();

      expect(
          find.text("give quantity exceeds available balance"), findsOneWidget);
      expect(find.text("escrow quantity exceeds available balance"),
          findsOneWidget);
    });

    testWidgets('ensure price per unit exceeds dust limit',
        (WidgetTester tester) async {
      // Mock dependencies
      when(() => mockFetchDispenserFormDataUseCase.call(any()))
          .thenAnswer((_) async => (
                [
                  Balance(
                    address: "test-address",
                    asset: 'ASSET1_DIVISIBLE',
                    quantity: 100000000,
                    quantityNormalized: '1.0',
                    assetInfo: FakeAssetInfo(
                        divisible: true, assetLongname: "ASSET1_DIVISIBLE"),
                  ),
                  Balance(
                    address: "test-address",
                    asset: 'ASSET2_NOT_DIVISIBLE',
                    quantity: 10,
                    quantityNormalized: '10',
                    assetInfo: FakeAssetInfo(
                        divisible: false,
                        assetLongname: "ASSET2_NOT_DIVISIBLE"),
                  ),
                ],
                const FeeEstimates(fast: 10, medium: 5, slow: 2),
                <Dispenser>[],
              ));

      when(() => mockWriteLocalTransactionUseCase.call(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockAnalyticsService.trackEvent(any()))
          .thenAnswer((_) async {});

      // Instantiate ComposeDispenserBloc with mocks
      final composeDispenserBloc = ComposeDispenserBloc(
        fetchDispenserFormDataUseCase: mockFetchDispenserFormDataUseCase,
        composeTransactionUseCase: mockComposeTransactionUseCase,
        composeRepository: mockComposeRepository,
        analyticsService: mockAnalyticsService,
        signAndBroadcastTransactionUseCase:
            mockSignAndBroadcastTransactionUseCase,
        writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
      );

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<ComposeDispenserBloc>.value(
                    value: composeDispenserBloc),
                BlocProvider<DashboardActivityFeedBloc>.value(
                    value: mockDashboardActivityFeedBloc),
              ],
              child: ComposeDispenserPage(
                address: FakeAddress().address,
                dashboardActivityFeedBloc: mockDashboardActivityFeedBloc,
              ),
            ),
          ),
        ),
      );

      // Dispatch the FetchFormData event
      composeDispenserBloc
          .add(FetchFormData(currentAddress: FakeAddress().address));

      // Allow time for the Bloc to process and the UI to rebuild
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('price_per_unit_input')), '0.000005');

      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));

      await tester.pumpAndSettle();

      expect(find.text('Price must exceed dust limit of 600 satoshis'),
          findsOneWidget);
    });

    testWidgets('give_quantity <= escrow_quantity',
        (WidgetTester tester) async {
      // Mock dependencies
      when(() => mockFetchDispenserFormDataUseCase.call(any()))
          .thenAnswer((_) async => (
                [
                  Balance(
                    address: "test-address",
                    asset: 'ASSET1_DIVISIBLE',
                    quantity: 100000000,
                    quantityNormalized: '1.0',
                    assetInfo: FakeAssetInfo(
                        divisible: true, assetLongname: "ASSET1_DIVISIBLE"),
                  ),
                  Balance(
                    address: "test-address",
                    asset: 'ASSET2_NOT_DIVISIBLE',
                    quantity: 10,
                    quantityNormalized: '10',
                    assetInfo: FakeAssetInfo(
                        divisible: false,
                        assetLongname: "ASSET2_NOT_DIVISIBLE"),
                  ),
                ],
                const FeeEstimates(fast: 10, medium: 5, slow: 2),
                <Dispenser>[],
              ));

      when(() => mockWriteLocalTransactionUseCase.call(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockAnalyticsService.trackEvent(any()))
          .thenAnswer((_) async {});

      // Instantiate ComposeDispenserBloc with mocks
      final composeDispenserBloc = ComposeDispenserBloc(
        fetchDispenserFormDataUseCase: mockFetchDispenserFormDataUseCase,
        composeTransactionUseCase: mockComposeTransactionUseCase,
        composeRepository: mockComposeRepository,
        analyticsService: mockAnalyticsService,
        signAndBroadcastTransactionUseCase:
            mockSignAndBroadcastTransactionUseCase,
        writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
      );

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<ComposeDispenserBloc>.value(
                    value: composeDispenserBloc),
                BlocProvider<DashboardActivityFeedBloc>.value(
                    value: mockDashboardActivityFeedBloc),
              ],
              child: ComposeDispenserPage(
                address: FakeAddress().address,
                dashboardActivityFeedBloc: mockDashboardActivityFeedBloc,
              ),
            ),
          ),
        ),
      );

      // Dispatch the FetchFormData event
      composeDispenserBloc
          .add(FetchFormData(currentAddress: FakeAddress().address));

      // Allow time for the Bloc to process and the UI to rebuild
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('give_quantity_input_ASSET1_DIVISIBLE')), '1.1');

      await tester.enterText(
          find.byKey(const Key('escrow_quantity_input_ASSET1_DIVISIBLE')),
          '0.9');

      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));

      await tester.pumpAndSettle();

      expect(
          find.text(
              'escrow quantity must be greater than or equal to give quantity'),
          findsOneWidget);
    });
  });

  group("Tx Submission", () {
    testWidgets('calls composeTransaction use case with correct params',
        (WidgetTester tester) async {
      // Mock dependencies

      const composeDispenserResponse = ComposeDispenserResponseVerbose(
          rawtransaction: "test-raw-tx",
          name: "test-name",
          btcIn: 0,
          btcOut: 0,
          btcChange: 0,
          btcFee: 0,
          data: "test-data",
          params: ComposeDispenserResponseVerboseParams(
            source: "test-address",
            asset: "test-asset",
            giveQuantity: 1,
            escrowQuantity: 1,
            mainchainrate: 10000,
            giveQuantityNormalized: "test-give-quantity-normalized",
            escrowQuantityNormalized: "test-escrow-quantity-normalized",
            status: 0,
          ));

      // Mock dependencies
      when(() => mockFetchDispenserFormDataUseCase.call(any()))
          .thenAnswer((_) async => (
                [
                  Balance(
                    address: "test-address",
                    asset: 'ASSET1_DIVISIBLE',
                    quantity: 100000000,
                    quantityNormalized: '1.0',
                    assetInfo: FakeAssetInfo(
                        divisible: true, assetLongname: "ASSET1_DIVISIBLE"),
                  ),
                  Balance(
                    address: "test-address",
                    asset: 'ASSET2_NOT_DIVISIBLE',
                    quantity: 10,
                    quantityNormalized: '10',
                    assetInfo: FakeAssetInfo(
                        divisible: false,
                        assetLongname: "ASSET2_NOT_DIVISIBLE"),
                  ),
                ],
                const FeeEstimates(fast: 10, medium: 5, slow: 2),
                <Dispenser>[],
              ));

      when(() => mockComposeTransactionUseCase
          .call<ComposeDispenserParams, ComposeDispenserResponseVerbose>(
              feeRate: 5, // medium
              source: "test-address",
              composeFn: any(named: 'composeFn'),
              params: any(named: 'params'))).thenAnswer((_) async => (
            composeDispenserResponse,
            FakeVirtualSize(virtualSize: 100, adjustedVirtualSize: 500)
          ));
      when(() => mockWriteLocalTransactionUseCase.call(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockAnalyticsService.trackEvent(any()))
          .thenAnswer((_) async {});

      // Instantiate ComposeDispenserBloc with mocks
      final composeDispenserBloc = ComposeDispenserBloc(
        fetchDispenserFormDataUseCase: mockFetchDispenserFormDataUseCase,
        composeTransactionUseCase: mockComposeTransactionUseCase,
        composeRepository: mockComposeRepository,
        analyticsService: mockAnalyticsService,
        signAndBroadcastTransactionUseCase:
            mockSignAndBroadcastTransactionUseCase,
        writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
      );

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(size: Size(900, 1300)),
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<ComposeDispenserBloc>.value(
                      value: composeDispenserBloc),
                  BlocProvider<DashboardActivityFeedBloc>.value(
                      value: mockDashboardActivityFeedBloc),
                ],
                child: ComposeDispenserPage(
                  address: FakeAddress().address,
                  dashboardActivityFeedBloc: mockDashboardActivityFeedBloc,
                ),
              ),
            ),
          ),
        ),
      );

      // Dispatch the FetchFormData event
      composeDispenserBloc
          .add(FetchFormData(currentAddress: FakeAddress().address));

      // Allow time for the Bloc to process and the UI to rebuild
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('give_quantity_input_ASSET1_DIVISIBLE')), '1.0');

      await tester.enterText(
          find.byKey(const Key('escrow_quantity_input_ASSET1_DIVISIBLE')),
          '1.0');

      await tester.enterText(
          find.byKey(const Key('price_per_unit_input')), '0.0001');

      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));

      await tester.pumpAndSettle();

      expect(find.textContaining('Please review your transaction details.'),
          findsOneWidget);
    });
  });
  // TODO: add test to make sure compoeFn called with correct args
}
