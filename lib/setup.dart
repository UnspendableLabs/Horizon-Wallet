import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/counterparty_api/counterparty_api.dart';
import 'package:horizon/data/services/address_service_impl.dart' as addy_service_impl;
import 'package:horizon/data/services/encryption_service_impl.dart';
import 'package:horizon/data/services/mnemonic_service_impl.dart';
import 'package:horizon/data/services/wallet_service_impl.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/data/sources/local/db_manager.dart';
import 'package:horizon/data/sources/repositories/account_repository_impl.dart';
import 'package:horizon/data/sources/repositories/address_repository_impl.dart';
import 'package:horizon/data/sources/repositories/wallet_repository_impl.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart' as addy_service;
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/services/bech32.dart' as bech32;
import 'package:horizon/services/bip32.dart' as bip32;
import 'package:horizon/services/bip39.dart' as bip39;
import 'package:horizon/services/bitcoind.dart';
import 'package:horizon/services/blockcypher.dart';
import 'package:horizon/services/ecpair.dart' as ecpair;
import 'package:horizon/services/key_value_store_service.dart';
import 'package:horizon/services/seed_ops_service.dart';

final database = DB();

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
  injector.registerSingleton<MnemonicService>(MnemonicServiceImpl(GetIt.I.get<bip39.Bip39Service>()));

  injector.registerSingleton<WalletService>(WalletServiceImpl(GetIt.I.get<EncryptionService>()));

  injector.registerSingleton<DatabaseManager>(DatabaseManager());

  injector.registerSingleton<AccountRepository>(AccountRepositoryImpl(injector.get<DatabaseManager>().database));
  injector.registerSingleton<WalletRepository>(WalletRepositoryImpl(injector.get<DatabaseManager>().database));
  injector.registerSingleton<AddressRepository>(AddressRepositoryImpl(injector.get<DatabaseManager>().database));
}
