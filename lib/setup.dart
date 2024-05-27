import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/counterparty_api/counterparty_api.dart';
import 'package:uniparty/data/services/address_service_impl.dart' as addy_service_impl;
import 'package:uniparty/data/services/encryption_service_impl.dart';
import 'package:uniparty/data/services/mnemonic_service_impl.dart';
import 'package:uniparty/data/services/wallet_service_impl.dart';
import 'package:uniparty/data/sources/local/db.dart';
import 'package:uniparty/data/sources/local/db_manager.dart';
import 'package:uniparty/data/sources/repositories/account_repository_impl.dart';
import 'package:uniparty/data/sources/repositories/address_repository_impl.dart';
import 'package:uniparty/data/sources/repositories/wallet_repository_impl.dart';
import 'package:uniparty/domain/repositories/account_repository.dart';
import 'package:uniparty/domain/repositories/address_repository.dart';
import 'package:uniparty/domain/repositories/wallet_repository.dart';
import 'package:uniparty/domain/services/address_service.dart' as addy_service;
import 'package:uniparty/domain/services/encryption_service.dart';
import 'package:uniparty/domain/services/mnemonic_service.dart';
import 'package:uniparty/domain/services/wallet_service.dart';
import 'package:uniparty/services/bech32.dart' as bech32;
import 'package:uniparty/services/bip32.dart' as bip32;
import 'package:uniparty/services/bip39.dart' as bip39;
import 'package:uniparty/services/bitcoind.dart';
import 'package:uniparty/services/blockcypher.dart';
import 'package:uniparty/services/ecpair.dart' as ecpair;
import 'package:uniparty/services/key_value_store_service.dart';
import 'package:uniparty/services/seed_ops_service.dart';

Future<void> setup() async {
  GetIt injector = GetIt.I;

  injector.registerSingleton<BitcoindService>(BitcoindServiceCounterpartyProxyImpl());
  injector.registerSingleton<BlockCypherService>(BlockCypherImpl(
    url: dotenv.env['BLOCKCYPHER_URL']!,
  ));

  injector.registerSingleton<KeyValueService>(SecureKeyValueImpl());
  injector.registerSingleton<bip39.Bip39Service>(bip39.Bip39JSService());
  injector.registerSingleton<bech32.Bech32Service>(bech32.Bech32JSService());
  injector.registerSingleton<ecpair.ECPairService>(ecpair.ECPairJSService());
  injector.registerLazySingleton<SeedOpsService>(() => SeedOpsService());
  injector.registerLazySingleton<CounterpartyApi>(() => CounterpartyApi());

  injector.registerSingleton<bip32.Bip32Service>(bip32.Bip32JSService());

  injector.registerSingleton<addy_service.AddressService>(addy_service_impl.AddressServiceImpl());

  injector.registerSingleton<EncryptionService>(EncryptionServiceImpl());
  injector.registerSingleton<MnemonicService>(MnemonicServiceImpl(injector()));

  injector.registerSingleton<WalletService>(WalletServiceImpl(injector()));

  injector.registerSingleton<DatabaseManager>(DatabaseManager());

  injector.registerSingleton<AccountRepository>(AccountRepositoryImpl(injector.get<DatabaseManager>().database));
  injector.registerSingleton<WalletRepository>(WalletRepositoryImpl(injector.get<DatabaseManager>().database));
  injector.registerSingleton<AddressRepository>(AddressRepositoryImpl(injector.get<DatabaseManager>().database));
}
