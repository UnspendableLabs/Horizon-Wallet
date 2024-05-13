import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/bitcoin_wallet_utils/bip39.dart';
import 'package:uniparty/counterparty_api/counterparty_api.dart';
import 'package:uniparty/services/bitcoind.dart';
import 'package:uniparty/services/blockcypher.dart';
import 'package:uniparty/services/key_value_store_service.dart';
import 'package:uniparty/services/seed_ops_service.dart';

Future<void> setup() async {

  GetIt.I.registerSingleton<BitcoindService>(BitcoindServiceHttpImpl(
    rpcUser: dotenv.env['RPC_USER']!,
    rpcPassword: dotenv.env['RPC_PASSWORD']!,
    rpcUrl: dotenv.env['RPC_URL']!,
  ));
  GetIt.I.registerSingleton<BlockCypherService>(BlockCypherImpl(
    url: dotenv.env['BLOCKCYPHER_URL']!,
  ));

  GetIt.I.registerSingleton<KeyValueService>(SecureKeyValueImpl());
  GetIt.I.registerSingleton<Bip39Service>(Bip39Impl());
  GetIt.I.registerLazySingleton<SeedOpsService>(() => SeedOpsService());
  GetIt.I.registerLazySingleton<CounterpartyApi>(() => CounterpartyApi());
}
