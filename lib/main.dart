import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:uniparty/app_router.dart';
import 'package:uniparty/redux/app_store.dart';
import 'package:uniparty/redux/reducers.dart';

void main() async {
  await dotenv.load();

  final store = Store<AppState>(appReducer,
      initialState: AppState.initial(), middleware: [thunkMiddleware]);
  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;
  const MyApp({
    required this.store,
    super.key,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const appTitle = 'Uniparty';
    return StoreProvider(
        store: store,
        child: MaterialApp.router(
            routerConfig: AppRouter().router,
            title: appTitle,
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
                    onSurface: Colors.white))));
  }
}
