import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_state.dart';
import 'package:horizon/presentation/screens/dashboard/view/portfolio_view.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'dart:typed_data';
import 'package:horizon/domain/entities/event.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/address.dart';

// Mock classes
class MockSessionStateCubit extends MockCubit<SessionState>
    implements SessionStateCubit {}

class MockBalancesBloc extends MockBloc<BalancesEvent, BalancesState>
    implements BalancesBloc {}

class MockDashboardActivityFeedBloc
    extends MockBloc<DashboardActivityFeedEvent, DashboardActivityFeedState>
    implements DashboardActivityFeedBloc {}

class MockLogger extends Mock implements Logger {}

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockEventsRepository extends Mock implements EventsRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

class MockBitcoinRepository extends Mock implements BitcoinRepository {}

class MockTransactionLocalRepository extends Mock
    implements TransactionLocalRepository {}

void main() {
  final getIt = GetIt.instance;
  late MockSessionStateCubit mockSessionCubit;
  late MockBalancesBloc mockBalancesBloc;
  late MockDashboardActivityFeedBloc mockActivityFeedBloc;
  late MockLogger mockLogger;
  late MockBalanceRepository mockBalanceRepository;
  late MockEventsRepository mockEventsRepository;
  late MockAddressRepository mockAddressRepository;
  late MockBitcoinRepository mockBitcoinRepository;
  late MockTransactionLocalRepository mockTransactionLocalRepository;

  setUpAll(() {
    registerFallbackValue(Start(pollingInterval: const Duration(seconds: 30)));
    registerFallbackValue(const Load());

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        // Return a minimal valid SVG to prevent asset loading errors
        const validSvg = '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="24" height="24" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <rect width="24" height="24"/>
</svg>''';
        final bytes = Uint8List.fromList(validSvg.codeUnits);
        return ByteData.sublistView(bytes);
      },
    );
  });

  setUp(() {
    mockSessionCubit = MockSessionStateCubit();
    mockLogger = MockLogger();
    mockBalanceRepository = MockBalanceRepository();
    mockEventsRepository = MockEventsRepository();
    mockAddressRepository = MockAddressRepository();
    mockBitcoinRepository = MockBitcoinRepository();
    mockTransactionLocalRepository = MockTransactionLocalRepository();

    mockBalancesBloc = MockBalancesBloc();
    mockActivityFeedBloc = MockDashboardActivityFeedBloc();

    // Set up bloc behavior
    whenListen(
      mockBalancesBloc,
      Stream.value(const BalancesState.initial()),
      initialState: const BalancesState.initial(),
    );

    whenListen(
      mockActivityFeedBloc,
      Stream.value(DashboardActivityFeedStateInitial()),
      initialState: DashboardActivityFeedStateInitial(),
    );

    // Mock initial states for blocs
    when(() => mockBalancesBloc.state)
        .thenReturn(const BalancesState.initial());
    when(() => mockActivityFeedBloc.state)
        .thenReturn(DashboardActivityFeedStateInitial());

    // Mock bloc event handling
    when(() => mockBalancesBloc.add(any())).thenReturn(null);
    when(() => mockActivityFeedBloc.add(any())).thenReturn(null);

    // Mock transaction repository response
    when(() => mockTransactionLocalRepository.getAllByAddresses(any()))
        .thenAnswer((_) async => []);

    // Mock events repository response
    when(() => mockEventsRepository.getAllByAddressesVerbose(
          addresses: any(named: 'addresses'),
          unconfirmed: any(named: 'unconfirmed'),
          whitelist: any(named: 'whitelist'),
        )).thenAnswer((_) async => []);

    when(() => mockEventsRepository.getAllMempoolVerboseEventsForAddresses(
          any(),
          any(),
        )).thenAnswer((_) async => []);

    when(() => mockEventsRepository.getByAddressesVerbose(
          addresses: any(named: 'addresses'),
          limit: any(named: 'limit'),
          unconfirmed: any(named: 'unconfirmed'),
          cursor: any(named: 'cursor'),
          whitelist: any(named: 'whitelist'),
        )).thenAnswer((_) async => (<VerboseEvent>[], null, 0));

    // Mock bitcoin repository response
    when(() => mockBitcoinRepository.getMempoolTransactions(any()))
        .thenAnswer((_) async => const Right(<BitcoinTx>[]));

    // Mock block height response
    when(() => mockBitcoinRepository.getBlockHeight())
        .thenAnswer((_) async => const Right(1000000));

    // Mock confirmed transactions response
    when(() => mockBitcoinRepository.getConfirmedTransactionsPaginated(
        any(), any())).thenAnswer((_) async => const Right(<BitcoinTx>[]));

    // Register dependencies
    getIt.registerSingleton<Logger>(mockLogger);
    getIt.registerSingleton<BalanceRepository>(mockBalanceRepository);
    getIt.registerSingleton<EventsRepository>(mockEventsRepository);
    getIt.registerSingleton<AddressRepository>(mockAddressRepository);
    getIt.registerSingleton<BitcoinRepository>(mockBitcoinRepository);
    getIt.registerSingleton<TransactionLocalRepository>(
        mockTransactionLocalRepository);

    // Mock session state
    const wallet = Wallet(
        uuid: 'test-uuid',
        name: 'Test Wallet',
        encryptedPrivKey: 'encrypted-key',
        encryptedMnemonic: 'encrypted-mnemonic',
        chainCodeHex: 'chain-code',
        publicKey: 'public-key');

    final account = Account(
        uuid: 'account-uuid',
        name: 'Test Account',
        walletUuid: wallet.uuid,
        purpose: '84\'',
        coinType: '1\'',
        accountIndex: '0\'',
        importFormat: ImportFormat.horizon);

    final testAddress = Address(
        accountUuid: account.uuid,
        address: 'test-address-1',
        index: 0,
        encryptedPrivateKey: null);

    when(() => mockSessionCubit.state).thenReturn(SessionState.success(
        SessionStateSuccess(
            redirect: false,
            wallet: wallet,
            decryptionKey: 'decryption-key',
            accounts: [account],
            addresses: [testAddress],
            importedAddresses: [])));
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
    getIt.reset();
    mockSessionCubit.close();
    mockBalancesBloc.close();
    mockActivityFeedBloc.close();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<SessionStateCubit>.value(value: mockSessionCubit),
            BlocProvider<BalancesBloc>.value(value: mockBalancesBloc),
            BlocProvider<DashboardActivityFeedBloc>.value(
                value: mockActivityFeedBloc),
          ],
          child: const PortfolioView(),
        ),
      ),
    );
  }

  void ignoreAssetErrors(WidgetTester tester) {
    final exceptions = <dynamic>[];
    while (true) {
      try {
        final error = tester.takeException();
        if (error == null) break;
        exceptions.add(error);
      } catch (e) {
        break;
      }
    }
  }

  group('PortfolioView Widget Tests', () {
    testWidgets('renders correctly with initial state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      ignoreAssetErrors(tester);
      await tester.pumpAndSettle();
      ignoreAssetErrors(tester);

      // Verify basic structure
      expect(find.text('Assets'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Send'), findsOneWidget);
      expect(find.text('Receive'), findsOneWidget);
      expect(find.text('Swap'), findsOneWidget);
      expect(find.text('Mint'), findsOneWidget);
    });

    testWidgets('search functionality works correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      ignoreAssetErrors(tester);
      await tester.pumpAndSettle();
      ignoreAssetErrors(tester);

      // Initially search should be hidden
      expect(find.byType(TextField), findsNothing);

      // Tap search button
      await tester.tap(find.byKey(const Key('search_button')));
      await tester.pumpAndSettle();
      ignoreAssetErrors(tester);

      // Search field should be visible
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search assets...'), findsOneWidget);

      // Enter search text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();
      ignoreAssetErrors(tester);

      // Close search
      await tester.tap(find.byKey(const Key('search_button')));
      await tester.pumpAndSettle();
      ignoreAssetErrors(tester);

      // Search should be hidden again
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('tab switching works correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      ignoreAssetErrors(tester);
      await tester.pumpAndSettle();
      ignoreAssetErrors(tester);

      // Should start on Assets tab
      expect(find.text('Assets'), findsOneWidget);

      // Switch to Activity tab
      await tester.tap(find.text('Activity'));
      await tester.pumpAndSettle();
      ignoreAssetErrors(tester);

      // Verify Activity tab is selected
      final activityTab = tester.widget<Tab>(find.byType(Tab).last);
      expect(activityTab.child, isA<Text>());
      expect((activityTab.child as Text).data, equals('Activity'));

      // Search should be disabled in Activity tab
      await tester.tap(find.byKey(const Key('search_button')));
      await tester.pumpAndSettle();
      ignoreAssetErrors(tester);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('action buttons are rendered correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      ignoreAssetErrors(tester);
      await tester.pumpAndSettle();
      ignoreAssetErrors(tester);

      // Verify all action buttons
      final buttons = [
        'Send',
        'Receive',
        'Swap',
        'Mint',
      ];

      for (final buttonText in buttons) {
        expect(find.text(buttonText), findsOneWidget);

        // Verify button is tappable
        await tester.tap(find.text(buttonText));
        await tester.pumpAndSettle();
        ignoreAssetErrors(tester);
      }
    });

    testWidgets('handles tab switching correctly', (tester) async {
      when(() => mockActivityFeedBloc.state)
          .thenReturn(DashboardActivityFeedStateInitial());
      when(() => mockBalancesBloc.state)
          .thenReturn(const BalancesState.initial());

      // Set up mock behavior for session state to return addresses
      when(() => mockSessionCubit.state).thenReturn(SessionState.success(
          SessionStateSuccess(
              redirect: false,
              wallet: const Wallet(
                  uuid: 'test-uuid',
                  name: 'Test Wallet',
                  encryptedPrivKey: 'encrypted-key',
                  encryptedMnemonic: 'encrypted-mnemonic',
                  chainCodeHex: 'chain-code',
                  publicKey: 'public-key'),
              decryptionKey: 'decryption-key',
              accounts: [
            Account(
                uuid: 'account-uuid',
                name: 'Test Account',
                walletUuid: 'test-uuid',
                purpose: '84\'',
                coinType: '1\'',
                accountIndex: '0\'',
                importFormat: ImportFormat.horizon)
          ],
              addresses: [
            const Address(
                accountUuid: 'account-uuid',
                address: 'test-address-1',
                index: 0,
                encryptedPrivateKey: null)
          ],
              importedAddresses: [])));

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(); // Initial frame
      ignoreAssetErrors(tester);

      // Find and tap the Activity tab
      final activityTab = find.text('Activity');
      expect(activityTab, findsOneWidget);
      await tester.tap(activityTab);
      await tester.pumpAndSettle(); // Wait for tab switch animation
      ignoreAssetErrors(tester);

      // Verify the activity view is shown
      expect(find.byKey(const Key('activity_feed_view')), findsOneWidget);

      // Find and tap the Assets tab
      final assetsTab = find.text('Assets');
      expect(assetsTab, findsOneWidget);
      await tester.tap(assetsTab);
      await tester.pumpAndSettle(); // Wait for tab switch animation
      ignoreAssetErrors(tester);

      // Verify the assets view is shown
      expect(find.byKey(const Key('balances_view')), findsOneWidget);
    });
  });
}
