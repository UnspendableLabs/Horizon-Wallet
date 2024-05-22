import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:uniparty/app_router.dart';
import 'package:uniparty/setup.dart';
import 'package:uniparty/presentation/screens/onboarding/view/onboarding_page.dart';
import 'package:uniparty/presentation/screens/onboarding_create/view/onboarding_create_page.dart';
import 'package:uniparty/presentation/screens/onboarding_import/view/onboarding_import_page.dart';
import 'package:drift_db_viewer/drift_db_viewer.dart';

final GoRouter router =
    GoRouter(initialLocation: "/onboarding", routes: <RouteBase>[
  GoRoute(
    path: "/db",
    pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: DriftDbViewer(database),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            child),
  ),
  GoRoute(
    path: "/onboarding",
    pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            child),
  ),
  GoRoute(
    path: "/onboarding/create",
    pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const OnboardingCreateScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            child),
  ),
  GoRoute(
    path: "/onboarding/import",
    pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: OnboardingImportPage(), // TODO: be consistent with screen / page
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            child),
  )
]);

void main() async {
  await dotenv.load();

  await setup();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );

    // const appTitle = 'Uniparty';
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
