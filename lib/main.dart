import 'package:counterparty_wallet/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const appTitle = 'Counterparty Wallet';

    return MaterialApp.router(
        routerConfig: AppRouter().router,
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
