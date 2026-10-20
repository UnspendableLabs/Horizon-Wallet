import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/reset/reset_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/reset/reset_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/reset/view/reset_dialog.dart';
import 'package:horizon/presentation/screens/dashboard/view/dashboard_contents.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:mocktail/mocktail.dart';

class MockSession extends MockCubit<SessionState>
    implements SessionStateCubit {}

class MockWallets extends Mock implements WalletRepository {}

class MockAccounts extends Mock implements AccountRepository {}

class MockAddresses extends Mock implements AddressRepository {}

class MockImports extends Mock implements ImportedAddressRepository {}

class MockKeys extends Mock implements InMemoryKeyRepository {}

class MockStorage extends Mock implements SecureKVService {}

class MockCache extends Mock implements CacheProvider {}

class MockAnalytics extends Mock implements AnalyticsService {}

class MockConfig extends Mock implements Config {}

void main() {
  late MockSession session;
  late MockWallets wallets;
  late MockAccounts accounts;
  late MockAddresses addresses;
  late MockImports imports;
  late MockKeys keys;
  late MockStorage storage;
  late MockCache cache;
  late MockAnalytics analytics;
  late ValueNotifier<bool> showHeader;
  final navigator = GlobalKey<NavigatorState>();

  setUpAll(() async {
    final fonts = FontLoader('Montserrat')
      ..addFont(rootBundle.load('fonts/Montserrat-Regular.ttf'));
    await fonts.load();
  });

  setUp(() {
    session = MockSession();
    when(() => session.state).thenReturn(const SessionState.initial());
    wallets = MockWallets();
    accounts = MockAccounts();
    addresses = MockAddresses();
    imports = MockImports();
    keys = MockKeys();
    storage = MockStorage();
    cache = MockCache();
    analytics = MockAnalytics();
    final config = MockConfig();
    when(() => config.horizonExplorerBase)
        .thenReturn('https://example.invalid');
    when(() => wallets.deleteAllWallets()).thenAnswer((_) async {});
    when(() => accounts.deleteAllAccounts()).thenAnswer((_) async {});
    when(() => addresses.deleteAllAddresses()).thenAnswer((_) async {});
    when(() => imports.deleteAllImportedAddresses()).thenAnswer((_) async {});
    when(() => keys.delete()).thenAnswer((_) async {});
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((_) async {});
    when(() => cache.removeAll()).thenAnswer((_) async {});
    GetIt.I.registerSingleton<Config>(config);
    GetIt.I.registerSingleton<WalletRepository>(wallets);
    GetIt.I.registerSingleton<AccountRepository>(accounts);
    GetIt.I.registerSingleton<AddressRepository>(addresses);
    GetIt.I.registerSingleton<ImportedAddressRepository>(imports);
    GetIt.I.registerSingleton<InMemoryKeyRepository>(keys);
    GetIt.I.registerSingleton<SecureKVService>(storage);
    GetIt.I.registerSingleton<CacheProvider>(cache);
    GetIt.I.registerSingleton<AnalyticsService>(analytics);
    showHeader = ValueNotifier(true);
  });

  tearDown(() async {
    showHeader.dispose();
    await session.close();
    await GetIt.I.reset();
  });

  Future<ResetBloc> open(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(BlocProvider<SessionStateCubit>.value(
      value: session,
      child: MaterialApp(
        navigatorKey: navigator,
        theme: ThemeData(fontFamily: 'Montserrat'),
        home: Scaffold(
          body: ValueListenableBuilder<bool>(
            valueListenable: showHeader,
            builder: (_, visible, __) => visible
                ? const HorizonAppBarContent()
                : const SizedBox.shrink(),
          ),
        ),
      ),
    ));
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset wallet'));
    await tester.pumpAndSettle();
    return tester.element(find.byType(ResetDialog)).read<ResetBloc>();
  }

  Future<void> confirm(WidgetTester tester) async {
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.ensureVisible(find.text('CONTINUE'));
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('resetConfirmationTextField')), 'RESET WALLET');
    await tester.ensureVisible(find.byKey(const Key('continueButton')));
    await tester.tap(find.byKey(const Key('continueButton')));
    await tester.pumpAndSettle();
  }

  for (final width in [390.0, 1000.0]) {
    testWidgets('reset survives header removal at width $width',
        (tester) async {
      final bloc = await open(tester, Size(width, 900));
      // The modal route stays open when its launching header is removed.
      showHeader.value = false;
      await tester.pumpAndSettle();
      expect(find.byType(ResetDialog), findsOneWidget);
      await confirm(tester);
      expect(tester.takeException(), isNull);
      verify(() => wallets.deleteAllWallets()).called(1);
      verify(() => accounts.deleteAllAccounts()).called(1);
      verify(() => addresses.deleteAllAddresses()).called(1);
      verify(() => imports.deleteAllImportedAddresses()).called(1);
      verify(() => session.onOnboarding()).called(1);
      expect(find.byType(ResetDialog), findsNothing);
      expect(bloc.isClosed, isTrue);
    });
  }

  testWidgets('acknowledgement and exact reset text remain required',
      (tester) async {
    await open(tester, const Size(1000, 900));
    await tester.tap(find.text('CONTINUE'));
    await tester.pump();
    expect(find.byKey(const Key('resetConfirmationTextField')), findsNothing);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('resetConfirmationTextField')), 'reset wallet');
    await tester.tap(find.byKey(const Key('continueButton')));
    await tester.pump();
    verifyNever(() => wallets.deleteAllWallets());
    verifyNever(() => session.onOnboarding());
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
  });

  testWidgets('dismissal closes only the dialog controller and deletes nothing',
      (tester) async {
    final first = await open(tester, const Size(1000, 900));
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(first.isClosed, isTrue);
    verifyNever(() => wallets.deleteAllWallets());
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset wallet'));
    await tester.pumpAndSettle();
    final second = tester.element(find.byType(ResetDialog)).read<ResetBloc>();
    expect(second, isNot(same(first)));
    expect(second.isClosed, isFalse);
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(second.isClosed, isTrue);
  });

  testWidgets('repeated confirmation runs one awaited reset', (tester) async {
    final deletion = Completer<void>();
    when(() => wallets.deleteAllWallets()).thenAnswer((_) => deletion.future);
    final bloc = await open(tester, const Size(1000, 900));
    await confirm(tester);
    expect(find.text('RESETTING…'), findsOneWidget);
    // Even an already-queued confirmation must not overlap the first reset.
    bloc.add(ResetEvent());
    await tester.pump();
    verify(() => wallets.deleteAllWallets()).called(1);
    verifyNever(() => session.onOnboarding());
    deletion.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    verify(() => accounts.deleteAllAccounts()).called(1);
    verify(() => session.onOnboarding()).called(1);
  });

  for (final width in [390.0, 1000.0]) {
    testWidgets('reset cannot be dismissed during deletion at width $width',
        (tester) async {
      final deletion = Completer<void>();
      when(() => wallets.deleteAllWallets()).thenAnswer((_) => deletion.future);
      final bloc = await open(tester, Size(width, 900));
      await confirm(tester);
      await tester.tapAt(const Offset(2, 2));
      await navigator.currentState!.maybePop();
      await tester.pumpAndSettle();
      expect(find.byType(ResetDialog), findsOneWidget);
      expect(bloc.isClosed, isFalse);
      expect(
          tester
              .widget<AbsorbPointer>(find
                  .descendant(
                      of: find.byType(ResetDialog),
                      matching: find.byType(AbsorbPointer))
                  .first)
              .absorbing,
          isTrue);
      deletion.complete();
      await tester.pumpAndSettle();
      verify(() => session.onOnboarding()).called(1);
      expect(bloc.isClosed, isTrue);
    });
  }

  testWidgets('completion waits for settings deletion too', (tester) async {
    final clearing = Completer<void>();
    when(() => cache.removeAll()).thenAnswer((_) => clearing.future);
    await open(tester, const Size(1000, 900));
    await confirm(tester);
    verify(() => cache.removeAll()).called(1);
    verifyNever(() => session.onOnboarding());
    expect(find.text('RESETTING…'), findsOneWidget);
    clearing.complete();
    await tester.pumpAndSettle();
    verify(() => session.onOnboarding()).called(1);
  });

  testWidgets(
      'failed deletion is shown and can be retried without false success',
      (tester) async {
    when(() => accounts.deleteAllAccounts())
        .thenAnswer((_) async => throw StateError('test storage unavailable'));
    await open(tester, const Size(1000, 900));
    await confirm(tester);
    expect(find.textContaining('Some local data may already be deleted'),
        findsOneWidget);
    verifyNever(() => session.onOnboarding());
    verifyNever(() => addresses.deleteAllAddresses());
    when(() => accounts.deleteAllAccounts()).thenAnswer((_) async {});
    await tester.tap(find.byKey(const Key('continueButton')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    verify(() => session.onOnboarding()).called(1);
    verify(() => addresses.deleteAllAddresses()).called(1);
  });
}
