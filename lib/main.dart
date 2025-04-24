import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/common/fn.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/data/services/regtest_utils.dart';
import 'package:horizon/data/sources/local/db_manager.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/action_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/repositories/fairminter_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/repositories/version_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/inactivity_monitor/inactivity_monitor_bloc.dart';
import 'package:horizon/presentation/inactivity_monitor/inactivity_monitor_view.dart';
import 'package:horizon/presentation/screens/asset/asset_view.dart';
import 'package:horizon/presentation/screens/asset/bloc/asset_view_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/account_form/bloc/account_form_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/address_form/bloc/address_form_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/view/portfolio_view.dart';
import 'package:horizon/presentation/screens/login/login_view.dart';
import 'package:horizon/presentation/screens/onboarding/view/onboarding_page.dart';
import 'package:horizon/presentation/screens/onboarding_create/view/onboarding_create_page.dart';
import 'package:horizon/presentation/screens/onboarding_import/view/onboarding_import_page.dart';
import 'package:horizon/presentation/screens/privacy_policy.dart';
import 'package:horizon/presentation/screens/settings/import_address/bloc/import_address_pk_bloc.dart';
import 'package:horizon/presentation/screens/settings/settings_view.dart';
import 'package:horizon/presentation/screens/tos.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_bloc.dart';
import 'package:horizon/presentation/shell/app_shell.dart';
import 'package:horizon/presentation/version_cubit.dart';
import 'package:horizon/setup.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:horizon/presentation/screens/transactions/send/view/send_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> setupRegtestWallet() async {
  // read env for regtest private key
  const regtestPrivateKey = String.fromEnvironment('REG_TEST_PK');
  const regtestPassword = String.fromEnvironment('REG_TEST_PASSWORD');
  const network = String.fromEnvironment('NETWORK');

  if (regtestPrivateKey != "" &&
      regtestPassword != "" &&
      network == "regtest") {
    RegTestUtils regTestUtils = RegTestUtils();
    EncryptionService encryptionService = GetIt.I<EncryptionService>();
    AddressService addressService = GetIt.I<AddressService>();
    final accountRepository = GetIt.I<AccountRepository>();
    final addressRepository = GetIt.I<AddressRepository>();
    final walletRepository = GetIt.I<WalletRepository>();

    final maybeCurrentWallet = await walletRepository.getCurrentWallet();
    if (maybeCurrentWallet != null) {
      return;
    }

    Wallet wallet =
        await regTestUtils.fromBase58(regtestPrivateKey, regtestPassword);

    String decryptedPrivKey = await encryptionService.decrypt(
        wallet.encryptedPrivKey, regtestPassword);

    //m/84'/1'/0'/0
    Account account = Account(
      name: 'Regtest #0',
      walletUuid: wallet.uuid,
      purpose: '84\'',
      coinType: '1\'',
      accountIndex: '0\'',
      uuid: uuid.v4(),
      importFormat: ImportFormat.horizon,
    );

    List<Address> addresses = await addressService.deriveAddressSegwitRange(
        privKey: decryptedPrivKey,
        chainCodeHex: wallet.chainCodeHex,
        accountUuid: account.uuid,
        purpose: account.purpose,
        coin: account.coinType,
        account: account.accountIndex,
        change: '0',
        start: 0,
        end: 9);

    await walletRepository.insert(wallet);
    await accountRepository.insert(account);
    await addressRepository.insertMany(addresses);
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({this.from, super.key});
  final String? from;

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Color(0x001e1e38),
      );
}

class AppRouter {
  static GoRouter router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: "/dashboard",
      routes: <RouteBase>[
        GoRoute(
            path: "/",
            builder: (context, state) {
              return const LoadingScreen();
            }),
        if (GetIt.instance<Config>().isDatabaseViewerEnabled)
          GoRoute(
            path: "/db",
            pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child:
                    DriftDbViewer(GetIt.instance<DatabaseManager>().database),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) => child),
          ),
        GoRoute(
          path: "/privacy-policy",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const PrivacyPolicy(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child),
        ),
        GoRoute(
          path: "/tos",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const TermsOfService(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child),
        ),
        GoRoute(
          path: "/onboarding",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const OnboardingScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child),
        ),
        GoRoute(
          path: "/onboarding/create",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const OnboardingCreatePageWrapper(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child),
        ),
        GoRoute(
          path: "/onboarding/import",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const OnboardingImportPageWrapper(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child),
        ),
        GoRoute(
          path: "/login",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const LoginView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child),
        ),
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            // Check session state before showing the shell
            return ValueChangeObserver(
              cacheKey: SettingsKeys.inactivityTimeout.toString(),
              defaultValue: 5,
              builder: (context, inactivityTimeout, onChanged) {
                return BlocProvider(
                  key: Key("inactivity-timeout:$inactivityTimeout"),
                  create: (_) {
                    return InactivityMonitorBloc(
                      logger: GetIt.I<Logger>(),
                      kvService: GetIt.I<SecureKVService>(),
                      inactivityTimeout: Duration(minutes: inactivityTimeout),
                    );
                  },
                  child: InactivityMonitorView(
                    onTimeout: () {
                      final session = context.read<SessionStateCubit>();
                      session.onLogout();
                    },
                    child: context.watch<SessionStateCubit>().state.maybeWhen(
                          success: (sessionState) {
                            // Only show the shell if the user is logged in
                            return AppShell(
                              currentRoute: state.matchedLocation,
                              actionRepository: GetIt.I<ActionRepository>(),
                              child: child,
                            );
                          },
                          orElse: () => const LoadingScreen(),
                        ),
                  ),
                );
              },
            );
          },
          routes: [
            GoRoute(
              path: "/dashboard",
              builder: (context, state) {
                return const PortfolioView();
              },
            ),
            GoRoute(
              path: "/settings",
              builder: (context, state) => const SettingsView(),
            ),
            GoRoute(
              path: "/asset/:assetName",
              builder: (context, state) {
                final assetName = state.pathParameters['assetName'] ?? '';
                final session = context.read<SessionStateCubit>().state;

                return BlocProvider(
                  create: (context) => AssetViewBloc(
                    balanceRepository: GetIt.I<BalanceRepository>(),
                    fairminterRepository: GetIt.I<FairminterRepository>(),
                    addresses: session.allAddresses,
                    asset: assetName,
                  ),
                  child: AssetView(
                    assetName: assetName,
                  ),
                );
              },
            ),
            // CHATGPT: i need this route not to render an app footer
            GoRoute(
              path: "/asset/:assetName/compose/send",
              pageBuilder: (context, state) {
                final assetName = state.pathParameters['assetName'] ?? '';
                final session = context.read<SessionStateCubit>().state;

                return MaterialPage(
                  child: SendPage(
                    assetName: assetName,
                    addresses: session.allAddresses,
                  ),
                );
              },
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => ErrorScreen(
            error: state.error,
            onGoHome: () => context.go('/dashboard'),
          ),
      redirect: (context, state) async {
        if (state.matchedLocation == "/db") {
          return "/db";
        }

        if (state.matchedLocation == "/privacy-policy") {
          return "/privacy-policy";
        }

        if (state.matchedLocation == "/tos") {
          return "/tos";
        }

        final session = context.read<SessionStateCubit>();

        final path = session.state.maybeWhen(
            loggedOut: () => "/login",
            onboarding: (onboarding) {
              return onboarding.when(
                initial: () => "/onboarding",
                create: () => "/onboarding/create",
                import: () => "/onboarding/import",
                importPK: () => "/onboarding/import-pk",
              );
            },
            success: (data) {
              Future.delayed(const Duration(milliseconds: 500), () {
                session.initialized();
              });

              if (data.redirect) {
                return "/dashboard";
              }
            },
            // if the session state is not yet loaded, show a loading screen
            orElse: () => "/");

        final actionParam = state.uri.queryParameters['action'];

        if (actionParam != null) {
          final ActionRepository actionRepository =
              GetIt.instance<ActionRepository>();
          actionRepository
              .fromString(actionParam)
              .fold(noop1, (action) => actionRepository.enqueue(action));
        }
        return path;
      });
}

// Custom error screen widget
class ErrorScreen extends StatelessWidget {
  final Exception? error;
  final VoidCallback onGoHome;

  const ErrorScreen({super.key, this.error, required this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('GoRouter Exception: ${error?.toString() ?? 'Unknown error'}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onGoHome,
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  setup();

  // Catch synchronous errors in Flutter framework
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    // TODO: Is this error capture necessary?
    GetIt.I<ErrorService>().captureException(details.exception,
        context: {'runtimeType': details.exception.runtimeType.toString()});
  };

  // Catch uncaught asynchronous errors
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await setupRegtestWallet();
    await initSettings();

    final version = GetIt.I<Config>().version;
    final versionInfo = GetIt.I<VersionRepository>().get();

    versionInfo.match((failure) {
      runApp(MyApp(
        currentVersion: version,
        latestVersion: version,
        warning: VersionServiceUnreachable(),
      ));
    }, (versionInfo) {
      if (version < versionInfo.min) {
        runApp(MaterialApp(
          home: Scaffold(
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  AppIcons.warningIcon(
                    width: 60.0,
                    height: 60.0,
                    color: red1,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Upgrade Required!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // Bold font weight
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                      "Your version ($version) is below the minimum supported version (${versionInfo.min})",
                      style: const TextStyle(
                        fontSize: 18.0, // Standard readable font size
                        color: Colors.black87,
                      )),
                ])),
          ),
        ));
      } else if (version < versionInfo.latest) {
        runApp(MyApp(
          currentVersion: version,
          latestVersion: versionInfo.latest,
          warning: NewVersionAvailable(),
        ));
      } else {
        runApp(MyApp(
          currentVersion: version,
          latestVersion: versionInfo.latest,
        ));
      }
    }).run();
  }, (Object error, StackTrace stackTrace) {
    final logger = GetIt.I<Logger>();

    // Handle different error types
    if (error is DioException) {
      logger.error(error.message ?? "", null, stackTrace);
    } else if (error is TypeError) {
      // Handle type errors (like the minified event type error)
      final errorMessage = 'Type Error: ${error.toString()}';
      logger.error(errorMessage, error, stackTrace);
      GetIt.I<ErrorService>().captureException(error,
          message: errorMessage,
          context: {'runtimeType': error.runtimeType.toString()});
    } else {
      // Add more specific error type handling here as needed
      const errorMessage = 'An unexpected error occurred';
      logger.error(errorMessage, null, stackTrace);
      GetIt.I<ErrorService>().captureException(FlutterError(errorMessage),
          message: errorMessage,
          context: {'errorType': error.runtimeType.toString()});
    }
  });
}

Future<ValueNotifier<Color>> initSettings() async {
  await Settings.init(
    cacheProvider: GetIt.I<CacheProvider>(),
  );
  final accentColor = ValueNotifier(Colors.blueAccent);
  return accentColor;
}

class MyApp extends StatelessWidget {
  final Version currentVersion;
  final Version latestVersion;
  final VersionWarning? warning;

  const MyApp({
    required this.currentVersion,
    required this.latestVersion,
    this.warning,
    super.key,
  });

  ThemeData _buildLightTheme() {
    final baseTextTheme = ThemeData.light().textTheme;
    const customTextTheme = TextTheme(
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black,
        fontFamily: 'Montserrat',
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        color: transparentBlack66,
        fontFamily: 'Montserrat',
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: Colors.black,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontFamily: 'Montserrat',
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.black,
        fontFamily: 'Montserrat',
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        color: Colors.black,
        fontFamily: 'Montserrat',
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        color: transparentBlack66,
        fontFamily: 'Montserrat',
      ),
    );

    return ThemeData(
      fontFamily: 'Montserrat',
      brightness: Brightness.light,
      scaffoldBackgroundColor: offWhite,
      dialogTheme: DialogTheme(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      primaryTextTheme: baseTextTheme.apply(fontFamily: 'Montserrat'),
      textTheme: customTextTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.all(20),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: const BorderSide(color: transparentBlack8),
          ),
          padding: const EdgeInsets.all(20),
          foregroundColor: offBlack,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'Montserrat',
          ),
          disabledBackgroundColor: const Color.fromRGBO(10, 10, 10, 0.16),
          disabledForegroundColor: Colors.white.withOpacity(0.5),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 8,
            fontWeight: FontWeight.w500,
            height: 1.2, // This gives us 9.6px line height (8 * 1.2 = 9.6)
            letterSpacing: 0,
          ),
          foregroundColor: transparentBlack33,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.fromLTRB(7, 11, 14, 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: transparentBlack8,
            ),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(
          fontSize: 12,
          color: Colors.black,
          fontFamily: 'Montserrat',
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(grey1),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          shadowColor: WidgetStatePropertyAll(Colors.transparent),
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: transparentBlack8,
          fontFamily: 'Montserrat',
        ),
        contentPadding: EdgeInsets.zero,
        outlineBorder: BorderSide(
          color: transparentBlack8,
          width: 1,
        ),
        border: InputBorder.none,
        hintStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: transparentBlack33,
          fontFamily: 'Montserrat',
        ),
      ),
      extensions: const {
        CustomThemeExtension.light,
      },
    );
  }

  ThemeData _buildDarkTheme() {
    final baseTextTheme = ThemeData.dark().textTheme;
    const customTextTheme = TextTheme(
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        fontFamily: 'Montserrat',
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        color: transparentWhite66,
        fontFamily: 'Montserrat',
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: Colors.white,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontFamily: 'Montserrat',
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.white,
        fontFamily: 'Montserrat',
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        color: Colors.white,
        fontFamily: 'Montserrat',
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        color: transparentWhite66,
        fontFamily: 'Montserrat',
      ),
    );

    return ThemeData(
      fontFamily: 'Montserrat',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: offBlack,
      dialogTheme: DialogTheme(
        backgroundColor: black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      primaryTextTheme: baseTextTheme.apply(fontFamily: 'Montserrat'),
      textTheme: customTextTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.all(20),
          foregroundColor: Colors.black,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: const BorderSide(color: transparentWhite8),
          ),
          padding: const EdgeInsets.all(20),
          foregroundColor: offWhite,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'Montserrat',
          ),
          disabledBackgroundColor: const Color.fromRGBO(254, 251, 249, 0.16),
          disabledForegroundColor: Colors.white.withOpacity(0.5),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 8,
            fontWeight: FontWeight.w500,
            height: 1.2, // This gives us 9.6px line height (8 * 1.2 = 9.6)
            letterSpacing: 0,
          ),
          foregroundColor: transparentWhite33,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: black,
          foregroundColor: white,
          padding: const EdgeInsets.fromLTRB(7, 11, 14, 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: transparentWhite8,
            ),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontFamily: 'Montserrat',
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(grey5),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          shadowColor: WidgetStatePropertyAll(Colors.transparent),
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: transparentWhite8,
          fontFamily: 'Montserrat',
        ),
        isDense: true,
        contentPadding: EdgeInsets.zero,
        outlineBorder: BorderSide(color: transparentWhite8, width: 1),
        border: InputBorder.none,
        hintStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: transparentWhite33,
          fontFamily: 'Montserrat',
        ),
      ),
      extensions: const {
        CustomThemeExtension.dark,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // if showWarning, just display a one off toast here?

    return MultiBlocProvider(
      providers: [
        BlocProvider<VersionCubit>(
          create: (context) => VersionCubit(VersionCubitState(
            latest: latestVersion,
            current: currentVersion,
            warning: warning,
          )),
        ),
        BlocProvider<SessionStateCubit>(
          create: (context) => SessionStateCubit(
              kvService: GetIt.I<SecureKVService>(),
              encryptionService: GetIt.I<EncryptionService>(),
              inMemoryKeyRepository: GetIt.I<InMemoryKeyRepository>(),
              cacheProvider: GetIt.I<CacheProvider>(),
              walletRepository: GetIt.I<WalletRepository>(),
              accountRepository: GetIt.I<AccountRepository>(),
              addressRepository: GetIt.I<AddressRepository>(),
              importedAddressRepository: GetIt.I<ImportedAddressRepository>(),
              analyticsService: GetIt.I<AnalyticsService>())
            ..initialize(),
        ),
        BlocProvider<AccountFormBloc>(
          create: (context) => AccountFormBloc(
            passwordRequired: GetIt.I<SettingsRepository>()
                .requirePasswordForCryptoOperations,
            accountRepository: GetIt.I<AccountRepository>(),
            walletRepository: GetIt.I<WalletRepository>(),
            inMemoryKeyRepository: GetIt.I<InMemoryKeyRepository>(),
            walletService: GetIt.I<WalletService>(),
            encryptionService: GetIt.I<EncryptionService>(),
            addressService: GetIt.I<AddressService>(),
            addressRepository: GetIt.I<AddressRepository>(),
            errorService: GetIt.I<ErrorService>(),
          ),
        ),
        BlocProvider<AddressFormBloc>(
          create: (context) => AddressFormBloc(
            passwordRequired: GetIt.I<SettingsRepository>()
                .requirePasswordForCryptoOperations,
            inMemoryKeyRepository: GetIt.I<InMemoryKeyRepository>(),
            walletRepository: GetIt.I<WalletRepository>(),
            walletService: GetIt.I<WalletService>(),
            encryptionService: GetIt.I<EncryptionService>(),
            addressRepository: GetIt.I<AddressRepository>(),
            accountRepository: GetIt.I<AccountRepository>(),
            addressService: GetIt.I<AddressService>(),
            errorService: GetIt.I<ErrorService>(),
          ),
        ),
        BlocProvider<ImportAddressPkBloc>(
          create: (context) => ImportAddressPkBloc(
            inMemoryKeyRepository: GetIt.I<InMemoryKeyRepository>(),
            walletRepository: GetIt.I<WalletRepository>(),
            walletService: GetIt.I<WalletService>(),
            encryptionService: GetIt.I<EncryptionService>(),
            addressService: GetIt.I<AddressService>(),
            addressRepository: GetIt.I<AddressRepository>(),
            importedAddressRepository: GetIt.I<ImportedAddressRepository>(),
            importedAddressService: GetIt.I<ImportedAddressService>(),
          ),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(GetIt.I<CacheProvider>()),
        ),
      ],
      child: BlocListener<SessionStateCubit, SessionState>(
        listener: (context, state) {
          AppRouter.router.refresh();
        },
        child: BlocBuilder<ThemeBloc, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              theme: _buildLightTheme(),
              darkTheme: _buildDarkTheme(),
              themeMode: themeMode,
              routeInformationParser: AppRouter.router.routeInformationParser,
              routerDelegate: AppRouter.router.routerDelegate,
              routeInformationProvider:
                  AppRouter.router.routeInformationProvider,
            );
          },
        ),
      ),
    );
  }
}
