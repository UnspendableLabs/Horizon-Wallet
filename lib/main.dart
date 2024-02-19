import 'package:counterparty_wallet/home_page.dart';
import 'package:counterparty_wallet/start_pages/create_wallet_dialog.dart';
import 'package:counterparty_wallet/start_pages/recover_wallet.dart';
import 'package:counterparty_wallet/wallet_pages/wallet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Read value

void main() {
  runApp(const MyApp());
} // GoRouter configuration

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/create_wallet',
      builder: (context, state) => const CreateWalletDialogueButton(),
    ),
    GoRoute(
      path: '/recover_wallet',
      builder: (context, state) => const RecoverWalletPage(),
    ),
    GoRoute(
      path: '/wallet',
      builder: (context, state) => const WalletPage(),
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
            primaryColor: Colors.blueAccent,
            colorScheme: const ColorScheme(
                primary: Colors.white,
                onPrimary: Color.fromRGBO(49, 49, 71, 1),
                secondary: Color.fromRGBO(86, 142, 96, 1),
                onSecondary: Colors.white,
                brightness: Brightness.dark,
                background: Colors.black,
                onBackground: Colors.white,
                error: Colors.red,
                onError: Colors.white,
                surface: Color.fromRGBO(49, 49, 71, 1),
                onSurface: Colors.white)));
  }
}
