import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/dispenser_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/main.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/screens/transactions/dispenser/create_dispenser/bloc/create_dispenser_bloc.dart';
import 'package:horizon/presentation/screens/transactions/dispenser/create_dispenser/bloc/create_dispenser_event.dart';
import 'package:horizon/presentation/screens/transactions/dispenser/create_dispenser/view/create_dispenser_page.dart';
import 'package:integration_test/integration_test.dart';
import 'package:horizon/setup.dart';

import 'package:mocktail/mocktail.dart';

import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_virtual_size_usecase.dart';

import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/compose_response.dart';

import 'package:horizon/domain/repositories/in_memory_key_repository.dart';

class MockInMemoryKeyRepository extends Mock implements InMemoryKeyRepository {}

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

// class MockCreateDispenserDependenciesRequested
//     extends Mock implements CreateDispenserDependenciesRequested {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockComposeRepository extends Mock implements ComposeRepository {}

class MockDashboardActivityFeedBloc extends Mock
    implements DashboardActivityFeedBloc {}

class MockGetVirtualSizeUseCase extends Mock implements GetVirtualSizeUseCase {}

class MockSignAndBroadcastTransactionUseCase extends Mock
    implements SignAndBroadcastTransactionUseCase {}

class MockWriteLocalTransactionUseCase extends Mock
    implements WriteLocalTransactionUseCase {}

class FakeComposeDispenserParams extends Fake
    implements ComposeDispenserParams {}

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockDispenserRepository extends Mock implements DispenserRepository {}

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

class MockLogger extends Mock implements Logger {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late CreateDispenserBloc createDispenserBloc;
  late MockDashboardActivityFeedBloc mockDashboardActivityFeedBloc;

  late ComposeTransactionUseCase mockComposeTransactionUseCase;
  // late MockCreateDispenserDependenciesRequested
  //     mockCreateDispenserDependenciesRequested;
  late MockSignAndBroadcastTransactionUseCase
      mockSignAndBroadcastTransactionUseCase;
  late MockAnalyticsService mockAnalyticsService;
  late MockComposeRepository mockComposeRepository;
  late MockWriteLocalTransactionUseCase mockWriteLocalTransactionUseCase;
  late MockBalanceRepository mockBalanceRepository;
  late MockGetFeeEstimatesUseCase mockGetFeeEstimatesUseCase;
  late MockSettingsRepository mockSettingsRepository;
  late MockDispenserRepository mockDispenserRepository;

  late MockLogger mockLogger;
  setUpAll(() async {
    setup();
    await initSettings();
    registerFallbackValue(FakeAddress().address);
    registerFallbackValue(
        FakeComposeFunction<ComposeDispenserResponseVerbose>());
    registerFallbackValue(FakeComposeDispenserParams());
  });

  setUp(() {
    mockComposeTransactionUseCase = MockComposeTransactionUseCase();
    // mockCreateDispenserDependenciesRequested =
    //     MockCreateDispenserDependenciesRequested();
    mockSignAndBroadcastTransactionUseCase =
        MockSignAndBroadcastTransactionUseCase();
    mockAnalyticsService = MockAnalyticsService();
    mockComposeRepository = MockComposeRepository();
    mockWriteLocalTransactionUseCase = MockWriteLocalTransactionUseCase();
    mockLogger = MockLogger();
    mockBalanceRepository = MockBalanceRepository();
    mockGetFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();
    mockSettingsRepository = MockSettingsRepository();
    mockDispenserRepository = MockDispenserRepository();

    createDispenserBloc = CreateDispenserBloc(
      balanceRepository: mockBalanceRepository,
      getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
      composeTransactionUseCase: mockComposeTransactionUseCase,
      composeRepository: mockComposeRepository,
      signAndBroadcastTransactionUseCase:
          mockSignAndBroadcastTransactionUseCase,
      analyticsService: mockAnalyticsService,
      logger: mockLogger,
      settingsRepository: mockSettingsRepository,
      dispenserRepository: mockDispenserRepository,
      writeLocalTransactionUseCase: mockWriteLocalTransactionUseCase,
    );

    mockDashboardActivityFeedBloc = MockDashboardActivityFeedBloc();
  });

  tearDown(() async {
    await createDispenserBloc.close();
    Settings.clearCache();
  });

  group('Form Validations', () {
    testWidgets('renders correct fields', (WidgetTester tester) async {
      // Mock dependencies
      when(() => mockBalanceRepository
              .getBalancesForAddressesAndAsset(any(), any()))
          .thenAnswer((_) async => MultiAddressBalance(
                asset: 'ASSET1_DIVISIBLE',
                assetLongname: 'ASSET1_DIVISIBLE',
                total: 100000000,
                totalNormalized: '1.0',
                assetInfo: FakeAssetInfo(
                    divisible: true, assetLongname: "ASSET1_DIVISIBLE"),
                entries: [
                  MultiAddressBalanceEntry(
                    address: "test-address",
                    quantity: 100000000,
                    quantityNormalized: '1.0',
                  ),
                  MultiAddressBalanceEntry(
                    address: "test-address",
                    quantity: 100000000,
                    quantityNormalized: '1.0',
                  )
                ],
              ));
      when(() => mockGetFeeEstimatesUseCase.call()).thenAnswer(
          (_) async => const FeeEstimates(fast: 10, medium: 5, slow: 2));

      when(() => mockWriteLocalTransactionUseCase.call(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockAnalyticsService.trackEvent(any()))
          .thenAnswer((_) async {});

      // Instantiate ComposeDispenserBloc with mocks
      final composeDispenserBloc = CreateDispenserBloc(
        balanceRepository: mockBalanceRepository,
        getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
        composeTransactionUseCase: mockComposeTransactionUseCase,
        composeRepository: mockComposeRepository,
        analyticsService: mockAnalyticsService,
        signAndBroadcastTransactionUseCase:
            mockSignAndBroadcastTransactionUseCase,
        writeLocalTransactionUseCase: mockWriteLocalTransactionUseCase,
        dispenserRepository: mockDispenserRepository,
        logger: mockLogger,
        settingsRepository: mockSettingsRepository,
      );

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<CreateDispenserBloc>.value(
                    value: createDispenserBloc),
                BlocProvider<DashboardActivityFeedBloc>.value(
                    value: mockDashboardActivityFeedBloc),
              ],
              child: CreateDispenserPage(
                assetName: 'ASSET1_DIVISIBLE',
                addresses: [FakeAddress().address],
              ),
            ),
          ),
        ),
      );

      // Dispatch the FetchFormData event
      createDispenserBloc.add(CreateDispenserDependenciesRequested(
          assetName: 'ASSET1_DIVISIBLE', addresses: [FakeAddress().address]));

      // Allow time for the Bloc to process and the UI to rebuild
      await tester.pumpAndSettle();

      expect(find.text('Create Dispenser on a new address'), findsOneWidget);
      await tester.tap(find.text('Create Dispenser on a new address'));
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
      when(() => mockBalanceRepository
              .getBalancesForAddressesAndAsset(any(), any()))
          .thenAnswer((_) async => MultiAddressBalance(
                asset: 'ASSET1_NON_DIVISIBLE',
                assetLongname: 'ASSET1_NON_DIVISIBLE',
                total: 10,
                totalNormalized: '10',
                assetInfo: FakeAssetInfo(
                    divisible: false, assetLongname: "ASSET1_NON_DIVISIBLE"),
                entries: [
                  MultiAddressBalanceEntry(
                    address: "test-address",
                    quantity: 10,
                    quantityNormalized: '10',
                  ),
                  MultiAddressBalanceEntry(
                    address: "test-address",
                    quantity: 10,
                    quantityNormalized: '10',
                  )
                ],
              ));

      when(() => mockWriteLocalTransactionUseCase.call(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockAnalyticsService.trackEvent(any()))
          .thenAnswer((_) async {});

      // Instantiate ComposeDispenserBloc with mocks
      final composeDispenserBloc = CreateDispenserBloc(
        balanceRepository: mockBalanceRepository,
        getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
        composeTransactionUseCase: mockComposeTransactionUseCase,
        composeRepository: mockComposeRepository,
        analyticsService: mockAnalyticsService,
        signAndBroadcastTransactionUseCase:
            mockSignAndBroadcastTransactionUseCase,
        writeLocalTransactionUseCase: mockWriteLocalTransactionUseCase,
        dispenserRepository: mockDispenserRepository,
        logger: mockLogger,
        settingsRepository: mockSettingsRepository,
      );

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<CreateDispenserBloc>.value(
                    value: createDispenserBloc),
                BlocProvider<DashboardActivityFeedBloc>.value(
                    value: mockDashboardActivityFeedBloc),
              ],
              child: CreateDispenserPage(
                assetName: 'ASSET1_NON_DIVISIBLE',
                addresses: [FakeAddress().address],
              ),
            ),
          ),
        ),
      );

      // Dispatch the FetchFormData event
      createDispenserBloc.add(CreateDispenserDependenciesRequested(
          assetName: 'ASSET1_NON_DIVISIBLE',
          addresses: [FakeAddress().address]));

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
      when(() => mockBalanceRepository
              .getBalancesForAddressesAndAsset(any(), any()))
          .thenAnswer((_) async => MultiAddressBalance(
                asset: 'ASSET1_DIVISIBLE',
                assetLongname: 'ASSET1_DIVISIBLE',
                total: 100000000,
                totalNormalized: '1.0',
                assetInfo: FakeAssetInfo(
                    divisible: true, assetLongname: "ASSET1_DIVISIBLE"),
                entries: [
                  MultiAddressBalanceEntry(
                    address: "test-address",
                    quantity: 100000000,
                    quantityNormalized: '1.0',
                  ),
                  MultiAddressBalanceEntry(
                    address: "test-address",
                    quantity: 10,
                    quantityNormalized: '10',
                  ),
                  MultiAddressBalanceEntry(
                    address: "test-address",
                    quantity: 10,
                    quantityNormalized: '10',
                  ),
                ],
              ));

      when(() => mockWriteLocalTransactionUseCase.call(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockAnalyticsService.trackEvent(any()))
          .thenAnswer((_) async {});

      // Instantiate ComposeDispenserBloc with mocks
      final composeDispenserBloc = CreateDispenserBloc(
        balanceRepository: mockBalanceRepository,
        getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
        composeTransactionUseCase: mockComposeTransactionUseCase,
        composeRepository: mockComposeRepository,
        analyticsService: mockAnalyticsService,
        signAndBroadcastTransactionUseCase:
            mockSignAndBroadcastTransactionUseCase,
        writeLocalTransactionUseCase: mockWriteLocalTransactionUseCase,
        dispenserRepository: mockDispenserRepository,
        logger: mockLogger,
        settingsRepository: mockSettingsRepository,
      );

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<CreateDispenserBloc>.value(
                    value: createDispenserBloc),
                BlocProvider<DashboardActivityFeedBloc>.value(
                    value: mockDashboardActivityFeedBloc),
              ],
              child: CreateDispenserPage(
                assetName: 'ASSET1_DIVISIBLE',
                addresses: [FakeAddress().address],
              ),
            ),
          ),
        ),
      );

      // Dispatch the FetchFormData event
      createDispenserBloc.add(CreateDispenserDependenciesRequested(
          assetName: 'ASSET1_DIVISIBLE', addresses: [FakeAddress().address]));

      // Allow time for the Bloc to process and the UI to rebuild
      await tester.pumpAndSettle();

      expect(find.text('Continue with existing address'), findsOneWidget);

      await tester.tap(find.widgetWithText(
          ElevatedButton, 'Continue with existing address'));

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
      when(() => mockBalanceRepository
              .getBalancesForAddressesAndAsset(any(), any()))
          .thenAnswer((_) async => MultiAddressBalance(
                asset: 'ASSET1_DIVISIBLE',
                assetLongname: 'ASSET1_DIVISIBLE',
                total: 100000000,
                totalNormalized: '1.0',
                assetInfo: FakeAssetInfo(
                    divisible: true, assetLongname: "ASSET1_DIVISIBLE"),
                entries: [
                  MultiAddressBalanceEntry(
                    address: "test-address",
                    quantity: 100000000,
                    quantityNormalized: '1.0',
                  ),
                  MultiAddressBalanceEntry(
                    address: "test-address",
                    quantity: 10,
                    quantityNormalized: '10',
                  ),
                ],
              ));

      when(() => mockWriteLocalTransactionUseCase.call(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockAnalyticsService.trackEvent(any()))
          .thenAnswer((_) async {});

      // Instantiate ComposeDispenserBloc with mocks
      final createDispenserBloc = CreateDispenserBloc(
        balanceRepository: mockBalanceRepository,
        getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
        composeTransactionUseCase: mockComposeTransactionUseCase,
        composeRepository: mockComposeRepository,
        analyticsService: mockAnalyticsService,
        signAndBroadcastTransactionUseCase:
            mockSignAndBroadcastTransactionUseCase,
        writeLocalTransactionUseCase: mockWriteLocalTransactionUseCase,
        dispenserRepository: mockDispenserRepository,
        logger: mockLogger,
        settingsRepository: mockSettingsRepository,
      );

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<CreateDispenserBloc>.value(
                    value: createDispenserBloc),
                BlocProvider<DashboardActivityFeedBloc>.value(
                    value: mockDashboardActivityFeedBloc),
              ],
              child: CreateDispenserPage(
                assetName: 'ASSET1_DIVISIBLE',
                addresses: [FakeAddress().address],
              ),
            ),
          ),
        ),
      );

      // Dispatch the FetchFormData event
      createDispenserBloc.add(CreateDispenserDependenciesRequested(
          assetName: 'ASSET1_DIVISIBLE', addresses: [FakeAddress().address]));

      // Allow time for the Bloc to process and the UI to rebuild
      await tester.pumpAndSettle();

      expect(find.text('Continue with existing address'), findsOneWidget);

      await tester.tap(find.widgetWithText(
          ElevatedButton, 'Continue with existing address'));

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

      expect(find.text("Quantity exceeds available balance"), findsOneWidget);
      expect(find.text("Escrow Quantity exceeds available balance"),
          findsOneWidget);
    });

    testWidgets('ensure price per unit exceeds dust limit',
        (WidgetTester tester) async {
      // Mock dependencies
      when(() => mockGetFeeEstimatesUseCase.call()).thenAnswer(
          (_) async => const FeeEstimates(fast: 10, medium: 5, slow: 2));
      when(() => mockBalanceRepository
              .getBalancesForAddressesAndAsset(any(), any()))
          .thenAnswer((_) async => MultiAddressBalance(
                asset: 'ASSET1_DIVISIBLE',
                assetLongname: 'ASSET1_DIVISIBLE',
                total: 100000000,
                totalNormalized: '1.0',
                assetInfo: FakeAssetInfo(
                    divisible: true, assetLongname: "ASSET1_DIVISIBLE"),
                entries: [
                  MultiAddressBalanceEntry(
                    address: "test-address",
                    quantity: 100000000,
                    quantityNormalized: '1.0',
                  ),
                ],
              ));

      when(() => mockWriteLocalTransactionUseCase.call(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockAnalyticsService.trackEvent(any()))
          .thenAnswer((_) async {});

      // Instantiate ComposeDispenserBloc with mocks
      final composeDispenserBloc = CreateDispenserBloc(
        balanceRepository: mockBalanceRepository,
        getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
        composeTransactionUseCase: mockComposeTransactionUseCase,
        composeRepository: mockComposeRepository,
        analyticsService: mockAnalyticsService,
        signAndBroadcastTransactionUseCase:
            mockSignAndBroadcastTransactionUseCase,
        writeLocalTransactionUseCase: mockWriteLocalTransactionUseCase,
        dispenserRepository: mockDispenserRepository,
        logger: mockLogger,
        settingsRepository: mockSettingsRepository,
      );

      when(() => mockWriteLocalTransactionUseCase.call(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockAnalyticsService.trackEvent(any()))
          .thenAnswer((_) async {});

      // Instantiate ComposeDispenserBloc with mocks
      final createDispenserBloc = CreateDispenserBloc(
        balanceRepository: mockBalanceRepository,
        getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
        composeTransactionUseCase: mockComposeTransactionUseCase,
        composeRepository: mockComposeRepository,
        analyticsService: mockAnalyticsService,
        signAndBroadcastTransactionUseCase:
            mockSignAndBroadcastTransactionUseCase,
        writeLocalTransactionUseCase: mockWriteLocalTransactionUseCase,
        dispenserRepository: mockDispenserRepository,
        logger: mockLogger,
        settingsRepository: mockSettingsRepository,
      );

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<CreateDispenserBloc>.value(
                    value: createDispenserBloc),
                BlocProvider<DashboardActivityFeedBloc>.value(
                    value: mockDashboardActivityFeedBloc),
              ],
              child: CreateDispenserPage(
                assetName: 'ASSET1_DIVISIBLE',
                addresses: [FakeAddress().address],
              ),
            ),
          ),
        ),
      );

      // Dispatch the FetchFormData event
      createDispenserBloc.add(CreateDispenserDependenciesRequested(
          assetName: 'ASSET1_DIVISIBLE', addresses: [FakeAddress().address]));

      // Allow time for the Bloc to process and the UI to rebuild
      await tester.pumpAndSettle();

      expect(find.text('Continue with existing address'), findsOneWidget);
      await tester.tap(find.widgetWithText(
          ElevatedButton, 'Continue with existing address'));

      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('give_quantity_input_ASSET1_DIVISIBLE')), '1.0');

      await tester.enterText(
          find.byKey(const Key('escrow_quantity_input_ASSET1_DIVISIBLE')),
          '1.0');

      await tester.enterText(
          find.byKey(const Key('price_per_unit_input')), '0.00000000');

      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));

      await tester.pumpAndSettle();

      expect(find.text('Error: total price < dust limit'), findsOneWidget);
    });

    testWidgets('give_quantity <= escrow_quantity',
        (WidgetTester tester) async {
      // Mock dependencies
      when(() => mockGetFeeEstimatesUseCase.call()).thenAnswer(
          (_) async => const FeeEstimates(fast: 10, medium: 5, slow: 2));
      when(() => mockBalanceRepository
              .getBalancesForAddressesAndAsset(any(), any()))
          .thenAnswer((_) async => MultiAddressBalance(
                asset: 'ASSET1_DIVISIBLE',
                assetLongname: 'ASSET1_DIVISIBLE',
                total: 100000000,
                totalNormalized: '1.0',
                assetInfo: FakeAssetInfo(
                    divisible: true, assetLongname: "ASSET1_DIVISIBLE"),
                entries: [
                  MultiAddressBalanceEntry(
                    address: "test-address",
                    quantity: 100000000,
                    quantityNormalized: '1.0',
                  ),
                ],
              ));

      when(() => mockWriteLocalTransactionUseCase.call(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockAnalyticsService.trackEvent(any()))
          .thenAnswer((_) async {});

      // Instantiate ComposeDispenserBloc with mocks
      final composeDispenserBloc = CreateDispenserBloc(
        balanceRepository: mockBalanceRepository,
        getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
        composeTransactionUseCase: mockComposeTransactionUseCase,
        composeRepository: mockComposeRepository,
        analyticsService: mockAnalyticsService,
        signAndBroadcastTransactionUseCase:
            mockSignAndBroadcastTransactionUseCase,
        writeLocalTransactionUseCase: mockWriteLocalTransactionUseCase,
        dispenserRepository: mockDispenserRepository,
        logger: mockLogger,
        settingsRepository: mockSettingsRepository,
      );

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<CreateDispenserBloc>.value(
                    value: createDispenserBloc),
                BlocProvider<DashboardActivityFeedBloc>.value(
                    value: mockDashboardActivityFeedBloc),
              ],
              child: CreateDispenserPage(
                assetName: 'ASSET1_DIVISIBLE',
                addresses: [FakeAddress().address],
              ),
            ),
          ),
        ),
      );

      // Dispatch the FetchFormData event
      createDispenserBloc.add(CreateDispenserDependenciesRequested(
          assetName: 'ASSET1_DIVISIBLE', addresses: [FakeAddress().address]));

      // Allow time for the Bloc to process and the UI to rebuild
      await tester.pumpAndSettle();

      expect(find.text('Continue with existing address'), findsOneWidget);

      await tester.tap(find.widgetWithText(
          ElevatedButton, 'Continue with existing address'));

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
          find.text('Escrow Quantity must be >= to Quantity'), findsOneWidget);
    });
  });

  group("Tx Submission", () {
    testWidgets('calls composeTransaction use case with correct params',
        (WidgetTester tester) async {
      // Mock dependencies

      final composeDispenserResponse = ComposeDispenserResponseVerbose(
          rawtransaction: "test-raw-tx",
          name: "test-name",
          btcIn: 0,
          btcOut: 0,
          btcChange: 0,
          btcFee: 0,
          data: "test-data",
          params: const ComposeDispenserResponseVerboseParams(
            source: "test-address",
            asset: "test-asset",
            giveQuantity: 1,
            escrowQuantity: 1,
            mainchainrate: 10000,
            giveQuantityNormalized: "test-give-quantity-normalized",
            escrowQuantityNormalized: "test-escrow-quantity-normalized",
            status: 0,
          ),
          signedTxEstimatedSize: SignedTxEstimatedSize(
            virtualSize: 100,
            adjustedVirtualSize: 100,
            sigopsCount: 1,
          ));

      // Mock dependencies
      when(() => mockBalanceRepository
              .getBalancesForAddressesAndAsset(any(), any()))
          .thenAnswer((_) async => MultiAddressBalance(
                asset: 'ASSET1_DIVISIBLE',
                assetLongname: 'ASSET1_DIVISIBLE',
                total: 100000000,
                totalNormalized: '1.0',
                assetInfo: FakeAssetInfo(
                    divisible: true, assetLongname: "ASSET1_DIVISIBLE"),
                entries: [
                  MultiAddressBalanceEntry(
                    address: "test-address",
                    quantity: 100000000,
                    quantityNormalized: '1.0',
                  ),
                ],
              ));

      when(() => mockComposeTransactionUseCase
          .call<ComposeDispenserParams, ComposeDispenserResponseVerbose>(
              feeRate: 5, // medium
              source: "test-address",
              composeFn: any(named: 'composeFn'),
              params: any(named: 'params'))).thenAnswer(
        (_) async => composeDispenserResponse,
      );
      when(() => mockWriteLocalTransactionUseCase.call(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockAnalyticsService.trackEvent(any()))
          .thenAnswer((_) async {});

      // Instantiate ComposeDispenserBloc with mocks
      final composeDispenserBloc = CreateDispenserBloc(
        balanceRepository: mockBalanceRepository,
        getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
        composeTransactionUseCase: mockComposeTransactionUseCase,
        composeRepository: mockComposeRepository,
        analyticsService: mockAnalyticsService,
        signAndBroadcastTransactionUseCase:
            mockSignAndBroadcastTransactionUseCase,
        writeLocalTransactionUseCase: mockWriteLocalTransactionUseCase,
        dispenserRepository: mockDispenserRepository,
        logger: mockLogger,
        settingsRepository: mockSettingsRepository,
      );

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MediaQuery(
                data: const MediaQueryData(size: Size(900, 1300)),
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider<CreateDispenserBloc>.value(
                        value: createDispenserBloc),
                    BlocProvider<DashboardActivityFeedBloc>.value(
                        value: mockDashboardActivityFeedBloc),
                  ],
                  child: CreateDispenserPage(
                    assetName: 'ASSET1_DIVISIBLE',
                    addresses: [FakeAddress().address],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Dispatch the FetchFormData event
      createDispenserBloc.add(CreateDispenserDependenciesRequested(
          assetName: 'ASSET1_DIVISIBLE', addresses: [FakeAddress().address]));

      // Allow time for the Bloc to process and the UI to rebuild
      await tester.pumpAndSettle();

      expect(find.text('Continue with existing address'), findsOneWidget);

      await tester.tap(find.widgetWithText(
          ElevatedButton, 'Continue with existing address'));

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
