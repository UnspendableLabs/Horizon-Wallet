import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/address_index_set.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/wallet_config.dart';
import 'package:horizon/domain/services/mempool_price_service.dart';
import 'package:horizon/presentation/common/sats_to_usd_display.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:rxdart/rxdart.dart';

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionStateCubit {}

class FakeWalletConfig extends Fake implements WalletConfig {}

class TestPriceService implements MempoolPriceService {
  final prices = BehaviorSubject<int>.seeded(50000);
  final starts = <HttpConfig>[];
  int stops = 0;
  int subscriptions = 0;

  @override
  int? get lastPrice => prices.valueOrNull;

  @override
  Stream<int> get priceStream => prices.stream
      .doOnListen(() => subscriptions++)
      .doOnCancel(() => subscriptions--);

  @override
  void startListening({required HttpConfig httpConfig}) =>
      starts.add(httpConfig);

  @override
  void stopListening() => stops++;

  @override
  void dispose() => unawaited(prices.close());
}

void main() {
  late TestPriceService prices;
  late MockSessionCubit session;
  late StreamController<SessionState> sessions;
  final walletConfig = FakeWalletConfig();

  SessionState success(HttpConfig config, {String key = 'test-key'}) =>
      SessionState.success(SessionStateSuccess(
        httpConfig: config,
        currentAccount: null,
        decryptionKey: key,
        accounts: const [],
        addressIndexSet: AddressIndexSet({}),
        walletConfig: walletConfig,
      ));

  Widget app({bool secondDisplay = false}) =>
      BlocProvider<SessionStateCubit>.value(
        value: session,
        child: MaterialApp(
          home: Column(children: [
            SatsToUsdDisplay(
                key: const ValueKey('first'), sats: BigInt.from(100000)),
            if (secondDisplay)
              SatsToUsdDisplay(
                  key: const ValueKey('second'), sats: BigInt.from(200000)),
          ]),
        ),
      );

  setUp(() {
    prices = TestPriceService();
    GetIt.I.registerSingleton<MempoolPriceService>(prices);
    session = MockSessionCubit();
    sessions = StreamController<SessionState>();
    whenListen(session, sessions.stream, initialState: success(Mainnet()));
  });

  tearDown(() async {
    await sessions.close();
    await prices.prices.close();
    await GetIt.I.reset();
  });

  testWidgets('renders the cached price and subsequent updates',
      (tester) async {
    await tester.pumpWidget(app());
    expect(find.text(r'$50.00'), findsOneWidget);
    prices.prices.add(60000);
    await tester.pumpAndSettle();
    expect(find.text(r'$60.00'), findsOneWidget);
    expect(prices.starts, hasLength(1));
    expect(prices.subscriptions, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('session updates keep one subscription and balanced ownership',
      (tester) async {
    await tester.pumpWidget(app());
    for (var i = 0; i < 3; i++) {
      // A fresh config object with the same endpoint is not a new price source.
      sessions.add(success(Mainnet(), key: 'test-key-$i'));
      await tester.pump();
    }
    expect(prices.subscriptions, 1);
    expect(prices.starts, hasLength(1));
    expect(prices.stops, 0);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(prices.subscriptions, 0);
    expect(prices.stops, 1);
  });

  testWidgets('late prices after session updates and removal cannot setState',
      (tester) async {
    await tester.pumpWidget(app());
    sessions.add(success(Mainnet(), key: 'another-test-key'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    prices.prices.add(70000);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(prices.subscriptions, 0);
    expect(prices.starts.length, prices.stops);
  });

  testWidgets(
      'network changes replace service ownership without leaking listeners',
      (tester) async {
    await tester.pumpWidget(app());
    final signet = Signet();
    sessions.add(success(signet));
    await tester.pump();
    expect(prices.starts, hasLength(2));
    expect(prices.starts.last, same(signet));
    expect(prices.stops, 1);
    expect(prices.subscriptions, 1);
    prices.prices.add(60000);
    await tester.pumpAndSettle();
    expect(find.text(r'$60.00'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(prices.stops, 2);
    expect(prices.subscriptions, 0);
  });

  testWidgets('removing one display leaves the other subscribed',
      (tester) async {
    await tester.pumpWidget(app(secondDisplay: true));
    expect(prices.subscriptions, 2);
    await tester.pumpWidget(app());
    expect(prices.starts.length - prices.stops, 1);
    expect(prices.subscriptions, 1);
    prices.prices.add(60000);
    await tester.pumpAndSettle();
    expect(find.text(r'$60.00'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(prices.starts.length, prices.stops);
    expect(prices.subscriptions, 0);
  });
}
