import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/app_router.dart';
import 'package:uniparty/bitcoin_wallet_utils/bip39.dart';
import 'package:uniparty/counterparty_api/counterparty_api.dart';
import 'package:uniparty/services/bitcoind.dart';
import 'package:uniparty/services/key_value_store_service.dart';
import 'package:uniparty/services/seed_ops_service.dart';

void main() async {
  await dotenv.load();

  GetIt.I.registerSingleton<KeyValueService>(SecureKeyValueImpl());
  GetIt.I.registerSingleton<Bip39Service>(Bip39Impl());
  GetIt.I.registerLazySingleton<SeedOpsService>(() => SeedOpsService());
  GetIt.I.registerLazySingleton<CounterpartyApi>(() => CounterpartyApi());

  //TODO: inject correct network
  GetIt.I.registerSingleton<BitcoindService>(
      BitcoindServiceHttpImpl(rpcUser: 'rpc', rpcPassword: 'rpc', rpcUrl: 'https://api.counterparty.io/18332/'));

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
        initialRoute: AppRouter.onboardingPage,
        onGenerateRoute: AppRouter.onGenerateRoute,
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
