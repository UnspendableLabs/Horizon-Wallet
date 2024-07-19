import 'package:dio/dio.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/data/services/address_service_impl.dart';
import 'package:horizon/data/services/bip39_service_impl.dart';
import 'package:horizon/data/services/bitcoind_service_impl.dart';
import 'package:horizon/data/services/cache_provider_impl.dart';
import 'package:horizon/data/services/encryption_service_impl.dart';
import 'package:horizon/data/services/mnemonic_service_impl.dart';
import 'package:horizon/data/services/transaction_service_impl.dart';
import 'package:horizon/data/services/wallet_service_impl.dart';
import 'package:horizon/data/sources/local/db_manager.dart';
import 'package:horizon/data/sources/network/api/dio_client.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/data/sources/repositories/account_repository_impl.dart';
import 'package:horizon/data/sources/repositories/account_settings_repository_impl.dart';
import 'package:horizon/data/sources/repositories/address_repository_impl.dart';
import 'package:horizon/data/sources/repositories/address_tx_repository_impl.dart';
import 'package:horizon/data/sources/repositories/balance_repository_impl.dart';
import 'package:horizon/data/sources/repositories/compose_repository_impl.dart';
import 'package:horizon/data/sources/repositories/materialized_address_repository_impl.dart';
import 'package:horizon/data/sources/repositories/utxo_repository_impl.dart';
import 'package:horizon/data/sources/repositories/wallet_repository_impl.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/account_settings_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/address_tx_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/materialized_address_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bip39.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';

import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/data/sources/repositories/asset_repository_impl.dart';

import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/data/sources/repositories/transaction_repository_impl.dart';

Future<void> setup() async {
  GetIt injector = GetIt.I;

  injector.registerLazySingleton<Dio>(() => buildDioClient());
  injector.registerLazySingleton<V2Api>(() => V2Api(GetIt.I.get<Dio>()));

  injector.registerSingleton<AddressTxRepository>(
      AddressTxRepositoryImpl(api: GetIt.I.get<V2Api>()));
  injector.registerSingleton<ComposeRepository>(
      ComposeRepositoryImpl(api: GetIt.I.get<V2Api>()));
  injector.registerSingleton<UtxoRepository>(
      UtxoRepositoryImpl(api: GetIt.I.get<V2Api>()));
  injector.registerSingleton<BalanceRepository>(BalanceRepositoryImpl(
      api: GetIt.I.get<V2Api>(),
      utxoRepository: GetIt.I.get<UtxoRepository>()));

  injector.registerSingleton<AssetRepository>(
      AssetRepositoryImpl(api: GetIt.I.get<V2Api>()));

  injector.registerSingleton<TransactionRepository>(
      TransactionRepositoryImpl(api: GetIt.I.get<V2Api>()));

    


  injector.registerSingleton<Bip39Service>(Bip39ServiceImpl());
  injector.registerSingleton<TransactionService>(TransactionServiceImpl());
  injector.registerSingleton<EncryptionService>(EncryptionServiceImpl());
  injector.registerSingleton<WalletService>(WalletServiceImpl(injector()));
  injector.registerSingleton<AddressService>(AddressServiceImpl());
  injector.registerSingleton<MnemonicService>(
      MnemonicServiceImpl(GetIt.I.get<Bip39Service>()));
  injector.registerSingleton<BitcoindService>(
      BitcoindServiceCounterpartyProxyImpl(GetIt.I.get<V2Api>()));
  injector.registerSingleton<DatabaseManager>(DatabaseManager());
  injector.registerSingleton<AccountRepository>(
      AccountRepositoryImpl(injector.get<DatabaseManager>().database));
  injector.registerSingleton<WalletRepository>(
      WalletRepositoryImpl(injector.get<DatabaseManager>().database));
  injector.registerSingleton<AddressRepository>(
      AddressRepositoryImpl(injector.get<DatabaseManager>().database));

  injector.registerSingleton<CacheProvider>(HiveCache());

  injector.registerSingleton<AccountSettingsRepository>(
      AccountSettingsRepositoryImpl(
    cacheProvider: GetIt.I.get<CacheProvider>(),
  ));

  injector.registerSingleton<MaterializedAddressRepository>(
      MaterializedAddressRepositoryImpl());
}
