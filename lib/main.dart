import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uniparty/bloc/data_bloc.dart';
import 'package:uniparty/home_page.dart';

void main() async {
  await dotenv.load();
  // run the application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const appTitle = 'Uniparty';
    // fire off the initial dispatch; this will see if the seedHex and walletType are already in secure storage and set the state

    return MaterialApp(
        title: appTitle,
        home: BlocProvider(
          create: (context) => DataBloc(),
          child: const HomePage(),
        ),
        theme: ThemeData(
            primaryColor: Colors.blueAccent,
            colorScheme: const ColorScheme(
                primary: Colors.white,
                onPrimary: Color.fromRGBO(49, 49, 71, 1),
                secondary: Color.fromRGBO(159, 194, 244, 1.0),
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
