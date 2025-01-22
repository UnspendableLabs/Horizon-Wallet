import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/dispenser_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_dispense/bloc/compose_dispense_bloc.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/estimate_dispenses.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/fetch_open_dispensers_on_address.dart';
import 'package:horizon/presentation/screens/compose_dispense/view/compose_dispense_modal.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart';
import 'package:horizon/setup.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFetchOpenDispensersOnAddressUseCase extends Mock
    implements FetchOpenDispensersOnAddressUseCase {}

class MockFetchDispenseFormDataUseCase extends Mock
    implements FetchDispenseFormDataUseCase {}

class MockComposeTransactionUseCase extends Mock
    implements ComposeTransactionUseCase {}

class MockSignAndBroadcastTransactionUseCase extends Mock
    implements SignAndBroadcastTransactionUseCase {}

class MockWriteLocalTransactionUseCase extends Mock
    implements WriteLocalTransactionUseCase {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockComposeRepository extends Mock implements ComposeRepository {}

class MockDashboardActivityFeedBloc extends Mock
    implements DashboardActivityFeedBloc {}

class MockDispenserRepository extends Mock implements DispenserRepository {}

class MockEstimateDispensesUseCase extends Mock
    implements EstimateDispensesUseCase {}

class MockLogger extends Mock implements Logger {}

class MockSessionStateCubit extends Mock implements SessionStateCubit {
  @override
  SessionState get state => SessionState.success(SessionStateSuccess.withAccount(
        accounts: [],
        redirect: false,
        decryptionKey: 'decryption_key',
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

class FakeAddress extends Fake implements Address {
  @override
  String get address => 'test-address';

  @override
  String get accountUuid => 'test-account-uuid';

  @override
  int get index => 0;
}

// Helper function to verify dispenser details
Future<void> _verifyDispenserDetails({
  required WidgetTester tester,
  required String assetName,
  required String initialQuantity,
  required String initialPrice,
  required String assetId,
  required List<String> incrementQuantities,
  required List<String> incrementPrices,
  String? decrementQuantity,
  String? decrementPrice,
  int? maxLots,
}) async {
  // Select the dispenser from dropdown
  final assetDropdownMenu = find.byKey(const Key('asset_dropdown_menu'));
  await tester.tap(assetDropdownMenu);
  await tester.pumpAndSettle();

  final dropdownItem = find.byKey(Key('asset_dropdown_item_$assetId'));
  expect(dropdownItem, findsOneWidget);
  await tester.tap(dropdownItem);
  await tester.pumpAndSettle();

  // Verify asset is selected
  expect(find.text(assetName), findsOneWidget);

  // Verify initial quantity, price, and lots
  final buyQuantityTextFinder = find.byKey(const Key('buy_quantity_text'));
  final priceInputFinder = find.byKey(const Key('price_input'));
  final lotInputFinder = find.byKey(const Key('lot_input'));
  final selectableTextFinder = find.descendant(
    of: priceInputFinder,
    matching: find.byType(SelectableText),
  );

  expect(tester.widget<Text>(buyQuantityTextFinder).data!, initialQuantity);
  expect(
      tester.widget<SelectableText>(selectableTextFinder).data!, initialPrice);

  // Get the HorizonTextFormField widget and check its controller
  final lotInput = tester.widget<HorizonTextFormField>(lotInputFinder);
  expect(lotInput.controller!.text, '1');

  // Only test increments if we haven't reached maxLots
  if (maxLots == null || maxLots > 1) {
    final addButton = find.byIcon(Icons.add);
    for (int i = 0;
        i < incrementQuantities.length && (maxLots == null || i + 2 <= maxLots);
        i++) {
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(tester.widget<Text>(buyQuantityTextFinder).data!,
          incrementQuantities[i]);
      expect(tester.widget<SelectableText>(selectableTextFinder).data!,
          incrementPrices[i]);

      // Verify lot count increased
      final updatedLotInput =
          tester.widget<HorizonTextFormField>(lotInputFinder);
      expect(updatedLotInput.controller!.text, '${i + 2}');
    }

    // Test decrement if provided and we've incremented at least once
    if (decrementQuantity != null && decrementPrice != null) {
      final removeButton = find.byIcon(Icons.remove);
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      expect(
          tester.widget<Text>(buyQuantityTextFinder).data!, decrementQuantity);
      expect(tester.widget<SelectableText>(selectableTextFinder).data!,
          decrementPrice);

      // Verify lot count decreased
      final decrementedLotInput =
          tester.widget<HorizonTextFormField>(lotInputFinder);
      expect(decrementedLotInput.controller!.text,
          '${incrementQuantities.length}');
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    setup();
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FlutterError: ${details.exception}\n${details.stack}');
    };
  });

  group('ComposeDispensePage Integration Test', () {
    late ComposeDispenseBloc composeDispenseBloc;
    late MockFetchOpenDispensersOnAddressUseCase
        mockFetchOpenDispensersOnAddressUseCase;
    late MockFetchDispenseFormDataUseCase mockFetchDispenseFormDataUseCase;
    late MockComposeTransactionUseCase mockComposeTransactionUseCase;
    late MockSignAndBroadcastTransactionUseCase
        mockSignAndBroadcastTransactionUseCase;
    late MockWriteLocalTransactionUseCase mockWriteLocalTransactionUseCase;
    late MockAnalyticsService mockAnalyticsService;
    late MockComposeRepository mockComposeRepository;
    late MockDashboardActivityFeedBloc mockDashboardActivityFeedBloc;
    late MockLogger mockLogger;
    late MockDispenserRepository mockDispenserRepository;
    late MockEstimateDispensesUseCase mockEstimateDispensesUseCase;
    setUpAll(() {
      registerFallbackValue(FakeAddress());
    });

    setUp(() {
      mockFetchOpenDispensersOnAddressUseCase =
          MockFetchOpenDispensersOnAddressUseCase();
      mockFetchDispenseFormDataUseCase = MockFetchDispenseFormDataUseCase();
      mockComposeTransactionUseCase = MockComposeTransactionUseCase();
      mockSignAndBroadcastTransactionUseCase =
          MockSignAndBroadcastTransactionUseCase();
      mockWriteLocalTransactionUseCase = MockWriteLocalTransactionUseCase();
      mockAnalyticsService = MockAnalyticsService();
      mockComposeRepository = MockComposeRepository();
      mockDashboardActivityFeedBloc = MockDashboardActivityFeedBloc();
      mockLogger = MockLogger();
      mockDispenserRepository = MockDispenserRepository();
      mockEstimateDispensesUseCase = MockEstimateDispensesUseCase();
      composeDispenseBloc = ComposeDispenseBloc(
        fetchOpenDispensersOnAddressUseCase:
            mockFetchOpenDispensersOnAddressUseCase,
        fetchDispenseFormDataUseCase: mockFetchDispenseFormDataUseCase,
        composeTransactionUseCase: mockComposeTransactionUseCase,
        signAndBroadcastTransactionUseCase:
            mockSignAndBroadcastTransactionUseCase,
        writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
        analyticsService: mockAnalyticsService,
        composeRepository: mockComposeRepository,
        logger: mockLogger,
        dispenserRepository: mockDispenserRepository,
        estimateDispensesUseCase: mockEstimateDispensesUseCase,
      );
    });

    tearDown(() {
      composeDispenseBloc.close();
    });

    testWidgets('renders initial form fields with mocked dispensers',
        (WidgetTester tester) async {
      await runZonedGuarded(() async {
        // Mock the dispensers
        final dispensers = [
          Dispenser(
            txIndex: 2977292,
            txHash: "txHash1",
            blockIndex: 875048,
            source: "test_address",
            asset: "A4630460187535670455",
            giveQuantity: 150000000,
            escrowQuantity: 15050000000,
            satoshirate: 6000,
            status: 0,
            giveRemaining: 15050000000,
            oracleAddress: null,
            lastStatusTxHash: null,
            origin: "test_address",
            dispenseCount: 0,
            lastStatusTxSource: null,
            closeBlockIndex: null,
            price: 40000,
            assetInfo: const AssetInfo(
              assetLongname: null,
              description: "",
              issuer: "test_address",
              divisible: true,
            ),
            giveQuantityNormalized: "1.50000000",
            giveRemainingNormalized: "150.50000000",
            escrowQuantityNormalized: "150.50000000",
            satoshirateNormalized: "0.00006000",
            satoshiPriceNormalized: "0.00006000",
            priceNormalized: "0.0000400000000000",
            confirmed: true,
            blockTime: 1734377644,
          ),
          Dispenser(
            txIndex: 2977248,
            txHash: "txHash2",
            blockIndex: 875030,
            source: "test_address",
            asset: "CANTREACH",
            giveQuantity: 1,
            escrowQuantity: 10,
            satoshirate: 600,
            status: 0,
            giveRemaining: 10,
            oracleAddress: null,
            lastStatusTxHash: null,
            origin: "test_address",
            dispenseCount: 0,
            lastStatusTxSource: null,
            closeBlockIndex: null,
            price: 600,
            assetInfo: const AssetInfo(
              assetLongname: null,
              description: "https://example.com/CANTR.json",
              issuer: "bc1q44dnlzkngksuttmds54rhw9q04wqmfr9sq5u0z",
              divisible: false,
            ),
            giveQuantityNormalized: "1",
            giveRemainingNormalized: "10",
            escrowQuantityNormalized: "10",
            satoshirateNormalized: "0.00000600",
            satoshiPriceNormalized: "0.00000600",
            priceNormalized: "600.0000000000000000",
            confirmed: true,
            blockTime: 1734367168,
          ),
          Dispenser(
            txIndex: 2757921,
            txHash: "txHash3",
            blockIndex: 864928,
            source: "test_address",
            asset: "A12256739633266178981",
            giveQuantity: 10000000,
            escrowQuantity: 10000000,
            satoshirate: 10000,
            status: 0,
            giveRemaining: 10000000,
            oracleAddress: null,
            lastStatusTxHash: null,
            origin: "test_address",
            dispenseCount: 0,
            lastStatusTxSource: null,
            closeBlockIndex: null,
            price: 1000,
            assetInfo: const AssetInfo(
              assetLongname: null,
              description: "a new description",
              issuer: "test_address",
              divisible: true,
            ),
            giveQuantityNormalized: "0.10000000",
            giveRemainingNormalized: "0.10000000",
            escrowQuantityNormalized: "0.10000000",
            satoshirateNormalized: "0.00010000",
            satoshiPriceNormalized: "0.00010000",
            priceNormalized: "0.0010000000000000",
            confirmed: true,
            blockTime: 1728499156,
          ),
          Dispenser(
            txIndex: 2977567,
            txHash: "txHash4",
            blockIndex: 875193,
            source: "test_address",
            asset: "XCP",
            giveQuantity: 500000,
            escrowQuantity: 50000000,
            satoshirate: 650,
            status: 0,
            giveRemaining: 50000000,
            oracleAddress: null,
            lastStatusTxHash: null,
            origin: "test_address",
            dispenseCount: 0,
            lastStatusTxSource: null,
            closeBlockIndex: null,
            price: 1300,
            assetInfo: const AssetInfo(
              assetLongname: null,
              description: "The Counterparty protocol native currency",
              issuer: null,
              divisible: true,
            ),
            giveQuantityNormalized: "0.00500000",
            giveRemainingNormalized: "0.50000000",
            escrowQuantityNormalized: "0.50000000",
            satoshirateNormalized: "0.00000650",
            satoshiPriceNormalized: "0.00000650",
            priceNormalized: "0.0013000000000000",
            confirmed: true,
            blockTime: 1734463560,
          ),
          Dispenser(
            txIndex: 2977566,
            txHash: "txHash5",
            blockIndex: 875192,
            source: "test_address",
            asset: "A7805927145042695546",
            giveQuantity: 2,
            escrowQuantity: 18,
            satoshirate: 700,
            status: 0,
            giveRemaining: 18,
            oracleAddress: null,
            lastStatusTxHash: null,
            origin: "test_address",
            dispenseCount: 0,
            lastStatusTxSource: null,
            closeBlockIndex: null,
            price: 350000,
            assetInfo: const AssetInfo(
              assetLongname: "USMINT.GOV",
              description: "",
              issuer: "bc1qtke38j72qv4d8eljn7pccaykypw8luytfwdn7q",
              divisible: false,
            ),
            giveQuantityNormalized: "2",
            giveRemainingNormalized: "18",
            escrowQuantityNormalized: "18",
            satoshirateNormalized: "0.00000700",
            satoshiPriceNormalized: "0.00000700",
            priceNormalized: "350.0000000000000000",
            confirmed: true,
            blockTime: 1734463101,
          ),
        ];

        // Mock the fee estimates
        const feeEstimates = FeeEstimates(fast: 10, medium: 5, slow: 2);

        // Setup mocks
        when(() => mockFetchOpenDispensersOnAddressUseCase.call(any()))
            .thenAnswer((_) async => dispensers);

        when(() => mockFetchDispenseFormDataUseCase.call(any()))
            .thenAnswer((_) async => feeEstimates);

        when(() => mockAnalyticsService.trackEvent(any()))
            .thenAnswer((_) async {});

        // Initialize the MockSessionStateCubit
        final mockSessionCubit = MockSessionStateCubit();

        // Build the widget tree
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Directionality(
                textDirection: TextDirection.ltr,
                child: SingleChildScrollView(
                  child: MediaQuery(
                    data: const MediaQueryData(size: Size(900, 1300)),
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider<ComposeDispenseBloc>.value(
                            value: composeDispenseBloc),
                        BlocProvider<DashboardActivityFeedBloc>.value(
                            value: mockDashboardActivityFeedBloc),
                        BlocProvider<SessionStateCubit>.value(
                            value: mockSessionCubit),
                      ],
                      child: ComposeDispensePage(
                        key: const Key('compose_dispense_page'),
                        address: FakeAddress().address,
                        dashboardActivityFeedBloc:
                            mockDashboardActivityFeedBloc,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        // Wait for the widget tree to build
        await tester.pumpAndSettle();

        // Dispatch the FetchFormData event
        composeDispenseBloc.add(FetchFormData(
          currentAddress: FakeAddress().address,
        ));

        // Allow time for the bloc to process the event and rebuild the UI
        await tester.pumpAndSettle();


        // Find the TextFormField using bySemanticsLabel
        final dispenserInput = find.bySemanticsLabel('Dispenser Address');
        await tester.pumpAndSettle();

        // Verify that the dispenser input is present
        expect(dispenserInput, findsOneWidget);

        // Enter text into the dispenser input field
        await tester.enterText(dispenserInput, 'test_address');

        // Pump to process the text input
        await tester.pumpAndSettle();

        await Future.delayed(const Duration(seconds: 1));

        final quantityBuyInput =
            find.byKey(const Key('dispense_quantity_input'));
        final quantityBuyText = find.byKey(const Key('buy_quantity_text'));
        final priceInput = find.byKey(const Key('price_input'));
        expect(quantityBuyInput, findsOneWidget);
        expect(quantityBuyText, findsOneWidget);
        expect(priceInput, findsOneWidget);

        // Test CANTREACH dispenser
        await _verifyDispenserDetails(
          tester: tester,
          assetName: 'CANTREACH',
          initialQuantity: '1',
          initialPrice: '0.00000600',
          assetId: 'CANTREACH',
          incrementQuantities: ['2', '3'],
          incrementPrices: ['0.00001200', '0.00001800'],
          decrementQuantity: '2',
          decrementPrice: '0.00001200',
        );

        // Test A4630460187535670455 dispenser
        await _verifyDispenserDetails(
          tester: tester,
          assetName: 'A4630460187535670455',
          initialQuantity: '1.5',
          initialPrice: '0.00006000',
          assetId: 'A4630460187535670455',
          incrementQuantities: ['3', '4.5'],
          incrementPrices: ['0.00012000', '0.00018000'],
          decrementQuantity: '3',
          decrementPrice: '0.00012000',
        );

        // Test XCP dispenser
        await _verifyDispenserDetails(
          tester: tester,
          assetName: 'XCP',
          initialQuantity: '0.005',
          initialPrice: '0.00000650',
          assetId: 'XCP',
          incrementQuantities: ['0.01', '0.015'],
          incrementPrices: ['0.00001300', '0.00001950'],
          decrementQuantity: '0.01',
          decrementPrice: '0.00001300',
        );

        // Test USMINT.GOV dispenser
        await _verifyDispenserDetails(
          tester: tester,
          assetName: 'USMINT.GOV',
          initialQuantity: '2',
          initialPrice: '0.00000700',
          assetId: 'A7805927145042695546',
          incrementQuantities: ['4', '6'],
          incrementPrices: ['0.00001400', '0.00002100'],
          decrementQuantity: '4',
          decrementPrice: '0.00001400',
        );

        // Test A12256739633266178981 dispenser
        await _verifyDispenserDetails(
          tester: tester,
          assetName: 'A12256739633266178981',
          initialQuantity: '0.1',
          initialPrice: '0.00010000',
          assetId: 'A12256739633266178981',
          incrementQuantities: ['0.1', '0.1'],
          incrementPrices: ['0.00010000', '0.00010000'],
          maxLots: 1,
        );
      }, (error, stackTrace) {
        print('Caught error: $error\n$stackTrace');
      });
    });

    testWidgets('lot input functionality works correctly for all dispensers',
        (WidgetTester tester) async {
      await runZonedGuarded(() async {
        // Use the same setup as the previous test
        final dispensers = [
          Dispenser(
            txIndex: 2977292,
            txHash: "txHash1",
            blockIndex: 875048,
            source: "test_address",
            asset: "A4630460187535670455",
            giveQuantity: 150000000,
            escrowQuantity: 15050000000,
            satoshirate: 6000,
            status: 0,
            giveRemaining: 15050000000,
            oracleAddress: null,
            lastStatusTxHash: null,
            origin: "test_address",
            dispenseCount: 0,
            lastStatusTxSource: null,
            closeBlockIndex: null,
            price: 40000,
            assetInfo: const AssetInfo(
              assetLongname: null,
              description: "",
              issuer: "test_address",
              divisible: true,
            ),
            giveQuantityNormalized: "1.50000000",
            giveRemainingNormalized: "150.50000000",
            escrowQuantityNormalized: "150.50000000",
            satoshirateNormalized: "0.00006000",
            satoshiPriceNormalized: "0.00006000",
            priceNormalized: "0.0000400000000000",
            confirmed: true,
            blockTime: 1734377644,
          ),
          Dispenser(
            txIndex: 2977248,
            txHash: "txHash2",
            blockIndex: 875030,
            source: "test_address",
            asset: "CANTREACH",
            giveQuantity: 1,
            escrowQuantity: 10,
            satoshirate: 600,
            status: 0,
            giveRemaining: 10,
            oracleAddress: null,
            lastStatusTxHash: null,
            origin: "test_address",
            dispenseCount: 0,
            lastStatusTxSource: null,
            closeBlockIndex: null,
            price: 600,
            assetInfo: const AssetInfo(
              assetLongname: null,
              description: "https://example.com/CANTR.json",
              issuer: "bc1q44dnlzkngksuttmds54rhw9q04wqmfr9sq5u0z",
              divisible: false,
            ),
            giveQuantityNormalized: "1",
            giveRemainingNormalized: "10",
            escrowQuantityNormalized: "10",
            satoshirateNormalized: "0.00000600",
            satoshiPriceNormalized: "0.00000600",
            priceNormalized: "600.0000000000000000",
            confirmed: true,
            blockTime: 1734367168,
          ),
          Dispenser(
            txIndex: 2757921,
            txHash: "txHash3",
            blockIndex: 864928,
            source: "test_address",
            asset: "A12256739633266178981",
            giveQuantity: 10000000,
            escrowQuantity: 10000000,
            satoshirate: 10000,
            status: 0,
            giveRemaining: 10000000,
            oracleAddress: null,
            lastStatusTxHash: null,
            origin: "test_address",
            dispenseCount: 0,
            lastStatusTxSource: null,
            closeBlockIndex: null,
            price: 1000,
            assetInfo: const AssetInfo(
              assetLongname: null,
              description: "a new description",
              issuer: "test_address",
              divisible: true,
            ),
            giveQuantityNormalized: "0.10000000",
            giveRemainingNormalized: "0.10000000",
            escrowQuantityNormalized: "0.10000000",
            satoshirateNormalized: "0.00010000",
            satoshiPriceNormalized: "0.00010000",
            priceNormalized: "0.0010000000000000",
            confirmed: true,
            blockTime: 1728499156,
          ),
          Dispenser(
            txIndex: 2977567,
            txHash: "txHash4",
            blockIndex: 875193,
            source: "test_address",
            asset: "XCP",
            giveQuantity: 500000,
            escrowQuantity: 50000000,
            satoshirate: 650,
            status: 0,
            giveRemaining: 50000000,
            oracleAddress: null,
            lastStatusTxHash: null,
            origin: "test_address",
            dispenseCount: 0,
            lastStatusTxSource: null,
            closeBlockIndex: null,
            price: 1300,
            assetInfo: const AssetInfo(
              assetLongname: null,
              description: "The Counterparty protocol native currency",
              issuer: null,
              divisible: true,
            ),
            giveQuantityNormalized: "0.00500000",
            giveRemainingNormalized: "0.50000000",
            escrowQuantityNormalized: "0.50000000",
            satoshirateNormalized: "0.00000650",
            satoshiPriceNormalized: "0.00000650",
            priceNormalized: "0.0013000000000000",
            confirmed: true,
            blockTime: 1734463560,
          ),
          Dispenser(
            txIndex: 2977566,
            txHash: "txHash5",
            blockIndex: 875192,
            source: "test_address",
            asset: "A7805927145042695546",
            giveQuantity: 2,
            escrowQuantity: 18,
            satoshirate: 700,
            status: 0,
            giveRemaining: 18,
            oracleAddress: null,
            lastStatusTxHash: null,
            origin: "test_address",
            dispenseCount: 0,
            lastStatusTxSource: null,
            closeBlockIndex: null,
            price: 350000,
            assetInfo: const AssetInfo(
              assetLongname: "USMINT.GOV",
              description: "",
              issuer: "bc1qtke38j72qv4d8eljn7pccaykypw8luytfwdn7q",
              divisible: false,
            ),
            giveQuantityNormalized: "2",
            giveRemainingNormalized: "18",
            escrowQuantityNormalized: "18",
            satoshirateNormalized: "0.00000700",
            satoshiPriceNormalized: "0.00000700",
            priceNormalized: "350.0000000000000000",
            confirmed: true,
            blockTime: 1734463101,
          ),
        ];
        const feeEstimates = FeeEstimates(fast: 10, medium: 5, slow: 2);

        // Setup mocks
        when(() => mockFetchOpenDispensersOnAddressUseCase.call(any()))
            .thenAnswer((_) async => dispensers);
        when(() => mockFetchDispenseFormDataUseCase.call(any()))
            .thenAnswer((_) async => feeEstimates);
        when(() => mockAnalyticsService.trackEvent(any()))
            .thenAnswer((_) async {});

        // Initialize the MockSessionStateCubit
        final mockSessionCubit = MockSessionStateCubit();

        // Build the widget tree (same as previous test)
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Directionality(
                textDirection: TextDirection.ltr,
                child: SingleChildScrollView(
                  child: MediaQuery(
                    data: const MediaQueryData(size: Size(900, 1300)),
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider<ComposeDispenseBloc>.value(
                            value: composeDispenseBloc),
                        BlocProvider<DashboardActivityFeedBloc>.value(
                            value: mockDashboardActivityFeedBloc),
                        BlocProvider<SessionStateCubit>.value(
                            value: mockSessionCubit),
                      ],
                      child: ComposeDispensePage(
                        key: const Key('compose_dispense_page'),
                        address: FakeAddress().address,
                        dashboardActivityFeedBloc:
                            mockDashboardActivityFeedBloc,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        // Dispatch the FetchFormData event
        composeDispenseBloc.add(FetchFormData(
          currentAddress: FakeAddress().address,
        ));

        await tester.pumpAndSettle();

        // Find the TextFormField using bySemanticsLabel
        final dispenserInput = find.bySemanticsLabel('Dispenser Address');
        await tester.pumpAndSettle();

        // Verify that the dispenser input is present
        expect(dispenserInput, findsOneWidget);
        await tester.enterText(dispenserInput, 'test_address');
        await tester.pumpAndSettle();

        // Find and tap the Lots radio button
        final lotsRadio = find.byType(Radio<InputMethod>).at(1);
        await tester.tap(lotsRadio);
        await tester.pumpAndSettle();

        // Test CANTREACH dispenser
        await _testDispenserLotInput(
          tester: tester,
          assetName: 'CANTREACH',
          giveQuantity: '1',
          maxLots: 10,
          testLots: ['5', '10', '11'],
          expectedQuantities: ['5', '10', '10'],
          expectedPrices: ['0.00003000', '0.00006000', '0.00006000'],
          expectedError:
              'Lots entered are greater\nthan lots available.\nMax: 10',
        );

        // Test A4630460187535670455 dispenser
        await _testDispenserLotInput(
          tester: tester,
          assetName: 'A4630460187535670455',
          giveQuantity: '1.50000000',
          maxLots: 100,
          testLots: ['50', '100', '101'],
          expectedQuantities: ['75', '150', '150'],
          expectedPrices: ['0.00300000', '0.00600000', '0.00600000'],
          expectedError:
              'Lots entered are greater\nthan lots available.\nMax: 100',
        );

        // Test XCP dispenser
        await _testDispenserLotInput(
          tester: tester,
          assetName: 'XCP',
          giveQuantity: '0.00500000',
          maxLots: 100,
          testLots: ['50', '100', '101'],
          expectedQuantities: ['0.25', '0.5', '0.5'],
          expectedPrices: ['0.00032500', '0.00065000', '0.00065000'],
          expectedError:
              'Lots entered are greater\nthan lots available.\nMax: 100',
        );

        // Test USMINT.GOV dispenser
        await _testDispenserLotInput(
          tester: tester,
          assetName: 'USMINT.GOV',
          giveQuantity: '2',
          maxLots: 9,
          testLots: ['5', '9', '10'],
          expectedQuantities: ['10', '18', '18'],
          expectedPrices: ['0.00003500', '0.00006300', '0.00006300'],
          expectedError:
              'Lots entered are greater\nthan lots available.\nMax: 9',
          assetLongname: 'A7805927145042695546',
        );

        // Test A12256739633266178981 dispenser
        await _testDispenserLotInput(
          tester: tester,
          assetName: 'A12256739633266178981',
          giveQuantity: '0.10000000',
          maxLots: 1,
          testLots: ['1', '2'],
          expectedQuantities: ['0.1', '0.1'],
          expectedPrices: ['0.00010000', '0.00010000'],
          expectedError:
              'Lots entered are greater\nthan lots available.\nMax: 1',
        );
      }, (error, stackTrace) {
        print('Caught error: $error\n$stackTrace');
      });
    });
  });
}

// Helper function to test lot input for a specific dispenser
Future<void> _testDispenserLotInput({
  required WidgetTester tester,
  required String assetName,
  required String giveQuantity,
  required int maxLots,
  required List<String> testLots,
  required List<String> expectedQuantities,
  required List<String> expectedPrices,
  required String expectedError,
  String? assetLongname,
}) async {
  // Select the dispenser from dropdown
  final assetDropdownMenu = find.byKey(const Key('asset_dropdown_menu'));
  await tester.tap(assetDropdownMenu);
  await tester.pumpAndSettle();

  final dropdownItem =
      find.byKey(Key('asset_dropdown_item_${assetLongname ?? assetName}'));
  await tester.tap(dropdownItem);
  await tester.pumpAndSettle();

  // Verify the asset is selected
  expect(find.text(assetName), findsOneWidget);

  // Find the lot input field
  final lotInput = find.byKey(const Key('lot_input'));
  expect(lotInput, findsOneWidget);

  // Verify helper text shows correct max lots
  expect(find.text('Max Lots available: $maxLots'), findsOneWidget);

  // Test different lot quantities
  for (int i = 0; i < testLots.length; i++) {
    // Clear the lot input
    await tester.tap(lotInput);
    await tester.pumpAndSettle();
    await tester.enterText(lotInput, testLots[i]);
    await tester.pumpAndSettle();

    // Verify error message for overflow
    if (int.parse(testLots[i]) > maxLots) {
      expect(find.text(expectedError), findsOneWidget);
      return;
    }

    // Verify quantity
    final buyQuantityText = find.byKey(const Key('buy_quantity_text'));
    expect(
      tester.widget<Text>(buyQuantityText).data,
      expectedQuantities[i],
    );

    // Verify price
    final priceInput = find.byKey(const Key('price_input'));
    final priceText = find.descendant(
      of: priceInput,
      matching: find.byType(SelectableText),
    );
    expect(
      tester.widget<SelectableText>(priceText).data,
      expectedPrices[i],
    );
  }
}
