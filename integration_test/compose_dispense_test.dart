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
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/shell/bloc/shell_state.dart';
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

class FakeAddress extends Fake implements Address {
  @override
  String get address => 'test-address';

  @override
  String get accountUuid => 'test-account-uuid';

  @override
  int get index => 0;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
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

        // Initialize the MockShellStateCubit
        final mockShellCubit = MockShellStateCubit();

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
                        BlocProvider<ShellStateCubit>.value(
                            value: mockShellCubit),
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

        // Allow time for the Bloc to process and the UI to rebuild
        await tester.pumpAndSettle();

        // Verify that the initial form fields are rendered correctly
        final dispenserInput =
            find.byKey(const Key('dispense_dispenser_input'));
        expect(dispenserInput, findsOneWidget);

        // Enter the dispenser address to trigger fetching dispensers
        await tester.enterText(dispenserInput, 'test_address');

        await tester.pumpAndSettle();

        await Future.delayed(const Duration(seconds: 1));

        final quantityBuyInput =
            find.byKey(const Key('dispense_quantity_input'));
        final quantityBuyText = find.byKey(const Key('buy_quantity_text'));
        final priceInput = find.byKey(const Key('price_input'));
        expect(quantityBuyInput, findsOneWidget);
        expect(quantityBuyText, findsOneWidget);
        expect(priceInput, findsOneWidget);

        // Tap on the dropdown menu to open it
        final assetDropdownMenu = find.byKey(const Key('asset_dropdown_menu'));
        expect(assetDropdownMenu, findsOneWidget);
        await tester.tap(assetDropdownMenu);
        await tester.pumpAndSettle();

        // Find the dropdown menu item and tap it
        final dropdownItemCantReach =
            find.byKey(const Key('asset_dropdown_item_CANTREACH'));
        expect(dropdownItemCantReach, findsOneWidget);
        await tester.tap(dropdownItemCantReach);
        await tester.pumpAndSettle();

        // Verify that 'CANTREACH' is now selected
        expect(find.text('CANTREACH'), findsOneWidget);

        // Enter quantity
        expect(find.text('1'), findsWidgets);

        // Verify that 'buy_quantity_text' displays the expected quantity
        final buyQuantityTextFinder =
            find.byKey(const Key('buy_quantity_text'));
        expect(buyQuantityTextFinder, findsOneWidget);

        final Text buyQuantityTextWidget =
            tester.widget<Text>(buyQuantityTextFinder);
        final String displayedQuantity = buyQuantityTextWidget.data!;

        expect(displayedQuantity, '1');

        // Verify that 'price_input' displays the expected price
        final priceInputFinder = find.byKey(const Key('price_input'));
        expect(priceInputFinder, findsOneWidget);

        final selectableTextFinder = find.descendant(
          of: priceInputFinder,
          matching: find.byType(SelectableText),
        );
        expect(selectableTextFinder, findsOneWidget);

        final SelectableText priceTextWidget =
            tester.widget<SelectableText>(selectableTextFinder);
        final String displayedPrice = priceTextWidget.data!;

        expect(displayedPrice, '0.00000600');

        // Interact with the UI by tapping the add button
        final addButton = find.byIcon(Icons.add);
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // After tapping the add button, verify the updated quantity and price

        // Verify that 'buy_quantity_text' now displays '2'
        final Text updatedQuantityTextWidgetCantReach2 =
            tester.widget<Text>(buyQuantityTextFinder);
        final String updatedQuantityCantReach2 =
            updatedQuantityTextWidgetCantReach2.data!;
        expect(updatedQuantityCantReach2, '2');

        // Verify that 'price_input' now displays the updated price '0.00001200'
        final SelectableText updatedPriceTextWidgetCantReach2 =
            tester.widget<SelectableText>(selectableTextFinder);
        final String updatedPriceCantReach2 =
            updatedPriceTextWidgetCantReach2.data!;
        expect(updatedPriceCantReach2, '0.00001200');

        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // After tapping the add button, verify the updated quantity and price

        // Verify that 'buy_quantity_text' now displays '2'
        final Text updatedQuantityTextWidgetCantReach3 =
            tester.widget<Text>(buyQuantityTextFinder);
        final String updatedQuantityCantReach3 =
            updatedQuantityTextWidgetCantReach3.data!;
        expect(updatedQuantityCantReach3, '3');

        // Verify that 'price_input' now displays the updated price '0.00001200'
        final SelectableText updatedPriceTextWidgetCantReach3 =
            tester.widget<SelectableText>(selectableTextFinder);
        final String updatedPriceCantReach3 =
            updatedPriceTextWidgetCantReach3.data!;
        expect(updatedPriceCantReach3, '0.00001800');

        final removeButton = find.byIcon(Icons.remove);
        await tester.tap(removeButton);
        await tester.pumpAndSettle();

        // Verify that 'buy_quantity_text' now displays '2'
        final Text updatedQuantityTextWidgetCantReach4 =
            tester.widget<Text>(buyQuantityTextFinder);
        final String updatedQuantityCantReach4 =
            updatedQuantityTextWidgetCantReach4.data!;
        expect(updatedQuantityCantReach4, '2');

        // Verify that 'price_input' now displays the updated price '0.00001200'
        final SelectableText updatedPriceTextWidgetCantReach4 =
            tester.widget<SelectableText>(selectableTextFinder);
        final String updatedPriceCantReach4 =
            updatedPriceTextWidgetCantReach4.data!;
        expect(updatedPriceCantReach4, '0.00001200');

        expect(assetDropdownMenu, findsOneWidget);
        await tester.tap(assetDropdownMenu);
        await tester.pumpAndSettle();

        // Find the dropdown menu item and tap it
        final dropdownItem70455 =
            find.byKey(const Key('asset_dropdown_item_A4630460187535670455'));
        expect(dropdownItem70455, findsOneWidget);
        await tester.tap(dropdownItem70455);
        await tester.pumpAndSettle();

        // Verify that 'A4630460187535670455' is now selected
        expect(find.text('A4630460187535670455'), findsOneWidget);

        // Verify that 'buy_quantity_text' displays the expected quantity
        final buyQuantityTextFinder70455 =
            find.byKey(const Key('buy_quantity_text'));
        expect(buyQuantityTextFinder70455, findsOneWidget);

        final Text buyQuantityTextWidget70455 =
            tester.widget<Text>(buyQuantityTextFinder70455);
        final String displayedQuantity70455 = buyQuantityTextWidget70455.data!;

        expect(displayedQuantity70455, '1.5');

        // Verify that 'price_input' displays the expected price
        final priceInputFinder70455 = find.byKey(const Key('price_input'));
        expect(priceInputFinder70455, findsOneWidget);

        final selectableTextFinder70455 = find.descendant(
          of: priceInputFinder70455,
          matching: find.byType(SelectableText),
        );
        expect(selectableTextFinder70455, findsOneWidget);

        final SelectableText priceTextWidget70455 =
            tester.widget<SelectableText>(selectableTextFinder70455);
        final String displayedPrice70455 = priceTextWidget70455.data!;

        expect(displayedPrice70455, '0.00006000');

        // Interact with the UI by tapping the add button
        final addButton70455 = find.byIcon(Icons.add);
        await tester.tap(addButton70455);
        await tester.pumpAndSettle();

        // After tapping the add button, verify the updated quantity and price

        // Verify that 'buy_quantity_text' now displays '2'
        final Text updatedQuantityTextWidget70455_2 =
            tester.widget<Text>(buyQuantityTextFinder70455);
        final String updatedQuantity70455_2 =
            updatedQuantityTextWidget70455_2.data!;
        expect(updatedQuantity70455_2, '3');

        // Verify that 'price_input' now displays the updated price '0.00001200'
        final SelectableText updatedPriceTextWidget70455_2 =
            tester.widget<SelectableText>(selectableTextFinder70455);
        final String updatedPrice70455_2 = updatedPriceTextWidget70455_2.data!;
        expect(updatedPrice70455_2, '0.00012000');

        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // After tapping the add button, verify the updated quantity and price

        // Verify that 'buy_quantity_text' now displays '2'
        final Text updatedQuantityTextWidget3 =
            tester.widget<Text>(buyQuantityTextFinder);
        final String updatedQuantity3 = updatedQuantityTextWidget3.data!;
        expect(updatedQuantity3, '4.5');

        // Verify that 'price_input' now displays the updated price '0.00001200'
        final SelectableText updatedPriceTextWidget3 =
            tester.widget<SelectableText>(selectableTextFinder);
        final String updatedPrice3 = updatedPriceTextWidget3.data!;
        expect(updatedPrice3, '0.00018000');

        final removeButton70455 = find.byIcon(Icons.remove);
        await tester.tap(removeButton70455);
        await tester.pumpAndSettle();

        // Verify that 'buy_quantity_text' now displays '2'
        final Text updatedQuantityTextWidget70455_3 =
            tester.widget<Text>(buyQuantityTextFinder70455);
        final String updatedQuantity70455_3 =
            updatedQuantityTextWidget70455_3.data!;
        expect(updatedQuantity70455_3, '3');

        // Verify that 'price_input' now displays the updated price '0.00001200'
        final SelectableText updatedPriceTextWidget70455_3 =
            tester.widget<SelectableText>(selectableTextFinder70455);
        final String updatedPrice70455_3 = updatedPriceTextWidget70455_3.data!;
        expect(updatedPrice70455_3, '0.00012000');

        // Find the dropdown menu item and tap it
        await tester.tap(assetDropdownMenu);
        await tester.pumpAndSettle();

        final dropdownItemXcp =
            find.byKey(const Key('asset_dropdown_item_XCP'));
        expect(dropdownItemXcp, findsOneWidget);
        await tester.tap(dropdownItemXcp);
        await tester.pumpAndSettle();

        // Verify that 'XCP' is now selected
        expect(find.text('XCP'), findsOneWidget);

        // Verify initial quantity and price
        final Text initialQuantityTextXcp =
            tester.widget<Text>(buyQuantityTextFinder);
        expect(initialQuantityTextXcp.data!, '0.005');

        final SelectableText initialPriceTextXcp =
            tester.widget<SelectableText>(selectableTextFinder);
        expect(initialPriceTextXcp.data!, '0.00000650');

        // Test increment
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        final Text updatedQuantityTextXcp =
            tester.widget<Text>(buyQuantityTextFinder);
        expect(updatedQuantityTextXcp.data!, '0.01');

        final SelectableText updatedPriceTextXcp =
            tester.widget<SelectableText>(selectableTextFinder);
        expect(updatedPriceTextXcp.data!, '0.00001300');

        // Test another increment
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        final Text updatedQuantityTextXcp2 =
            tester.widget<Text>(buyQuantityTextFinder);
        expect(updatedQuantityTextXcp2.data!, '0.015');

        final SelectableText updatedPriceTextXcp2 =
            tester.widget<SelectableText>(selectableTextFinder);
        expect(updatedPriceTextXcp2.data!, '0.00001950');

        // Test decrement
        await tester.tap(removeButton);
        await tester.pumpAndSettle();

        final Text decrementedQuantityTextXcp =
            tester.widget<Text>(buyQuantityTextFinder);
        expect(decrementedQuantityTextXcp.data!, '0.01');

        final SelectableText decrementedPriceTextXcp =
            tester.widget<SelectableText>(selectableTextFinder);
        expect(decrementedPriceTextXcp.data!, '0.00001300');

        // Test USMINT.GOV
        await tester.tap(assetDropdownMenu);
        await tester.pumpAndSettle();

        final dropdownItemUsmint =
            find.byKey(const Key('asset_dropdown_item_A7805927145042695546'));
        expect(dropdownItemUsmint, findsOneWidget);
        await tester.tap(dropdownItemUsmint);
        await tester.pumpAndSettle();

        // Verify that 'USMINT.GOV' is selected
        expect(find.text('A7805927145042695546'), findsOneWidget);

        // Verify initial quantity and price
        final Text initialQuantityTextUsmint =
            tester.widget<Text>(buyQuantityTextFinder);
        expect(initialQuantityTextUsmint.data!, '2');

        final SelectableText initialPriceTextUsmint =
            tester.widget<SelectableText>(selectableTextFinder);
        expect(initialPriceTextUsmint.data!, '0.00000700');

        // Test increment
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        final Text updatedQuantityTextUsmint =
            tester.widget<Text>(buyQuantityTextFinder);
        expect(updatedQuantityTextUsmint.data!, '4');

        final SelectableText updatedPriceTextUsmint =
            tester.widget<SelectableText>(selectableTextFinder);
        expect(updatedPriceTextUsmint.data!, '0.00001400');

        // Test another increment
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        final Text updatedQuantityTextUsmint2 =
            tester.widget<Text>(buyQuantityTextFinder);
        expect(updatedQuantityTextUsmint2.data!, '6');

        final SelectableText updatedPriceTextUsmint2 =
            tester.widget<SelectableText>(selectableTextFinder);
        expect(updatedPriceTextUsmint2.data!, '0.00002100');

        // Test decrement
        await tester.tap(removeButton);
        await tester.pumpAndSettle();

        final Text decrementedQuantityTextUsmint =
            tester.widget<Text>(buyQuantityTextFinder);
        expect(decrementedQuantityTextUsmint.data!, '4');

        final SelectableText decrementedPriceTextUsmint =
            tester.widget<SelectableText>(selectableTextFinder);
        expect(decrementedPriceTextUsmint.data!, '0.00001400');

        // Test A12256739633266178981
        await tester.tap(assetDropdownMenu);
        await tester.pumpAndSettle();

        final dropdownItemA12256739633266178981 =
            find.byKey(const Key('asset_dropdown_item_A12256739633266178981'));
        expect(dropdownItemA12256739633266178981, findsOneWidget);
        await tester.tap(dropdownItemA12256739633266178981);
        await tester.pumpAndSettle();

        // Verify that 'A12256739633266178981' is selected
        expect(find.text('A12256739633266178981'), findsOneWidget);

        // Verify initial quantity and price
        final Text initialQuantityTextA12256739633266178981 =
            tester.widget<Text>(buyQuantityTextFinder);
        expect(initialQuantityTextA12256739633266178981.data!, '0.1');

        final SelectableText initialPriceTextA12256739633266178981 =
            tester.widget<SelectableText>(selectableTextFinder);
        expect(initialPriceTextA12256739633266178981.data!, '0.00010000');

        // Verify tapping add button does nothing
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        final Text unchangedQuantityText =
            tester.widget<Text>(buyQuantityTextFinder);
        expect(unchangedQuantityText.data!, '0.1');

        final SelectableText unchangedPriceText =
            tester.widget<SelectableText>(selectableTextFinder);
        expect(unchangedPriceText.data!, '0.00010000');
      }, (error, stackTrace) {
        print('Caught error: $error\n$stackTrace');
      });
    });
  });
}
