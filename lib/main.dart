import 'package:counterparty_wallet/create_wallet.dart';
import 'package:counterparty_wallet/home_page.dart';
import 'package:counterparty_wallet/recover_wallet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
} // GoRouter configuration

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/create_wallet',
      builder: (context, state) => const CreateWalletPage(),
    ),
    GoRoute(
      path: '/recover_wallet',
      builder: (context, state) => const RecoverWalletPage(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const appTitle = 'Counterparty Wallet';

    return MaterialApp.router(
      routerConfig: _router,
      title: appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
    );
  }
}
