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
import 'package:horizon/presentation/screens/compose_issuance/view/compose_issuance_page.dart';
import 'package:horizon/presentation/screens/compose_send/view/compose_send_page.dart';
import 'package:horizon/presentation/screens/dashboard/view/dashboard_page.dart';
import 'package:horizon/presentation/screens/onboarding/view/onboarding_page.dart';
import 'package:horizon/presentation/screens/onboarding_create/view/onboarding_create_page.dart';
import 'package:horizon/presentation/screens/onboarding_import/view/onboarding_import_page.dart';
import 'package:horizon/setup.dart';
import 'package:logger/logger.dart';

import 'package:horizon/presentation/shell/view/shell.dart';
import 'package:horizon/presentation/shell/bloc/shell_bloc.dart';

import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/account_repository.dart';

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
              Text('loading repository...'),
            ],
          ),
        ),
      );
}

abstract class AppRouter {
  static GoRouter router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: "/",
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
                    pageBuilder: (context, state) => CustomTransitionPage<void>(
                        key: state.pageKey,
                        child: DashboardPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) =>
                                child),
                  ),
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
                    }

                    // builder: (context, state) =>  {
                    //   Address initialAddress = const Address(
                    //       accountUuid: "76218sef-48fe-4f58-984c-b8fb5226e78a",
                    //       address: "tb1qmlykf0ej29ane2874y38c46kezr7jywrw6jqr9",
                    //       index: 0
                    //       );
                    //
                    //   return  ComposeSendPage(initialAddress: initialAddress);
                    //
                    // }
                    // pageBuilder: (context, state) {
                    // Retrieve the initial address from the extra parameter
                    // Address initialAddress =
                    //     (state.extra as Map<String, dynamic>)['initialAddress'];

                    // return CustomTransitionPage<void>(
                    //   child: Text("foo"),
                    //   transitionsBuilder:
                    //       (context, animation, secondaryAnimation, child) =>
                    //           child,
                    // );
                    // },
                    )
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
            ])
      ],
      redirect: (context, state) async {
        final status = context.read<ShellBloc>().state.status;

        if (status == Status.success) {
          return "/dashboard";
        }

        if( status == Status.error ) {
          return "/onboarding";
        }

        return null;
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

    runApp(MyApp());
  }, (Object error, StackTrace stackTrace) {
    logger.e({'error': error.toString(), 'stackTrace': stackTrace.toString()});
    // Log the error to a service or handle it accordingly
  });
}

class MyApp extends StatelessWidget {
  MyApp({
    super.key,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => ShellBloc(
            walletRepository: GetIt.I<WalletRepository>(),
            accountRepository: GetIt.I<AccountRepository>())
          ..add(const ShellEvent.init()),
        child: BlocListener<ShellBloc, ShellState>(
          listener: (context, state) {
            AppRouter.router.refresh();
          },
          child: MaterialApp.router(
            routeInformationParser: AppRouter.router.routeInformationParser,
            routerDelegate: AppRouter.router.routerDelegate,
            routeInformationProvider: AppRouter.router.routeInformationProvider,
          ),
        ));
  }
}
