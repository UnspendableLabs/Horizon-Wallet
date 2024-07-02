import 'dart:async';
import 'dart:js_interop';

import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/data/sources/local/db_manager.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/presentation/screens/compose_issuance/view/compose_issuance_page.dart';
import 'package:horizon/presentation/screens/compose_send/view/compose_send_page.dart';
import 'package:horizon/presentation/screens/dashboard/view/dashboard_page.dart';
import 'package:horizon/presentation/screens/onboarding/view/onboarding_page.dart';
import 'package:horizon/presentation/screens/onboarding_create/view/onboarding_create_page.dart';
import 'package:horizon/presentation/screens/onboarding_import/view/onboarding_import_page.dart';

import 'package:horizon/setup.dart';
import 'package:logger/logger.dart';

import 'package:horizon/remote_data_bloc/remote_data_state.dart';

import 'package:horizon/presentation/shell/view/shell.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/shell/bloc/shell_state.dart';

import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/account_settings_repository.dart';

import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';

import 'package:horizon/presentation/shell/account_form/bloc/account_form_bloc.dart';
import 'package:horizon/presentation/screens/addresses/view/addresses_page.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_bloc.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_state.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_event.dart';
import 'package:horizon/presentation/screens/settings/view/settings_page.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import "package:horizon/presentation/screens/settings/bloc/password_prompt_bloc.dart";
import "package:horizon/presentation/screens/settings/bloc/password_prompt_state.dart";
import "package:horizon/presentation/screens/settings/bloc/password_prompt_event.dart";

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _sectionNavigatorKey = GlobalKey<NavigatorState>();

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({this.from, Key? key}) : super(key: key);
  final String? from;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
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
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child),
        ),
        GoRoute(
          path: "/onboarding",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: OnboardingScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child),
        ),
        GoRoute(
          path: "/onboarding/create",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: OnboardingCreateScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child),
        ),
        GoRoute(
          path: "/onboarding/import",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child:
                  OnboardingImportPage(), // TODO: be consistent with screen / page
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child),
        ),
        StatefulShellRoute.indexedStack(
            builder:
                (BuildContext context, GoRouterState state, navigationShell) {
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
                      // Address initialAddress =
                      //     (state.extra as Map<String, dynamic>)['initialAddress'];
                      Address initialAddress = const Address(
                          accountUuid: "76218sef-48fe-4f58-984c-b8fb5226e78a",
                          address: "tb1qmlykf0ej29ane2874y38c46kezr7jywrw6jqr9",
                          index: 0);
                      return ComposeSendPage(initialAddress: initialAddress);
                    })
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  path: "/compose/issuance",
                  builder: (context, state) {
                    // Retrieve the initial address from the extra parameter
                    // Address initialAddress =
                    //     (state.extra as Map<String, dynamic>)['initialAddress'];
                    Address initialAddress = const Address(
                        accountUuid: "76218sef-48fe-4f58-984c-b8fb5226e78a",
                        address: "tb1qmlykf0ej29ane2874y38c46kezr7jywrw6jqr9",
                        index: 0);
                    return ComposeIssuancePage(initialAddress: initialAddress);
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
                          orElse: () => SizedBox.shrink(),
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

        final path =  shell.state.maybeWhen(
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<PasswordPromptBloc>(
              create: (context) => PasswordPromptBloc(
                walletService: GetIt.I<WalletService>(),
                walletRepository: GetIt.I<WalletRepository>(),
                encryptionService: GetIt.I<EncryptionService>(),
              )),
          BlocProvider<ShellStateCubit>(
            create: (context) => ShellStateCubit(
                walletRepository: GetIt.I<WalletRepository>(),
                accountRepository: GetIt.I<AccountRepository>())
              ..initialize(),
          ),
          BlocProvider<AccountFormBloc>(create: (context) => AccountFormBloc()),
          // BlocProvider(
          //     create: (context) => AddressesBloc(
          //           walletRepository: GetIt.I<WalletRepository>(),
          //           accountRepository: GetIt.I<AccountRepository>(),
          //           addressService: GetIt.I<AddressService>(),
          //           addressRepository: GetIt.I<AddressRepository>(),
          //           encryptionService: GetIt.I<EncryptionService>(),
          //         ))
         
        ],
        child: BlocListener<ShellStateCubit, RemoteDataState<ShellState>>(
          listener: (context, state) {
            AppRouter.router.refresh();
          },
          child: MaterialApp.router(
            theme: ThemeData.light(useMaterial3: true),
            routeInformationParser: AppRouter.router.routeInformationParser,
            routerDelegate: AppRouter.router.routerDelegate,
            routeInformationProvider: AppRouter.router.routeInformationProvider,
          ),
        ));
  }
}
