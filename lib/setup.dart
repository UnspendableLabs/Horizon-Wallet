import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/api/dio_client.dart';
import 'package:horizon/api/v2_api.dart';
import 'package:horizon/data/services/address_service_impl.dart';
import 'package:horizon/data/services/bip39_service_impl.dart';
import 'package:horizon/data/services/bitcoind_service_impl.dart';
import 'package:horizon/data/services/ecpair_service_impl.dart';
import 'package:horizon/data/services/encryption_service_impl.dart';
import 'package:horizon/data/services/mnemonic_service_impl.dart';
import 'package:horizon/data/services/transaction_service_impl.dart';
import 'package:horizon/data/services/wallet_service_impl.dart';
import 'package:horizon/data/sources/local/db_manager.dart';
import 'package:horizon/data/sources/repositories/account_repository_impl.dart';
import 'package:horizon/data/sources/repositories/address_repository_impl.dart';
import 'package:horizon/data/sources/repositories/wallet_repository_impl.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bip39.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/ecpair_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';

void setup() {
  GetIt injector = GetIt.I;

  // injector.registerSingleton<BlockCypherService>(BlockCypherImpl(
  //   url: dotenv.env['BLOCKCYPHER_URL']!,
  // ));
  // injector.registerLazySingleton<CounterpartyApi>(() => CounterpartyApi());
  injector.registerLazySingleton<Dio>(() => buildDioClient());
  injector.registerLazySingleton<V2Api>(() => V2Api(GetIt.I.get<Dio>()));
  injector.registerSingleton<Bip39Service>(Bip39ServiceImpl());
  // injector.registerSingleton<bech32.Bech32Service>(bech32.Bech32JSService());
  injector.registerSingleton<BitcoindService>(BitcoindServiceCounterpartyProxyImpl());
  injector.registerSingleton<ECPairService>(ECPairServiceImpl());
  injector.registerSingleton<TransactionService>(TransactionServiceImpl(GetIt.I.get<ECPairService>()));
  // injector.registerLazySingleton<SeedOpsService>(() => SeedOpsService());
  // injector.registerLazySingleton<CounterpartyApi>(() => CounterpartyApi());

  // injector.registerSingleton<bip32.Bip32Service>(bip32.Bip32JSService());

  injector.registerSingleton<AddressService>(AddressServiceImpl());

  injector.registerSingleton<EncryptionService>(EncryptionServiceImpl());
  injector.registerSingleton<MnemonicService>(MnemonicServiceImpl(GetIt.I.get<Bip39Service>()));

  injector.registerSingleton<WalletService>(WalletServiceImpl(GetIt.I.get<EncryptionService>()));

  injector.registerSingleton<DatabaseManager>(DatabaseManager());

  injector.registerSingleton<AccountRepository>(AccountRepositoryImpl(injector.get<DatabaseManager>().database));
  injector.registerSingleton<WalletRepository>(WalletRepositoryImpl(injector.get<DatabaseManager>().database));
  injector.registerSingleton<AddressRepository>(AddressRepositoryImpl(injector.get<DatabaseManager>().database));
}
