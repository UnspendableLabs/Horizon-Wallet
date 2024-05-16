import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/counterparty_api/counterparty_api.dart';
import 'package:uniparty/services/bitcoind.dart';
import 'package:uniparty/services/blockcypher.dart';
import 'package:uniparty/services/key_value_store_service.dart';
import 'package:uniparty/services/seed_ops_service.dart';
import 'package:uniparty/services/bip39.dart' as bip39;

Future<void> setup() async {

  GetIt.I.registerSingleton<BitcoindService>(BitcoindServiceCounterpartyProxyImpl());
  GetIt.I.registerSingleton<BlockCypherService>(BlockCypherImpl(
    url: dotenv.env['BLOCKCYPHER_URL']!,
  ));

  GetIt.I.registerSingleton<KeyValueService>(SecureKeyValueImpl());
  GetIt.I.registerSingleton<bip39.Bip39Service>(bip39.Bip39JSService());
  GetIt.I.registerLazySingleton<SeedOpsService>(() => SeedOpsService());
  GetIt.I.registerLazySingleton<CounterpartyApi>(() => CounterpartyApi());


}