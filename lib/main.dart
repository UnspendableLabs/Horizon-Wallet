import 'dart:async';

import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/data/sources/local/db_manager.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/screens/compose_issuance/view/compose_issuance_page.dart';
import 'package:horizon/presentation/screens/compose_send/view/compose_send_page.dart';
import 'package:horizon/presentation/screens/dashboard/view/dashboard_page.dart';
import 'package:horizon/presentation/screens/onboarding/view/onboarding_page.dart';
import 'package:horizon/presentation/screens/onboarding_create/view/onboarding_create_page.dart';
import 'package:horizon/presentation/screens/onboarding_import/view/onboarding_import_page.dart';
import "package:horizon/presentation/screens/settings/bloc/password_prompt_bloc.dart";
import 'package:horizon/presentation/screens/settings/view/settings_page.dart';
import 'package:horizon/presentation/shell/account_form/bloc/account_form_bloc.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/shell/bloc/shell_state.dart';
import 'package:horizon/presentation/shell/view/shell.dart';
import 'package:horizon/remote_data_bloc/remote_data_state.dart';
import 'package:horizon/setup.dart';
import 'package:logger/logger.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _sectionNavigatorKey = GlobalKey<NavigatorState>();

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({this.from, Key? key}) : super(key: key);
  final String? from;

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Text('loading...'),
            ],
          ),
        ),
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
        GoRoute(
          path: "/db",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: DriftDbViewer(GetIt.instance<DatabaseManager>().database),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => child),
        ),
        GoRoute(
          path: "/onboarding",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: OnboardingScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => child),
        ),
        GoRoute(
          path: "/onboarding/create",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const OnboardingCreateScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => child),
        ),
        GoRoute(
          path: "/onboarding/import",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: OnboardingImportPage(), // TODO: be consistent with screen / page
              transitionsBuilder: (context, animation, secondaryAnimation, child) => child),
        ),
        StatefulShellRoute.indexedStack(
            builder: (BuildContext context, GoRouterState state, navigationShell) {
              return Shell(navigationShell);
            },
            branches: [
              StatefulShellBranch(
                navigatorKey: _sectionNavigatorKey,
                routes: [
                  GoRoute(
                    path: "/dashboard",
                    builder: (context, state) => const DashboardPage(),
                  )
                ],
              ),
              StatefulShellBranch(routes: [
                GoRoute(
                    path: "/compose/send",
                    builder: (context, state) {
                      return ComposeSendPage();
                    })
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  path: "/compose/issuance",
                  builder: (context, state) {
                    return ComposeIssuancePage();
                  },
                ),
              ]),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                      path: "/settings",
                      builder: (context, state) {
                        final shell = context.watch<ShellStateCubit>();
                        // final accountSettingsRepository =
                        //     GetIt.I<AccountSettingsRepository>();

                        return shell.state.maybeWhen(
                          success: (state) {
                            return SettingsPage();
                          },
                          orElse: () => const SizedBox.shrink(),
                        );
                      })
                ],
              ),
              // StatefulShellBranch(
              //   routes: [
              //     GoRoute(
              //       path: "/settings",
              //       builder: (context, state) => const SettingsPage(),
              //     )
              //   ],
              // ),
            ])
      ],
      redirect: (context, state) async {
        final shell = context.read<ShellStateCubit>();

        final path = shell.state.maybeWhen(
            success: (data) {
              print("shell.state ${shell.state}");
              Future.delayed(const Duration(milliseconds: 500), () {
                shell.initialized();
              });

              // if accounts, show dashboard
              if (data.redirect && data.accounts.isNotEmpty) {
                return "/dashboard";
                // if no accounts, show onboarding
              } else if (data.redirect && data.accounts.isEmpty) {
                return "/onboarding";
              } else {
                return null;
              }
            },
            // if the shell state is not yet loaded, show a loading screen
            orElse: () => "/");

        return path;
      });
}

void main() {
  final logger = Logger();
  // Catch synchronous errors in Flutter framework
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  // Catch uncaught asynchronous errors
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load();

    await setup();

    await initSettings();

    runApp(MyApp());
  }, (Object error, StackTrace stackTrace) {
    logger.e({'error': error.toString(), 'stackTrace': stackTrace.toString()});
    // Log the error to a service or handle it accordingly
  });
}

Future<ValueNotifier<Color>> initSettings() async {
  await Settings.init(
    cacheProvider: GetIt.I<CacheProvider>(),
  );
  final _accentColor = ValueNotifier(Colors.blueAccent);
  return _accentColor;
}

class MyApp extends StatelessWidget {
  MyApp({
    super.key,
  });

  // Define light and dark themes
  final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color.fromRGBO(246, 247, 250, 1),
      primaryColor: const Color.fromRGBO(68, 69, 99, 1),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color.fromRGBO(227, 237, 254, 1),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color.fromRGBO(68, 69, 99, 1)),
        bodyMedium: TextStyle(color: Color.fromRGBO(106, 106, 134, 1)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(227, 237, 254, 1),
          foregroundColor: const Color.fromRGBO(68, 121, 252, 1),
        ),
      ),
      listTileTheme: const ListTileThemeData(
          iconColor: Color.fromRGBO(106, 106, 134, 1),
          textColor: Color.fromRGBO(106, 106, 134, 1),
          selectedColor: Color.fromRGBO(68, 121, 252, 1)),
      appBarTheme: AppBarTheme(
        color: const Color.fromRGBO(246, 247, 250, 1),
        titleTextStyle: TextStyle(
          color: const Color.fromRGBO(68, 69, 99, 1),
        ),
      ));

  final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color.fromRGBO(35, 35, 58, 1),
      primaryColor: Colors.white,
      buttonTheme: const ButtonThemeData(
        buttonColor: Color.fromRGBO(25, 25, 39, 1),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Color.fromRGBO(141, 141, 153, 1)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(25, 25, 39, 1),
          foregroundColor: const Color.fromRGBO(146, 209, 253, 1),
        ),
      ),
      listTileTheme: const ListTileThemeData(
          iconColor: Color.fromRGBO(183, 183, 188, 1),
          textColor: Color.fromRGBO(183, 183, 188, 1),
          selectedColor: Color.fromRGBO(146, 209, 254, 1)),
      appBarTheme: AppBarTheme(
        color: Color.fromRGBO(35, 35, 58, 1),
        titleTextStyle: TextStyle(
          color: Colors.white,
        ),
      ));

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PasswordPromptBloc>(
          create: (context) => PasswordPromptBloc(
            walletService: GetIt.I<WalletService>(),
            walletRepository: GetIt.I<WalletRepository>(),
            encryptionService: GetIt.I<EncryptionService>(),
          ),
        ),
        BlocProvider<ShellStateCubit>(
          create: (context) => ShellStateCubit(
            walletRepository: GetIt.I<WalletRepository>(),
            accountRepository: GetIt.I<AccountRepository>(),
          )..initialize(),
        ),
        BlocProvider<AccountFormBloc>(
          create: (context) => AccountFormBloc(),
        ),
      ],
      child: BlocListener<ShellStateCubit, RemoteDataState<ShellState>>(
        listener: (context, state) {
          AppRouter.router.refresh();
        },
        child: MaterialApp.router(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.light, // Automatically switch between light and dark themes
          routeInformationParser: AppRouter.router.routeInformationParser,
          routerDelegate: AppRouter.router.routerDelegate,
          routeInformationProvider: AppRouter.router.routeInformationProvider,
        ),
      ),
    );
  }
}
