import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/presentation/common/no_data.dart';
import 'package:horizon/presentation/screens/dashboard/view/balances_display.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

class MockBalancesBloc extends Mock implements BalancesBloc {}

class MockLogger extends Mock implements Logger {}

class MockConfig extends Mock implements Config {}

class MockEventsRepository extends Mock implements EventsRepository {}

class MockTransactionLocalRepository extends Mock
    implements TransactionLocalRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

class MockBitcoinRepository extends Mock implements BitcoinRepository {}

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

  FakeBalance({
    required this.asset,
    required this.quantity,
    required this.quantityNormalized,
    required this.address,
    required this.assetInfo,
  });
}

void main() {
  final getIt = GetIt.instance;
  late BalancesBloc mockBalancesBloc;

  // Define variables to be used in setUp() and tests
  late List<Balance> balances;
  late Map<String, Balance> aggregatedBalances;
  late List<Asset> ownedAssets;

  setUp(() {
    // Register mock Config
    getIt.registerSingleton<Config>(MockConfig());

    mockBalancesBloc = MockBalancesBloc();

    // Register fallback values for mocktail
    registerFallbackValue(FakeAddress(address: ''));
    registerFallbackValue(
      FakeAsset(
        asset: '',
        assetLongname: '',
        owner: '',
        issuer: '',
        divisible: false,
        locked: false,
      ),
    );
    registerFallbackValue(
      FakeBalance(
        asset: '',
        quantity: 0,
        quantityNormalized: '0',
        address: '',
        assetInfo: FakeAssetInfo(
          assetLongname: '',
          issuer: '',
          divisible: false,
        ),
      ),
    );

    // Create fake assets and balances
    final asset1 = FakeAsset(
      asset: 'PEPENARDO',
      assetLongname: 'PEPENARDO.PEPE',
      owner: '1TestAddress',
      issuer: '1IssuerAddress',
      divisible: true,
      locked: false,
    );

    final asset2 = FakeAsset(
      asset: 'MAXVOLUME',
      assetLongname: 'MAXVOLUME.PEPE',
      owner: '1OtherAddress',
      issuer: '1IssuerAddress',
      divisible: true,
      locked: false,
    );

    final assetInfo1 = FakeAssetInfo(
      assetLongname: 'PEPENARDO.PEPE',
      issuer: '1IssuerAddress',
      divisible: true,
    );

    final assetInfo2 = FakeAssetInfo(
      assetLongname: 'MAXVOLUME.PEPE',
      issuer: '1IssuerAddress',
      divisible: true,
    );

    final balance1 = FakeBalance(
      asset: 'PEPENARDO',
      quantity: 100000000,
      quantityNormalized: '1.00000000',
      address: '1TestAddress',
      assetInfo: assetInfo1,
    );

    final balance2 = FakeBalance(
      asset: 'MAXVOLUME',
      quantity: 200000000,
      quantityNormalized: '2.00000000',
      address: '1TestAddress',
      assetInfo: assetInfo2,
    );

    balances = [balance1, balance2];
    aggregatedBalances = {
      'PEPENARDO': balance1,
      'MAXVOLUME': balance2,
    };
    ownedAssets = [asset1];

    // Mock the state
    when(() => mockBalancesBloc.state).thenReturn(
      BalancesState.complete(
        Result.ok(balances, aggregatedBalances, ownedAssets),
      ),
    );

    // Mock the stream
    when(() => mockBalancesBloc.stream).thenAnswer(
      (_) => Stream<BalancesState>.value(
        BalancesState.complete(
          Result.ok(balances, aggregatedBalances, ownedAssets),
        ),
      ),
    );
  });

  tearDown(() {
    getIt.reset();
  });

  group('BalancesDisplay', () {
    testWidgets('should filter balances based on search input',
        (WidgetTester tester) async {
      final address = FakeAddress(address: '1TestAddress');

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<BalancesBloc>.value(
            value: mockBalancesBloc,
            child: Scaffold(
              body: CustomScrollView(
                slivers: [
                  BalancesDisplay(
                    isDarkTheme: false,
                    currentAddress: address.address,
                    initialItemCount: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Wait for the widget tree to build
      await tester.pumpAndSettle();

      // Verify that both assets are displayed
      expect(find.byKey(const Key('assetName_PEPENARDO')), findsOneWidget);
      expect(find.byKey(const Key('assetName_MAXVOLUME')), findsOneWidget);

      // Enter search term
      await tester.enterText(find.byKey(const Key('search_input')), 'pepe');
      await tester.pumpAndSettle();

      // Verify that only 'PEPENARDO' is displayed
      expect(find.byKey(const Key('assetName_PEPENARDO')), findsOneWidget);
      expect(find.byKey(const Key('assetName_MAXVOLUME')), findsNothing);
    });

    testWidgets(
        'should filter and display only owned assets when "Owned" is selected',
        (WidgetTester tester) async {
      final address = FakeAddress(address: '1TestAddress');

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<BalancesBloc>.value(
            value: mockBalancesBloc,
            child: Scaffold(
              body: CustomScrollView(
                slivers: [
                  BalancesDisplay(
                    isDarkTheme: false,
                    currentAddress: address.address,
                    initialItemCount: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Wait for the widget tree to build
      await tester.pumpAndSettle();

      // Verify that both assets are displayed
      expect(find.byKey(const Key('assetName_PEPENARDO')), findsOneWidget);
      expect(find.byKey(const Key('assetName_MAXVOLUME')), findsOneWidget);

      // Tap the "Owned" checkbox
      await tester.tap(find.byKey(const Key('owned_checkbox')));
      await tester.pumpAndSettle();

      // Verify that only the owned asset is displayed
      expect(find.byKey(const Key('assetName_PEPENARDO')), findsOneWidget);
      expect(find.byKey(const Key('assetName_MAXVOLUME')), findsNothing);
    });

    testWidgets(
        'should filter and display assets based on search input and Owned filter combined',
        (WidgetTester tester) async {
      final address = FakeAddress(address: '1TestAddress');

      // Create multiple assets with varying ownership and issuer details
      final assets = [
        // Asset owned and issued by the current address
        FakeAsset(
          asset: 'ASSET1',
          assetLongname: 'ASSET1.LONG',
          owner: '1TestAddress',
          issuer: '1TestAddress',
          divisible: true,
          locked: false,
        ),
        // Asset owned by current address but issued by someone else
        FakeAsset(
          asset: 'ASSET2',
          assetLongname: 'ASSET2.LONG',
          owner: '1TestAddress',
          issuer: '1IssuerAddress',
          divisible: true,
          locked: false,
        ),
        // Asset not owned by current address
        FakeAsset(
          asset: 'ASSET3',
          assetLongname: 'ASSET3.LONG',
          owner: '1OtherOwner',
          issuer: '1TestAddress',
          divisible: true,
          locked: false,
        ),
        // Asset not owned by current address
        FakeAsset(
          asset: 'ASSET4',
          assetLongname: 'ASSET4.LONG',
          owner: '1OtherOwner',
          issuer: '1OtherIssuer',
          divisible: true,
          locked: false,
        ),
        // Asset not owned by current address but matches search term
        FakeAsset(
          asset: 'FILTERME',
          assetLongname: 'FILTERME.LONG',
          owner: '1OtherOwner',
          issuer: '1OtherIssuer',
          divisible: true,
          locked: false,
        ),
      ];

      final balances = [
        FakeBalance(
          asset: 'ASSET1',
          quantity: 100000000,
          quantityNormalized: '1.00000000',
          address: '1TestAddress',
          assetInfo: FakeAssetInfo(
            assetLongname: 'ASSET1.LONG',
            issuer: '1TestAddress',
            divisible: true,
          ),
        ),
        FakeBalance(
          asset: 'ASSET2',
          quantity: 200000000,
          quantityNormalized: '2.00000000',
          address: '1TestAddress',
          assetInfo: FakeAssetInfo(
            assetLongname: 'ASSET2.LONG',
            issuer: '1IssuerAddress',
            divisible: true,
          ),
        ),
        FakeBalance(
          asset: 'ASSET3',
          quantity: 300000000,
          quantityNormalized: '3.00000000',
          address: '1OtherAddress',
          assetInfo: FakeAssetInfo(
            assetLongname: 'ASSET3.LONG',
            issuer: '1TestAddress',
            divisible: true,
          ),
        ),
        FakeBalance(
          asset: 'ASSET4',
          quantity: 400000000,
          quantityNormalized: '4.00000000',
          address: '1OtherAddress',
          assetInfo: FakeAssetInfo(
            assetLongname: 'ASSET4.LONG',
            issuer: '1OtherIssuer',
            divisible: true,
          ),
        ),
        FakeBalance(
          asset: 'FILTERME',
          quantity: 500000000,
          quantityNormalized: '5.00000000',
          address: '1OtherAddress',
          assetInfo: FakeAssetInfo(
            assetLongname: 'FILTERME.LONG',
            issuer: '1OtherIssuer',
            divisible: true,
          ),
        ),
      ];

      final aggregatedBalances = {
        for (var balance in balances) balance.asset: balance,
      };

      final ownedAssets = [
        assets[0], // ASSET1: Owned by current address
        assets[1], // ASSET2: Owned by current address
      ];

      // Mock the BalancesBloc state and stream with the new data
      when(() => mockBalancesBloc.state).thenReturn(
        BalancesState.complete(
          Result.ok(balances, aggregatedBalances, ownedAssets),
        ),
      );

      when(() => mockBalancesBloc.stream).thenAnswer(
        (_) => Stream<BalancesState>.value(
          BalancesState.complete(
            Result.ok(balances, aggregatedBalances, ownedAssets),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<BalancesBloc>.value(
            value: mockBalancesBloc,
            child: Scaffold(
              body: CustomScrollView(
                slivers: [
                  BalancesDisplay(
                    isDarkTheme: false,
                    currentAddress: address.address,
                    initialItemCount: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Wait for the widget tree to build
      await tester.pumpAndSettle();

      // Verify that all assets are displayed initially
      expect(find.byKey(const Key('assetName_ASSET1')), findsOneWidget);
      expect(find.byKey(const Key('assetName_ASSET2')), findsOneWidget);
      expect(find.byKey(const Key('assetName_ASSET3')), findsOneWidget);
      expect(find.byKey(const Key('assetName_ASSET4')), findsOneWidget);
      expect(find.byKey(const Key('assetName_FILTERME')), findsOneWidget);

      // Enter search term 'ASSET'
      await tester.enterText(find.byKey(const Key('search_input')), 'ASSET');
      await tester.pumpAndSettle();

      // Verify that assets with 'ASSET' in their name are displayed
      expect(find.byKey(const Key('assetName_ASSET1')), findsOneWidget);
      expect(find.byKey(const Key('assetName_ASSET2')), findsOneWidget);
      expect(find.byKey(const Key('assetName_ASSET3')), findsOneWidget);
      expect(find.byKey(const Key('assetName_ASSET4')), findsOneWidget);
      expect(find.byKey(const Key('assetName_FILTERME')), findsNothing);

      // Tap the "Owned" checkbox
      await tester.tap(find.byKey(const Key('owned_checkbox')));
      await tester.pumpAndSettle();

      // Verify that only owned assets with 'ASSET' in their name are displayed
      expect(find.byKey(const Key('assetName_ASSET1')), findsOneWidget);
      expect(find.byKey(const Key('assetName_ASSET2')), findsOneWidget);
      expect(find.byKey(const Key('assetName_ASSET3')), findsNothing);
      expect(find.byKey(const Key('assetName_ASSET4')), findsNothing);
      expect(find.byKey(const Key('assetName_FILTERME')), findsNothing);

      // Change the search term to 'FILTERME'
      await tester.enterText(find.byKey(const Key('search_input')), 'FILTERME');
      await tester.pumpAndSettle();

      // Verify that no assets are displayed since FILTERME is not owned by current address
      expect(find.byKey(const Key('assetName_ASSET1')), findsNothing);
      expect(find.byKey(const Key('assetName_ASSET2')), findsNothing);
      expect(find.byKey(const Key('assetName_ASSET3')), findsNothing);
      expect(find.byKey(const Key('assetName_ASSET4')), findsNothing);
      expect(find.byKey(const Key('assetName_FILTERME')), findsNothing);

      // Uncheck "Owned" filter
      await tester.tap(find.byKey(const Key('owned_checkbox')));
      await tester.pumpAndSettle();

      // Verify that assets owned by current address with 'FILTERME' in their name are displayed
      expect(find.byKey(const Key('assetName_ASSET1')), findsNothing);
      expect(find.byKey(const Key('assetName_ASSET2')), findsNothing);
      expect(find.byKey(const Key('assetName_ASSET3')), findsNothing);
      expect(find.byKey(const Key('assetName_ASSET4')), findsNothing);

      // Verify that 'FILTERME' asset is displayed now that owned filter is removed
      expect(find.byKey(const Key('assetName_FILTERME')), findsOneWidget);
    });

    testWidgets(
        'should display error message when an error occurs in BalancesBloc',
        (WidgetTester tester) async {
      final address = FakeAddress(address: '1TestAddress');

      // Mock the BalancesBloc to return an error state
      when(() => mockBalancesBloc.state).thenReturn(
        const BalancesState.complete(
          Result.error('An error occurred'),
        ),
      );

      when(() => mockBalancesBloc.stream).thenAnswer(
        (_) => Stream<BalancesState>.value(
          const BalancesState.complete(
            Result.error('An error occurred'),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<BalancesBloc>.value(
            value: mockBalancesBloc,
            child: Scaffold(
              body: CustomScrollView(
                slivers: [
                  BalancesDisplay(
                    isDarkTheme: false,
                    currentAddress: address.address,
                    initialItemCount: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Wait for the widget tree to build
      await tester.pumpAndSettle();

      // Verify that the error message is displayed
      expect(find.text('An error occurred'), findsOneWidget);
    });

    testWidgets('should display empty state message when there are no balances',
        (WidgetTester tester) async {
      final address = FakeAddress(address: '1TestAddress');

      // Mock the BalancesBloc to return an empty list of balances
      when(() => mockBalancesBloc.state).thenReturn(
        const BalancesState.complete(
          Result.ok([], {}, []),
        ),
      );

      when(() => mockBalancesBloc.stream).thenAnswer(
        (_) => Stream<BalancesState>.value(
          const BalancesState.complete(
            Result.ok([], {}, []),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<BalancesBloc>.value(
            value: mockBalancesBloc,
            child: Scaffold(
              body: CustomScrollView(
                slivers: [
                  BalancesDisplay(
                    isDarkTheme: false,
                    currentAddress: address.address,
                    initialItemCount: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Wait for the widget tree to build
      await tester.pumpAndSettle();

      // Verify that the empty state message is displayed
      expect(find.byType(NoData), findsOneWidget);
    });

    testWidgets('should open ComposeSend dialog when send icon is tapped',
        (WidgetTester tester) async {
      final address = FakeAddress(address: '1TestAddress');

      // Setup a balance with quantity > 0
      final asset = FakeAsset(
        asset: 'TESTASSET',
        assetLongname: 'TESTASSET.LONG',
        owner: '1OtherOwner',
        issuer: '1OtherIssuer',
        divisible: true,
        locked: false,
      );

      final balance = FakeBalance(
        asset: 'TESTASSET',
        quantity: 100000000,
        quantityNormalized: '1.00000000',
        address: '1TestAddress',
        assetInfo: FakeAssetInfo(
          assetLongname: 'TESTASSET.LONG',
          issuer: '1OtherIssuer',
          divisible: true,
        ),
      );

      final balances = [balance];
      final aggregatedBalances = {balance.asset: balance};
      final List<Asset> ownedAssets = [];

      // Mock the BalancesBloc state and stream with the new data
      when(() => mockBalancesBloc.state).thenReturn(
        BalancesState.complete(
          Result.ok(balances, aggregatedBalances, ownedAssets),
        ),
      );

      when(() => mockBalancesBloc.stream).thenAnswer(
        (_) => Stream<BalancesState>.value(
          BalancesState.complete(
            Result.ok(balances, aggregatedBalances, ownedAssets),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<BalancesBloc>.value(
            value: mockBalancesBloc,
            child: Scaffold(
              body: CustomScrollView(
                slivers: [
                  BalancesDisplay(
                    isDarkTheme: false,
                    currentAddress: address.address,
                    initialItemCount: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Wait for the widget tree to build
      await tester.pumpAndSettle();

      // Tap the send icon button for 'TESTASSET'
      final sendButton = find.byIcon(Icons.send).first;

      expect(sendButton, findsOneWidget);
    });
  });
}
