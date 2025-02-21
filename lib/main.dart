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
import 'package:horizon/domain/repositories/config_repository.dart';
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
import 'package:horizon/presentation/common/footer/view/footer.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/inactivity_monitor/inactivity_monitor_bloc.dart';
import 'package:horizon/presentation/inactivity_monitor/inactivity_monitor_view.dart';
import 'package:horizon/presentation/screens/dashboard/account_form/bloc/account_form_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/address_form/bloc/address_form_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/view/dashboard_page.dart';
import 'package:horizon/presentation/screens/login/login_view.dart';
import 'package:horizon/presentation/screens/onboarding/view/onboarding_page.dart';
import 'package:horizon/presentation/screens/onboarding_create/view/onboarding_create_page.dart';
import 'package:horizon/presentation/screens/onboarding_import/view/onboarding_import_page.dart';
import 'package:horizon/presentation/screens/privacy_policy.dart';
import 'package:horizon/presentation/screens/settings/settings_view.dart';
import 'package:horizon/presentation/screens/tos.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_bloc.dart';
import 'package:horizon/presentation/version_cubit.dart';
import 'package:horizon/setup.dart';
import 'package:pub_semver/pub_semver.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _sectionNavigatorKey = GlobalKey<NavigatorState>();

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

class VersionWarningSnackbar extends StatefulWidget {
  final Widget child;

  const VersionWarningSnackbar({required this.child, super.key});

  @override
  VersionWarningState createState() => VersionWarningState();
}

class VersionWarningState extends State<VersionWarningSnackbar> {
  bool _hasShownSnackbar = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final versionInfo = context
        .read<VersionCubit>()
        .state; // we should only ever get to this page if session is success

    if (!_hasShownSnackbar && versionInfo.warning != null) {
      switch (versionInfo.warning!) {
        case NewVersionAvailable():
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                'There is a new version of Horizon Wallet: ${versionInfo.latest}.  Your version is ${versionInfo.current} ',
              )),
            );
            _hasShownSnackbar = true;
          });
          break;
        case VersionServiceUnreachable():
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                'Version service unreachable.  Horizon Wallet may be out of date. Your version is ${versionInfo.current} ',
              )),
            );
            _hasShownSnackbar = true;
          });
          break;
      }
    }

    if (!_hasShownSnackbar && versionInfo.current < versionInfo.latest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'There is a new version of Horizon Wallet: ${versionInfo.latest}.  Your version is ${versionInfo.current} ',
          )),
        );
        _hasShownSnackbar = true;
      });
    }
  }

  @override
  Widget build(context) => widget.child;
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
        StatefulShellRoute.indexedStack(
            builder:
                (BuildContext context, GoRouterState state, navigationSession) {
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
                            inactivityTimeout:
                                Duration(minutes: inactivityTimeout),
                          );
                        },
                        child: InactivityMonitorView(
                          onTimeout: () {
                            final session = context.read<SessionStateCubit>();
                            session.onLogout();
                          },
                          child: navigationSession,
                        ));
                  });
              return navigationSession;
            },
            branches: [
              StatefulShellBranch(
                navigatorKey: _sectionNavigatorKey,
                routes: [
                  GoRoute(
                      path: "/dashboard",
                      builder: (context, state) {
                        final session = context.watch<SessionStateCubit>();

                        // this technically isn't necessary, will always be
                        // success
                        return session.state.maybeWhen(
                          success: (state) {
                            final Key key = Key(state.wallet.uuid);

                            return Scaffold(
                                bottomNavigationBar: const Footer(),
                                body: VersionWarningSnackbar(
                                    child: DashboardPageWrapper(key: key)));
                          },
                          orElse: () => const LoadingScreen(),
                        );
                      }),
                  GoRoute(
                      path: "/settings",
                      builder: (context, state) {
                        final session = context.watch<SessionStateCubit>();

                        // this technically isn't necessary, will always be
                        // success
                        return session.state.maybeWhen(
                          success: (state) {
                            final Key key = Key(state.wallet.uuid);

                            return const Scaffold(
                                bottomNavigationBar: Footer(),
                                body: VersionWarningSnackbar(
                                    child: SettingsView()));
                          },
                          orElse: () => const LoadingScreen(),
                        );
                      }),
                ],
              ),
            ])
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
                  const Icon(Icons.warning_amber_rounded,
                      size: 60.0, color: Colors.redAccent),
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
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: lightThemeBackgroundColor,
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
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: BorderSide.none,
          ),
          padding: const EdgeInsets.all(20),
          foregroundColor: Colors.black,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
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
          backgroundColor: transparentPurpleButtonColor,
          textStyle: const TextStyle(
            color: Colors.black,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          iconColor: Colors.black,
        ),
      ),
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      textTheme: const TextTheme(
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          titleSmall: TextStyle(
            fontSize: 12,
            color: subtitleLightTextColor,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: Colors.black,
          )),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(
          fontSize: 12,
          color: Colors.black,
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(inputLightBackground),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          shadowColor: WidgetStatePropertyAll(Colors.transparent),
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        hintStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: inputLightLabelColor,
        ),
      ),
      extensions: {
        CustomThemeExtension.light,
      },
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: darkThemeBackgroundColor,
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
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: importButtonDarkBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: BorderSide.none,
          ),
          padding: const EdgeInsets.all(20),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
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
          backgroundColor: Colors.transparent,
          textStyle: const TextStyle(
            color: Colors.white,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          iconColor: Colors.white,
        ),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      textTheme: const TextTheme(
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          titleSmall: TextStyle(
            fontSize: 12,
            color: subtitleDarkTextColor,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: Colors.white,
          )),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(inputDarkBackground),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          shadowColor: WidgetStatePropertyAll(Colors.transparent),
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        hintStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: inputDarkLabelColor,
        ),
      ),
      extensions: {
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
