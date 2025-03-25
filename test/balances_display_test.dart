import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/common/no_data.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';
import 'package:horizon/presentation/screens/dashboard/view/balances_display.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

abstract class Config {
  bool get isMobile;
}

class MockBalancesBloc extends MockBloc<BalancesEvent, BalancesState>
    implements BalancesBloc {
  @override
  final BalanceRepository balanceRepository;
  @override
  final List<String> addresses;
  @override
  final CacheProvider cacheProvider;

  MockBalancesBloc({
    required this.balanceRepository,
    required this.addresses,
    required this.cacheProvider,
  });
}

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockLogger extends Mock implements Logger {}

class MockEventsRepository extends Mock implements EventsRepository {}

class MockConfig extends Mock implements Config {
  @override
  bool get isMobile => false;
}

class MockGoRouter extends Mock implements GoRouter {}

class MockCacheProvider extends Mock implements CacheProvider {}

// Define fake classes
class FakeAddress extends Fake implements Address {
  @override
  final String address;

  FakeAddress({required this.address});
}

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
    required this.assetLongname,
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
  @override
  final String? utxo;
  @override
  final String? utxoAddress;

  FakeBalance({
    required this.asset,
    required this.quantity,
    required this.quantityNormalized,
    required this.address,
    required this.assetInfo,
    this.utxo,
    this.utxoAddress,
  });
}

class FakeUtxoBalance extends Fake implements Balance {
  @override
  final String? address;
  @override
  final int quantity;
  @override
  final String quantityNormalized;
  @override
  final AssetInfo assetInfo;

  @override
  final String utxo;

  @override
  final String utxoAddress;

  @override
  final String asset;

  FakeUtxoBalance({
    this.address,
    required this.quantity,
    required this.quantityNormalized,
    required this.assetInfo,
    required this.utxo,
    required this.utxoAddress,
    required this.asset,
  });
}

void main() {
  final getIt = GetIt.instance;
  late MockBalancesBloc mockBalancesBloc;
  late MockGoRouter mockGoRouter;

  // Test data
  final mockBalances = [
    MultiAddressBalance(
      asset: 'BTC',
      assetLongname: null,
      total: 100000000,
      totalNormalized: '1.00000000',
      entries: [
        MultiAddressBalanceEntry(
          address: 'address1',
          quantity: 100000000,
          quantityNormalized: '1.00000000',
          utxo: null,
          utxoAddress: null,
        ),
      ],
      assetInfo: const AssetInfo(
        assetLongname: null,
        description: 'BTC',
        divisible: true,
        owner: null,
      ),
    ),
    MultiAddressBalance(
      asset: 'XCP',
      assetLongname: null,
      total: 50000000,
      totalNormalized: '0.50000000',
      entries: [
        MultiAddressBalanceEntry(
          address: 'address1',
          quantity: 50000000,
          quantityNormalized: '0.50000000',
          utxo: null,
          utxoAddress: null,
        ),
      ],
      assetInfo: const AssetInfo(
        assetLongname: null,
        description: 'Counterparty',
        divisible: true,
        owner: null,
      ),
    ),
    MultiAddressBalance(
      asset: 'A12345',
      assetLongname: null,
      total: 1000000000,
      totalNormalized: '10.00000000',
      entries: [
        MultiAddressBalanceEntry(
          address: 'address1',
          quantity: 1000000000,
          quantityNormalized: '10.00000000',
          utxo: null,
          utxoAddress: null,
        ),
      ],
      assetInfo: const AssetInfo(
        assetLongname: '',
        description: '',
        divisible: true,
        owner: 'address2',
      ),
    ),
    MultiAddressBalance(
      asset: 'NAMEDASSET',
      assetLongname: null,
      total: 1000000,
      totalNormalized: '0.01000000',
      entries: [
        MultiAddressBalanceEntry(
          address: 'address1',
          quantity: 1000000,
          quantityNormalized: '0.01000000',
          utxo: null,
          utxoAddress: null,
        ),
      ],
      assetInfo: const AssetInfo(
        assetLongname: null,
        description: 'A NAMEDASSET',
        divisible: true,
        owner: 'address1',
      ),
    ),
    MultiAddressBalance(
      asset: 'A98765',
      assetLongname: 'PEPE.FROG',
      total: 50000000,
      totalNormalized: '0.50000000',
      entries: [
        MultiAddressBalanceEntry(
          address: 'address1',
          quantity: 50000000,
          quantityNormalized: '0.50000000',
          utxo: null,
          utxoAddress: null,
        ),
      ],
      assetInfo: const AssetInfo(
        assetLongname: 'PEPE.FROG',
        description: null,
        divisible: true,
        owner: 'address1',
      ),
    ),
  ];

  setUp(() {
    getIt.registerSingleton<Config>(MockConfig());
    mockBalancesBloc = MockBalancesBloc(
      balanceRepository: MockBalanceRepository(),
      addresses: ['address1'],
      cacheProvider: MockCacheProvider(),
    );
    mockGoRouter = MockGoRouter();

    // Mock successful state by default
    when(() => mockBalancesBloc.state).thenReturn(
      BalancesState.complete(Result.ok(mockBalances, [])),
    );
    when(() => mockBalancesBloc.stream).thenAnswer(
      (_) => Stream.value(BalancesState.complete(Result.ok(mockBalances, []))),
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
    getIt.reset();
  });

  Widget buildTestWidget({String searchQuery = ''}) {
    return MaterialApp(
      home: MockGoRouterProvider(
        goRouter: mockGoRouter,
        child: BlocProvider<BalancesBloc>.value(
          value: mockBalancesBloc,
          child: Scaffold(
            body: SingleChildScrollView(
              child: BalancesDisplay(searchQuery: searchQuery),
            ),
          ),
        ),
      ),
    );
  }

  group('BalancesDisplay Widget Tests', () {
    testWidgets('displays loading state correctly', (tester) async {
      when(() => mockBalancesBloc.state)
          .thenReturn(const BalancesState.loading());
      when(() => mockBalancesBloc.stream).thenAnswer(
        (_) => Stream.value(const BalancesState.loading()),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Ignore asset loading errors
      tester.takeException();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error state correctly', (tester) async {
      const errorMessage = 'Failed to load balances';
      when(() => mockBalancesBloc.state).thenReturn(
        const BalancesState.complete(Result.error(errorMessage)),
      );
      when(() => mockBalancesBloc.stream).thenAnswer(
        (_) => Stream.value(
            const BalancesState.complete(Result.error(errorMessage))),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Ignore asset loading errors
      tester.takeException();

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('displays empty state correctly', (tester) async {
      when(() => mockBalancesBloc.state).thenReturn(
        const BalancesState.complete(Result.ok([], [])),
      );
      when(() => mockBalancesBloc.stream).thenAnswer(
        (_) => Stream.value(const BalancesState.complete(Result.ok([], []))),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Ignore asset loading errors
      tester.takeException();

      expect(find.byType(NoData), findsOneWidget);
      expect(find.text('No Balances'), findsOneWidget);
    });

    testWidgets(
        'displays balances in correct order (BTC, XCP, then alphabetical)',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Ignore asset loading errors
            while (tester.takeException() != null) {}

      final listItems = find.byType(InkWell);
      expect(listItems, findsNWidgets(5));

      // Verify order: BTC, XCP, A12345, NAMEDASSET, PEPE.FROG
      final texts =
          tester.widgetList<SelectableText>(find.byType(SelectableText));
      final amounts = texts.map((widget) => widget.data).toList();
      expect(amounts, ['1.0', '0.5', '10.0', '0.01', '0.5']);

      final truncatedTexts = tester
          .widgetList<MiddleTruncatedText>(find.byType(MiddleTruncatedText));
      final names = truncatedTexts.map((widget) => widget.text).toList();
      expect(names, ['BTC', 'XCP', 'A12345', 'NAMEDASSET', 'PEPE.FROG']);
    });

    testWidgets(
        'displays balances in correct starred order (BTC, XCP, then alphabetical)',
        (tester) async {
      when(() => mockBalancesBloc.state).thenReturn(
        BalancesState.complete(
            Result.ok(mockBalances, ['XCP', 'BTC', 'NAMEDASSET'])),
      );
      when(() => mockBalancesBloc.stream).thenAnswer(
        (_) => Stream.value(BalancesState.complete(
            Result.ok(mockBalances, ['XCP', 'BTC', 'NAMEDASSET']))),
      );
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Ignore asset loading errors
      tester.takeException();

      final listItems = find.byType(InkWell);
      expect(listItems, findsNWidgets(5));

      // Verify order: BTC, XCP, NAMEDASSET, A12345, PEPE.FROG
      final texts =
          tester.widgetList<SelectableText>(find.byType(SelectableText));
      final amounts = texts.map((widget) => widget.data).toList();
      expect(amounts, ['1.0', '0.5', '0.01', '10.0', '0.5']);

      final truncatedTexts = tester
          .widgetList<MiddleTruncatedText>(find.byType(MiddleTruncatedText));
      final names = truncatedTexts.map((widget) => widget.text).toList();
      expect(names, ['BTC', 'XCP', 'NAMEDASSET', 'A12345', 'PEPE.FROG']);
    });

    testWidgets('search functionality filters balances correctly',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(searchQuery: 'named'));
      await tester.pumpAndSettle();

      // Ignore asset loading errors
      while (tester.takeException() != null) {}

      expect(find.text('NAMEDASSET'), findsOneWidget);
      expect(find.text('BTC'), findsNothing);
      expect(find.text('XCP'), findsNothing);
      expect(find.text('A12345'), findsNothing);
      expect(find.text('PEPE.FROG'), findsNothing);
    });
    testWidgets('search functionality filters substring correctly',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(searchQuery: 'rog'));
      await tester.pumpAndSettle();

      // Ignore asset loading errors
      while (tester.takeException() != null) {}

      expect(find.text('PEPE.FROG'), findsOneWidget);
      expect(find.text('BTC'), findsNothing);
      expect(find.text('XCP'), findsNothing);
      expect(find.text('A12345'), findsNothing);
      expect(find.text('NAMEDASSET'), findsNothing);
    });

    group('Filter Tests', () {
      testWidgets('named filter shows only named assets', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Ignore asset loading errors
        while (tester.takeException() != null) {}

        // Find and tap the Named filter
        await tester.tap(find.text('Named'));
        await tester.pumpAndSettle();

        expect(find.text('NAMEDASSET'), findsOneWidget);
        expect(find.text('A12345'), findsNothing);
        expect(find.text('PEPE.FROG'), findsOneWidget);
        expect(find.text('BTC'), findsNothing);
        expect(find.text('XCP'), findsOneWidget);
      });

      testWidgets('numeric filter shows only numeric assets', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Ignore asset loading errors
        while (tester.takeException() != null) {}

        await tester.tap(find.text('Numeric'));
        await tester.pumpAndSettle();

        expect(find.text('A12345'), findsOneWidget);
        expect(find.text('NAMEDASSET'), findsNothing);
        expect(find.text('PEPE.FROG'), findsNothing);
        expect(find.text('BTC'), findsNothing);
        expect(find.text('XCP'), findsNothing);
      });

      testWidgets('subassets filter shows only subassets', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Ignore asset loading errors
        while (tester.takeException() != null) {}

        await tester.tap(find.text('Subassets'));
        await tester.pumpAndSettle();

        expect(find.text('PEPE.FROG'), findsOneWidget);
        expect(find.text('A12345'), findsNothing);
        expect(find.text('NAMEDASSET'), findsNothing);
        expect(find.text('BTC'), findsNothing);
      });

      testWidgets('issuances filter shows only owned assets', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Ignore asset loading errors
        while (tester.takeException() != null) {}

        await tester.tap(find.text('Issuances'));
        await tester.pumpAndSettle();

        // Should show assets where the owner matches the address
        expect(find.text('NAMEDASSET'), findsOneWidget);
        expect(find.text('XCP'), findsNothing);
        expect(find.text('A12345'), findsNothing);
        expect(find.text('PEPE.FROG'), findsOneWidget);
        expect(find.text('BTC'), findsNothing);
      });
    });

    testWidgets('clicking asset navigates to asset details', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Ignore asset loading errors
      while (tester.takeException() != null) {}

      await tester.tap(find.text('BTC').first);
      await tester.pumpAndSettle();

      verify(() => mockGoRouter.go('/asset/BTC')).called(1);
    });

    testWidgets('long asset names are truncated correctly', (tester) async {
      final isMobile = tester.view.physicalSize.width < 600;
      final longNameBalance = MultiAddressBalance(
        asset: 'VERY.LONG.ASSET.NAME.THAT.NEEDS.TRUNCATION',
        assetLongname: 'Very Long Asset Name That Needs Truncation',
        total: 1000000,
        totalNormalized: '0.01000000',
        entries: [
          MultiAddressBalanceEntry(
            address: 'address1',
            quantity: 1000000,
            quantityNormalized: '0.01000000',
            utxo: null,
            utxoAddress: null,
          ),
        ],
        assetInfo: const AssetInfo(
          assetLongname: 'Very Long Asset Name That Needs Truncation',
          description: 'Long name asset',
          divisible: true,
          owner: 'address1',
        ),
      );

      when(() => mockBalancesBloc.state).thenReturn(
        BalancesState.complete(Result.ok([longNameBalance], [])),
      );
      when(() => mockBalancesBloc.stream).thenAnswer(
        (_) => Stream.value(
            BalancesState.complete(Result.ok([longNameBalance], []))),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Ignore asset loading errors
      while (tester.takeException() != null) {}

      final truncatedText = find.byType(MiddleTruncatedText);
      expect(truncatedText, findsOneWidget);

      // Verify the text is actually truncated
      final text = tester.widget<MiddleTruncatedText>(truncatedText);
      expect(text.text, 'Very Long Asset Name That Needs Truncation');
      expect(text.width, equals(150.0));
      expect(text.charsToShow, equals(isMobile ? 16 : 30));
    });
  });
}

// Helper widget to provide mock GoRouter
class MockGoRouterProvider extends StatelessWidget {
  final GoRouter goRouter;
  final Widget child;

  const MockGoRouterProvider({
    super.key,
    required this.goRouter,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InheritedGoRouter(
      goRouter: goRouter,
      child: child,
    );
  }
}
