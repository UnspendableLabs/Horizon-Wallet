import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/presentation/screens/settings/settings_view.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_bloc.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_event.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

// Mock classes
class MockSessionStateCubit extends Mock implements SessionStateCubit {}

class MockThemeBloc extends Mock implements ThemeBloc {}

class MockWalletRepository extends Mock implements WalletRepository {}

class MockEncryptionService extends Mock implements EncryptionService {}

class MockWalletService extends Mock implements WalletService {}

class MockAddressService extends Mock implements AddressService {}

class MockAddressRepository extends Mock implements AddressRepository {}

class MockImportedAddressRepository extends Mock
    implements ImportedAddressRepository {}

class MockImportedAddressService extends Mock
    implements ImportedAddressService {}

class MockInMemoryKeyRepository extends Mock implements InMemoryKeyRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockCacheProvider extends Mock implements CacheProvider {}

class MockSecureKVService extends Mock implements SecureKVService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSessionStateCubit mockSessionCubit;
  late MockThemeBloc mockThemeBloc;
  late MockCacheProvider mockCacheProvider;
  final getIt = GetIt.instance;

  setUpAll(() async {
    mockCacheProvider = MockCacheProvider();
    when(() => mockCacheProvider.init()).thenAnswer((_) async {});
    when(() => mockCacheProvider.removeAll()).thenAnswer((_) async {});
    when(() => mockCacheProvider.getValue<bool>(any(),
        defaultValue: any(named: 'defaultValue'))).thenReturn(true);
    when(() => mockCacheProvider.containsKey(any())).thenReturn(true);

    // Initialize Settings with a mock cache provider
    await Settings.init(
      cacheProvider: mockCacheProvider,
    );

    registerFallbackValue(ThemeToggled());

    // Create a minimal valid SVG string
    const String validSvg = '''
<?xml version="1.0" encoding="UTF-8"?>
<svg width="24" height="24" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <rect width="24" height="24"/>
</svg>''';

    // Convert the SVG string to bytes
    final Uint8List svgBytes = Uint8List.fromList(validSvg.codeUnits);
    final ByteData byteData = ByteData.sublistView(svgBytes);

    // Mock the loading of all SVG files with the same valid SVG data
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        if (message != null) {
          final String asset = utf8.decode(message.buffer
              .asUint8List(message.offsetInBytes, message.lengthInBytes));
          if (asset.endsWith('.svg')) {
            return byteData;
          }
        }
        return null;
      },
    );
  });

  setUp(() async {
    mockSessionCubit = MockSessionStateCubit();
    mockThemeBloc = MockThemeBloc();

    // Reset and wait for GetIt to be ready
    getIt.reset();
    await getIt.allReady();

    // Register GetIt dependencies
    getIt.registerSingleton<WalletRepository>(MockWalletRepository());
    getIt.registerSingleton<EncryptionService>(MockEncryptionService());
    getIt.registerSingleton<WalletService>(MockWalletService());
    getIt.registerSingleton<AddressService>(MockAddressService());
    getIt.registerSingleton<AddressRepository>(MockAddressRepository());
    getIt.registerSingleton<ImportedAddressRepository>(
        MockImportedAddressRepository());
    getIt.registerSingleton<ImportedAddressService>(
        MockImportedAddressService());
    getIt.registerSingleton<InMemoryKeyRepository>(MockInMemoryKeyRepository());
    getIt.registerSingleton<AccountRepository>(MockAccountRepository());
    getIt.registerSingleton<AnalyticsService>(MockAnalyticsService());
    getIt.registerSingleton<SecureKVService>(MockSecureKVService());
    getIt.registerSingleton<CacheProvider>(mockCacheProvider);

    const successState = SessionState.success(SessionStateSuccess(
        redirect: false,
        wallet: Wallet(
            uuid: 'test-uuid',
            name: 'Test Wallet',
            encryptedPrivKey: 'encrypted-key',
            encryptedMnemonic: 'encrypted-mnemonic',
            chainCodeHex: 'chain-code',
            publicKey: 'public-key'),
        decryptionKey: 'decryption-key',
        accounts: [],
        addresses: [],
        importedAddresses: []));

    // Mock session state and stream
    when(() => mockSessionCubit.state).thenReturn(successState);
    when(() => mockSessionCubit.stream)
        .thenAnswer((_) => Stream.value(successState));

    // Mock theme bloc
    when(() => mockThemeBloc.state).thenReturn(ThemeMode.dark);
    when(() => mockThemeBloc.stream)
        .thenAnswer((_) => Stream.value(ThemeMode.dark));
  });

  tearDown(() async {
    Settings.clearCache();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SessionStateCubit>.value(value: mockSessionCubit),
          BlocProvider<ThemeBloc>.value(value: mockThemeBloc),
        ],
        child: const Material(child: SettingsView()),
      ),
    );
  }

  group('SettingsView Widget Tests', () {
    testWidgets('renders main settings page correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify page title
      expect(find.text('Settings'), findsOneWidget);

      // Verify all main menu items are present
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Seed phrase'), findsOneWidget);
      expect(find.text('Import new address'), findsOneWidget);
      expect(find.text('Reset wallet'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Lock Screen'), findsOneWidget);
    });

    testWidgets('navigates to Security page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Security'));
      await tester.pumpAndSettle();

      expect(find.text('Security'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('navigates to Seed phrase page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Seed phrase'));
      await tester.pumpAndSettle();

      expect(find.text('Seed Phrase'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('navigates to Import address page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Import new address'));
      await tester.pumpAndSettle();

      expect(find.text('Import Address'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('navigates to Reset wallet page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset wallet'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Wallet'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('back button returns to main settings', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Navigate to Security page
      await tester.tap(find.text('Security'));
      await tester.pumpAndSettle();

      // Verify we're on Security page
      expect(find.text('Security'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Verify we're back on main settings page
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Seed phrase'), findsOneWidget);
    });

    testWidgets('lock screen button triggers logout', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock Screen'));
      await tester.pumpAndSettle();

      verify(() => mockSessionCubit.onLogout()).called(1);
    });

    testWidgets('theme toggle changes theme', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Find and tap the Appearance item
      final themeToggle = find.byType(ThemeToggle);
      expect(themeToggle, findsOneWidget);

      // Tap the theme toggle
      await tester.tap(themeToggle);
      await tester.pumpAndSettle();

      // Verify theme bloc was called
      verify(() => mockThemeBloc.add(any())).called(1);
    });
  });
}
