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
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/data/sources/repositories/account_repository_impl.dart';
import 'package:horizon/data/sources/repositories/account_settings_repository_impl.dart';
import 'package:horizon/data/sources/repositories/address_repository_impl.dart';
import 'package:horizon/data/sources/repositories/address_tx_repository_impl.dart';
import 'package:horizon/data/sources/repositories/balance_repository_impl.dart';
import 'package:horizon/data/sources/repositories/compose_repository_impl.dart';
import 'package:horizon/data/sources/repositories/utxo_repository_impl.dart';
import 'package:horizon/data/sources/repositories/wallet_repository_impl.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/account_settings_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/address_tx_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
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
import 'package:horizon/data/sources/local/dao/transactions_dao.dart';

import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/data/sources/repositories/transaction_local_repository_impl.dart';

import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/data/sources/repositories/events_repository_impl.dart';

import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/data/sources/repositories/bitcoin_repository_impl.dart';

import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/data/sources/repositories/config_repository_impl.dart';

Future<void> setup() async {
  GetIt injector = GetIt.I;

  Config config = EnvironmentConfig();

  injector.registerLazySingleton<Config>(() => config);

  final dio = Dio(BaseOptions(
    baseUrl: config.counterpartyApiBase,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  dio.interceptors.addAll([
    TimeoutInterceptor(),
    ConnectionErrorInterceptor(),
    BadResponseInterceptor(),
    BadCertificateInterceptor()
  ]);

  injector.registerLazySingleton<V2Api>(() => V2Api(dio));

  injector.registerSingleton<BitcoinRepository>(BitcoinRepositoryImpl(
      esploraApi: EsploraApi(
          dio: Dio(BaseOptions(
    baseUrl: config.esploraBase,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  )))));

  injector.registerSingleton<DatabaseManager>(DatabaseManager());

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

  injector.registerSingleton<Bip39Service>(Bip39ServiceImpl());
  injector.registerSingleton<TransactionService>(
      TransactionServiceImpl(config: config));
  injector.registerSingleton<EncryptionService>(EncryptionServiceImpl());
  injector
      .registerSingleton<WalletService>(WalletServiceImpl(injector(), config));
  injector
      .registerSingleton<AddressService>(AddressServiceImpl(config: config));
  injector.registerSingleton<MnemonicService>(
      MnemonicServiceImpl(GetIt.I.get<Bip39Service>()));
  injector.registerSingleton<BitcoindService>(
      BitcoindServiceCounterpartyProxyImpl(GetIt.I.get<V2Api>()));
  injector.registerSingleton<AccountRepository>(
      AccountRepositoryImpl(injector.get<DatabaseManager>().database));
  injector.registerSingleton<WalletRepository>(
      WalletRepositoryImpl(injector.get<DatabaseManager>().database));
  injector.registerSingleton<AddressRepository>(
      AddressRepositoryImpl(injector.get<DatabaseManager>().database));

  injector.registerSingleton<EventsRepository>(
      EventsRepositoryImpl(api_: GetIt.I.get<V2Api>()));

  injector.registerSingleton<TransactionRepository>(TransactionRepositoryImpl(
    addressRepository: GetIt.I.get<AddressRepository>(),
    api_: GetIt.I.get<V2Api>(),
  ));

  injector.registerSingleton<TransactionLocalRepository>(
      TransactionLocalRepositoryImpl(
          addressRepository: GetIt.I.get<AddressRepository>(),
          api_: GetIt.I.get<V2Api>(),
          transactionDao:
              TransactionsDao(injector.get<DatabaseManager>().database)));

  injector.registerSingleton<CacheProvider>(HiveCache());

  injector.registerSingleton<AccountSettingsRepository>(
      AccountSettingsRepositoryImpl(
    cacheProvider: GetIt.I.get<CacheProvider>(),
  ));
}

class CustomDioException extends DioException {
  CustomDioException({
    required super.requestOptions,
    required String super.error,
    required super.type,
  });

  @override
  String toString() {
    return error.toString();
  }
}

class TimeoutInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      final requestPath = err.requestOptions.uri.toString();
      final timeoutDuration =
          err.requestOptions.connectTimeout ?? const Duration(seconds: 5);
      final formattedError = CustomDioException(
        requestOptions: err.requestOptions,
        error:
            'Timeout (${timeoutDuration.inSeconds}s) — Request Failed $requestPath',
        type: DioExceptionType.connectionTimeout,
      );
      handler.next(formattedError);
    } else {
      handler.next(err);
    }
  }
}

class ConnectionErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      final requestPath = err.requestOptions.uri.toString();
      final formattedError = CustomDioException(
        requestOptions: err.requestOptions,
        error: 'Connection Error — Request Failed $requestPath',
        type: DioExceptionType.connectionError,
      );
      handler.next(formattedError);
    } else {
      handler.next(err);
    }
  }
}

class BadResponseInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.badResponse) {
      final requestPath = err.requestOptions.uri.toString();
      final formattedError = CustomDioException(
        requestOptions: err.requestOptions,
        error: 'Bad Response — Request Failed $requestPath',
        type: DioExceptionType.badResponse,
      );
      handler.next(formattedError);
    } else {
      handler.next(err);
    }
  }
}

class BadCertificateInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.badCertificate) {
      final requestPath = err.requestOptions.uri.toString();
      final formattedError = CustomDioException(
        requestOptions: err.requestOptions,
        error: 'Bad Certificate — Request Failed $requestPath',
        type: DioExceptionType.badCertificate,
      );
      handler.next(formattedError);
    } else {
      handler.next(err);
    }
  }
}
