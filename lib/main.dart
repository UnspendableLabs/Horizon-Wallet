import 'dart:async';

import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/data/sources/local/db_manager.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/presentation/screens/compose_send/view/compose_send_page.dart';
import 'package:horizon/presentation/screens/dashboard/view/dashboard_page.dart';
import 'package:horizon/presentation/screens/onboarding/view/onboarding_page.dart';
import 'package:horizon/presentation/screens/onboarding_create/view/onboarding_create_page.dart';
import 'package:horizon/presentation/screens/onboarding_import/view/onboarding_import_page.dart';
import 'package:horizon/setup.dart';
import 'package:logger/logger.dart';

GoRouter router = GoRouter(initialLocation: "/onboarding", routes: <RouteBase>[
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
        child: OnboardingCreateScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => child),
  ),
  GoRoute(
    path: "/onboarding/import",
    pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: OnboardingImportPage(), // TODO: be consistent with screen / page
        transitionsBuilder: (context, animation, secondaryAnimation, child) => child),
  ),
  GoRoute(
    path: "/dashboard",
    pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: DashboardPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => child),
  ),
  GoRoute(
    path: "/compose/send",
    pageBuilder: (context, state) {
      // Retrieve the initial address from the extra parameter
      Address initialAddress = (state.extra as Map<String, dynamic>)['initialAddress'];
      return CustomTransitionPage<void>(
        key: state.pageKey,
        child: ComposeSendPage(initialAddress: initialAddress),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
      );
    },
  ),
]);

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

    setup();

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
    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primaryColor: Colors.blueAccent,
      ),
    );

    // const appTitle = 'Horizon';
    // fire off the initial dispatch; this will see if the seedHex and walletType are already in secure storage and set the state
    //
    //   return MaterialApp(
    //       title: appTitle,
    //       initialRoute: AppRouter.onboardingPage,
    //       onGenerateRoute: AppRouter.onGenerateRoute,
    //       theme: ThemeData(
    //           fontFamily: 'Open Sans',
    //           primaryColor: Colors.blueAccent,
    //           colorScheme: const ColorScheme(
    //               primary: Colors.white,
    //               onPrimary: Color.fromRGBO(49, 49, 71, 1),
    //               secondary: Color.fromRGBO(159, 194, 244, 1.0),
    //               onSecondary: Colors.white,
    //               brightness: Brightness.dark,
    //               background: Colors.black,
    //               onBackground: Colors.white,
    //               error: Colors.red,
    //               onError: Colors.white,
    //               surface: Color.fromRGBO(49, 49, 71, 1),
    //               onSurface: Colors.white)));
    //
  }
}
