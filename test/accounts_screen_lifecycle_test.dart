import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/entities/account_v2.dart';
import 'package:horizon/domain/entities/address_index_set.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/wallet_config.dart';
import 'package:horizon/domain/repositories/address_v2_repository.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/usecases/esplora/get_address_info.dart';
import 'package:horizon/presentation/screens/accounts/accounts_screen.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

class MockSession extends MockCubit<SessionState>
    implements SessionStateCubit {}

class MockAddresses extends Mock implements AddressV2Repository {}

class MockWalletConfigs extends Mock implements WalletConfigRepository {}

class MockAddressInfo extends Mock
    implements GetAddressInfoMultiEsploraUseCase {}

class FakeConfig extends Fake implements WalletConfig {}

void main() {
  late MockSession session;
  late MockAddresses addresses;
  late GoRouter router;
  late VoidCallback completeSwitch;
  final account = Bip32(walletConfigID: 'test-wallet', index: 0);

  setUp(() {
    session = MockSession();
    addresses = MockAddresses();
    // Leave balance loading pending: this test exercises navigation, not APIs.
    when(() => addresses.getByAccount(account))
        .thenAnswer((_) => Completer<AddressIndexSet>().future);
    whenListen(session, const Stream<SessionState>.empty(),
        initialState: SessionState.success(SessionStateSuccess(
          httpConfig: Mainnet(),
          currentAccount: account,
          decryptionKey: 'test',
          accounts: [account],
          addressIndexSet: AddressIndexSet({}),
          walletConfig: FakeConfig(),
        )));
    when(() => session.onAccountChanged(account, any())).thenAnswer((call) {
      completeSwitch = call.positionalArguments[1] as VoidCallback;
    });
    GetIt.I.registerSingleton<WalletConfigRepository>(MockWalletConfigs());
    router = GoRouter(initialLocation: '/accounts', routes: [
      GoRoute(
          path: '/', builder: (_, __) => const Scaffold(body: Text('Home'))),
      GoRoute(
          path: '/elsewhere',
          builder: (_, __) => const Scaffold(body: Text('Elsewhere'))),
      GoRoute(
          path: '/accounts',
          builder: (_, __) => Scaffold(
                  body: AccountsScreen(
                addressV2Repository: addresses,
                getAddressInfoMultiUseCase: MockAddressInfo(),
              ))),
    ]);
  });

  tearDown(() async {
    router.dispose();
    await session.close();
    await GetIt.I.reset();
  });

  Future<void> beginSwitch(WidgetTester tester) async {
    await tester.pumpWidget(BlocProvider<SessionStateCubit>.value(
      value: session,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('account 1'));
  }

  testWidgets('late account switch does not navigate from a disposed row',
      (tester) async {
    await beginSwitch(tester);
    router.go('/elsewhere');
    await tester.pumpAndSettle();
    expect(completeSwitch, returnsNormally);
    await tester.pumpAndSettle();
    expect(find.text('Elsewhere'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('account switch still returns home when the row is mounted',
      (tester) async {
    await beginSwitch(tester);
    completeSwitch();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
