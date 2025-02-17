import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fairminter.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/presentation/common/no_data.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';
import 'package:horizon/presentation/screens/dashboard/view/balances_display.dart';
import 'package:mocktail/mocktail.dart';

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

class FakeFairminter extends Fake implements Fairminter {
  @override
  final String asset;

  FakeFairminter({required this.asset});
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
  late BalancesBloc mockBalancesBloc;

  // Define variables to be used in setUp() and tests
  late Map<String, List<Balance>> aggregatedBalances;

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
        utxo: null,
        utxoAddress: '',
        assetInfo: FakeAssetInfo(
          assetLongname: '',
          issuer: '',
          divisible: false,
        ),
      ),
    );

    // Create test balances
    final balance1 = FakeBalance(
      asset: 'PEPENARDO',
      quantity: 100000000,
      quantityNormalized: '1.00000000',
      address: '1TestAddress',
      assetInfo: FakeAssetInfo(
        assetLongname: 'PEPENARDO.ASDF',
        issuer: '1IssuerAddress',
        divisible: true,
      ),
    );

    final balance2 = FakeBalance(
      asset: 'MAXVOLUME',
      quantity: 200000000,
      quantityNormalized: '2.00000000',
      address: '1TestAddress',
      assetInfo: FakeAssetInfo(
        assetLongname: '',
        issuer: '1IssuerAddress',
        divisible: true,
      ),
    );

    // Set up aggregated balances
    aggregatedBalances = {
      'PEPENARDO.ASDF': [balance1],
      'MAXVOLUME': [balance2],
    };

    // Mock the state
    when(() => mockBalancesBloc.state).thenReturn(
      BalancesState.complete(Result.ok(aggregatedBalances)),
    );

    // Mock the stream
    when(() => mockBalancesBloc.stream).thenAnswer(
      (_) => Stream<BalancesState>.value(
        BalancesState.complete(Result.ok(aggregatedBalances)),
      ),
    );
  });

  tearDown(() {
    getIt.reset();
  });

  group('BalancesDisplay', () {
    testWidgets('displays balances in table format',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<BalancesBloc>.value(
            value: mockBalancesBloc,
            child: const Scaffold(
              body: CustomScrollView(
                slivers: [
                  BalancesDisplay(isDarkTheme: false),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the table displays both assets
      expect(find.text('PEPENARDO.ASDF'), findsOneWidget);
      expect(find.text('MAXVOLUME'), findsOneWidget);
      expect(find.text('1.00000000'), findsOneWidget);
      expect(find.text('2.00000000'), findsOneWidget);
    });

    testWidgets('displays error message when error occurs',
        (WidgetTester tester) async {
      // Mock error state

      when(() => mockBalancesBloc.stream).thenAnswer(
        (_) => Stream<BalancesState>.value(
          const BalancesState.complete(Result.error('An error occurred')),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<BalancesBloc>.value(
            value: mockBalancesBloc,
            child: const Scaffold(
              body: CustomScrollView(
                slivers: [
                  BalancesDisplay(isDarkTheme: false),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The error is displayed in a SizedBox with a height of 200
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(Center),
          matching: find.text('An error occurred'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays loading indicator when loading',
        (WidgetTester tester) async {
      // Mock loading state
      when(() => mockBalancesBloc.state).thenReturn(
        const BalancesState.loading(),
      );

      // Add stream mock for loading state
      when(() => mockBalancesBloc.stream).thenAnswer(
        (_) => Stream<BalancesState>.value(
          const BalancesState.loading(),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<BalancesBloc>.value(
            value: mockBalancesBloc,
            child: const Scaffold(
              body: CustomScrollView(
                slivers: [
                  BalancesDisplay(isDarkTheme: false),
                ],
              ),
            ),
          ),
        ),
      );

      // Use pump() instead of pumpAndSettle()
      await tester.pump();

      // Look for loading indicator within SizedBox and Center
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(Center),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays NoData when balances are empty',
        (WidgetTester tester) async {
      // Mock empty balances
      when(() => mockBalancesBloc.state).thenReturn(
        const BalancesState.complete(Result.ok({})),
      );

      // Add stream mock for empty balances
      when(() => mockBalancesBloc.stream).thenAnswer(
        (_) => Stream<BalancesState>.value(
          const BalancesState.complete(Result.ok({})),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<BalancesBloc>.value(
            value: mockBalancesBloc,
            child: const Scaffold(
              body: CustomScrollView(
                slivers: [
                  BalancesDisplay(isDarkTheme: false),
                ],
              ),
            ),
          ),
        ),
      );

      // Use pump() instead of pumpAndSettle()
      await tester.pump();

      // Look for NoData widget and text
      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.byType(NoData),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NoData),
          matching: find.text('No Balances'),
        ),
        findsOneWidget,
      );
    });
  });
}
