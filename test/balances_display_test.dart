import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/presentation/screens/dashboard/view/balances_display.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/config_repository.dart'; // Adjust the import path

class MockBalancesBloc extends Mock implements BalancesBloc {}
class MockConfig extends Mock implements Config {}

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
    testWidgets('should filter balances based on search input', (WidgetTester tester) async {
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
                    addresses: [address],
                    accountUuid: 'test-account',
                    currentAddress: address,
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
      expect(find.byKey(Key('assetName_PEPENARDO')), findsOneWidget);
      expect(find.byKey(Key('assetName_MAXVOLUME')), findsOneWidget);

      // Enter search term
      await tester.enterText(find.byKey(Key('search_input')), 'pepe');
      await tester.pumpAndSettle();

      // Verify that only 'Asset One' is displayed
      expect(find.byKey(Key('assetName_PEPENARDO')), findsOneWidget);
      expect(find.byKey(Key('assetName_MAXVOLUME')), findsNothing);
    });
  });
}
