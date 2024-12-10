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
import 'package:horizon/domain/repositories/version_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/footer/view/footer.dart';
import 'package:horizon/presentation/screens/dashboard/account_form/bloc/account_form_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/address_form/bloc/address_form_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/view/dashboard_page.dart';
import 'package:horizon/presentation/screens/onboarding/view/onboarding_page.dart';
import 'package:horizon/presentation/screens/onboarding_create/view/onboarding_create_page.dart';
import 'package:horizon/presentation/screens/onboarding_import/view/onboarding_import_page.dart';
import 'package:horizon/presentation/screens/onboarding_import_pk/view/onboarding_import_pk_page.dart';
import 'package:horizon/presentation/screens/privacy_policy.dart';
import 'package:horizon/presentation/screens/tos.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/shell/bloc/shell_state.dart';
import 'package:horizon/presentation/shell/theme/bloc/theme_bloc.dart';
import 'package:horizon/presentation/version_cubit.dart';
import 'package:horizon/setup.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:horizon/domain/services/sentry_service.dart';

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
        .state; // we should only ever get to this page if shell is success

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
          path: "/onboarding/import-pk",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const OnboardingImportPKPageWrapper(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child),
        ),
        StatefulShellRoute.indexedStack(
            builder:
                (BuildContext context, GoRouterState state, navigationShell) {
              return navigationShell;
            },
            branches: [
              StatefulShellBranch(
                navigatorKey: _sectionNavigatorKey,
                routes: [
                  GoRoute(
                      path: "/dashboard",
                      builder: (context, state) {
                        final shell = context.watch<ShellStateCubit>();

                        // this technically isn't necessary, will always be
                        // success
                        return shell.state.maybeWhen(
                          success: (state) {
                            late Key key;
                            if (state.currentAddress != null) {
                              key = Key(state.currentAddress!.address);
                            } else if (state.currentImportedAddress != null) {
                              key = Key(state.currentImportedAddress!.address);
                            }
                            return Scaffold(
                                bottomNavigationBar: const Footer(),
                                body: VersionWarningSnackbar(
                                    child: DashboardPageWrapper(key: key)));
                          },
                          orElse: () => const LoadingScreen(),
                        );
                      })
                ],
              ),
            ])
      ],
      errorBuilder: (context, state) => ErrorScreen(
            error: state.error,
            onGoHome: () => context.go('/dashboard'),
          ),
      redirect: (context, state) async {
        if (state.matchedLocation == "/privacy-policy") {
          return "/privacy-policy";
        }

        if (state.matchedLocation == "/tos") {
          return "/tos";
        }

        final shell = context.read<ShellStateCubit>();

        final path = shell.state.maybeWhen(
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
                shell.initialized();
              });

              if (data.redirect) {
                return "/dashboard";
              }
            },
            // if the shell state is not yet loaded, show a loading screen
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
  // Catch synchronous errors in Flutter framework
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    GetIt.I<SentryService>()
        .captureException(details.exception, stackTrace: details.stack);
  };

  // Catch uncaught asynchronous errors
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await setup();
    await GetIt.I<SentryService>().initialize();

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
    if (error is DioException) {
      logger.error(error.message ?? "", null, stackTrace);
    } else {
      logger.error(error.toString(), null, stackTrace);
    }
    GetIt.I<SentryService>().captureException(error, stackTrace: stackTrace);
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

  MyApp({
    required this.currentVersion,
    required this.latestVersion,
    this.warning,
    super.key,
  });

  // Define light and dark themes
  final ThemeData lightTheme = ThemeData(
    // define a color scheme so it doesn't display flutter default purples
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
        backgroundColor: whiteLightTheme, scrolledUnderElevation: 0.0),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: noBackgroundColor,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: noBackgroundColor,
    ),
    primaryColor: const Color.fromRGBO(68, 69, 99, 1),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color.fromRGBO(227, 237, 254, 1),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Montserrat'),
      displayMedium: TextStyle(fontFamily: 'Montserrat'),
      displaySmall: TextStyle(fontFamily: 'Montserrat'),
      headlineLarge: TextStyle(fontFamily: 'Montserrat'),
      headlineMedium: TextStyle(fontFamily: 'Montserrat'),
      headlineSmall: TextStyle(fontFamily: 'Montserrat'),
      titleLarge: TextStyle(fontFamily: 'Montserrat'),
      titleMedium: TextStyle(fontFamily: 'Montserrat'),
      titleSmall: TextStyle(fontFamily: 'Montserrat'),
      bodyLarge: TextStyle(
          color: Color.fromRGBO(68, 69, 99, 1), fontFamily: 'Montserrat'),
      bodyMedium: TextStyle(
          color: Color.fromRGBO(106, 106, 134, 1), fontFamily: 'Montserrat'),
      bodySmall: TextStyle(fontFamily: 'Montserrat'),
      labelLarge: TextStyle(fontFamily: 'Montserrat'),
      labelMedium: TextStyle(fontFamily: 'Montserrat'),
      labelSmall: TextStyle(fontFamily: 'Montserrat'),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: elevatedButtonBackgroundLightTheme,
        foregroundColor: elevatedButtonForegroundLightTheme,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: const Color.fromRGBO(68, 121, 252, 1),
        foregroundColor: const Color.fromRGBO(227, 237, 254, 1),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color.fromRGBO(68, 121, 252, 1),
        side: const BorderSide(
          color: Color.fromRGBO(68, 121, 252, 1),
        ),
      ),
    ),
    listTileTheme: const ListTileThemeData(
        iconColor: elevatedButtonForegroundLightTheme,
        textColor: elevatedButtonForegroundLightTheme,
        selectedColor: royalBlueLightTheme),
    dialogTheme: const DialogTheme(
      contentTextStyle: TextStyle(color: mainTextBlack),
      backgroundColor: dialogBackgroundColorLightTheme,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      modalBackgroundColor: dialogBackgroundColorLightTheme,
      backgroundColor: dialogBackgroundColorLightTheme,
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: dialogBackgroundColorLightTheme,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightThemeInputColor,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: const TextStyle(
          fontWeight: FontWeight.normal, color: lightThemeInputLabelColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: redErrorText),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide.none,
      checkColor: WidgetStateProperty.all(royalBlueLightTheme),
      fillColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return lightThemeInputColor; // Color when selected
          }
          return lightThemeInputColor; // Use default color when not selected
        },
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lightThemeInputLabelColor,
        backgroundColor: noBackgroundColor,
        textStyle: const TextStyle(
          color: lightThemeInputLabelColor,
        ),
      ),
    ),
    dividerColor: greyLightThemeUnderlineColor,
    cardTheme: CardTheme(
      color: lightThemeInputColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
    ),
    canvasColor: lightThemeInputColor,
    cardColor: lightThemeInputColor,
  );

  final ThemeData darkTheme = ThemeData(
    // define a color scheme so it doesn't display flutter default purples
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightNavyDarkTheme,
      scrolledUnderElevation: 0.0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: noBackgroundColor,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: noBackgroundColor,
    ),
    primaryColor: Colors.white,
    buttonTheme: const ButtonThemeData(
      buttonColor: Color.fromRGBO(25, 25, 39, 1),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Montserrat'),
      displayMedium: TextStyle(fontFamily: 'Montserrat'),
      displaySmall: TextStyle(fontFamily: 'Montserrat'),
      headlineLarge: TextStyle(fontFamily: 'Montserrat'),
      headlineMedium: TextStyle(fontFamily: 'Montserrat'),
      headlineSmall: TextStyle(fontFamily: 'Montserrat'),
      titleLarge: TextStyle(fontFamily: 'Montserrat'),
      titleMedium: TextStyle(fontFamily: 'Montserrat'),
      titleSmall: TextStyle(fontFamily: 'Montserrat'),
      bodyLarge: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
      bodyMedium: TextStyle(
          color: Color.fromRGBO(141, 141, 153, 1), fontFamily: 'Montserrat'),
      bodySmall: TextStyle(fontFamily: 'Montserrat'),
      labelLarge: TextStyle(fontFamily: 'Montserrat'),
      labelMedium: TextStyle(fontFamily: 'Montserrat'),
      labelSmall: TextStyle(fontFamily: 'Montserrat'),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: elevatedButtonBackgroundDarkTheme,
        foregroundColor: elevatedButtonForegroundDarkTheme,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: filledButtonBackgroundDarkTheme,
        foregroundColor: neonBlueDarkTheme,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color.fromRGBO(146, 209, 253, 1),
        side: const BorderSide(
          color: Color.fromRGBO(146, 209, 253, 1),
        ),
      ),
    ),
    listTileTheme: const ListTileThemeData(
        iconColor: elevatedButtonForegroundDarkTheme,
        textColor: elevatedButtonForegroundDarkTheme,
        selectedColor: neonBlueDarkTheme),

    dialogTheme: const DialogTheme(
      contentTextStyle: TextStyle(color: mainTextWhite),
      backgroundColor: dialogBackgroundColorDarkTheme,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      modalBackgroundColor: dialogBackgroundColorDarkTheme,
      backgroundColor: dialogBackgroundColorDarkTheme,
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: darkNavyDarkTheme,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkThemeInputColor,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: const TextStyle(
          fontWeight: FontWeight.normal, color: darkThemeInputLabelColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: redErrorText),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide.none,
      checkColor: WidgetStateProperty.all(neonBlueDarkTheme),
      fillColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return filledButtonBackgroundDarkTheme; // Color when selected
          }
          return filledButtonBackgroundDarkTheme; // Use default color when not selected
        },
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkThemeInputLabelColor,
        backgroundColor: noBackgroundColor,
        textStyle: const TextStyle(
          color: darkThemeInputLabelColor,
        ),
      ),
    ),
    dividerColor: greyDarkThemeUnderlineColor,
    cardTheme: CardTheme(
      color: darkThemeInputColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
    ),
    canvasColor: darkThemeInputColor,
    cardColor: darkThemeInputColor,
  );

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
        BlocProvider<ShellStateCubit>(
          create: (context) => ShellStateCubit(
              walletRepository: GetIt.I<WalletRepository>(),
              accountRepository: GetIt.I<AccountRepository>(),
              addressRepository: GetIt.I<AddressRepository>(),
              importedAddressRepository: GetIt.I<ImportedAddressRepository>(),
              analyticsService: GetIt.I<AnalyticsService>())
            ..initialize(),
        ),
        BlocProvider<AccountFormBloc>(
          create: (context) => AccountFormBloc(
            accountRepository: GetIt.I<AccountRepository>(),
            walletRepository: GetIt.I<WalletRepository>(),
            walletService: GetIt.I<WalletService>(),
            encryptionService: GetIt.I<EncryptionService>(),
            addressService: GetIt.I<AddressService>(),
            addressRepository: GetIt.I<AddressRepository>(),
          ),
        ),
        BlocProvider<AddressFormBloc>(
          create: (context) => AddressFormBloc(
            walletRepository: GetIt.I<WalletRepository>(),
            walletService: GetIt.I<WalletService>(),
            encryptionService: GetIt.I<EncryptionService>(),
            addressRepository: GetIt.I<AddressRepository>(),
            accountRepository: GetIt.I<AccountRepository>(),
            addressService: GetIt.I<AddressService>(),
          ),
        ),
        BlocProvider<ImportAddressPkBloc>(
          create: (context) => ImportAddressPkBloc(
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
      child: BlocListener<ShellStateCubit, ShellState>(
        listener: (context, state) {
          AppRouter.router.refresh();
        },
        child: BlocBuilder<ThemeBloc, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              theme: lightTheme,
              darkTheme: darkTheme,
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
