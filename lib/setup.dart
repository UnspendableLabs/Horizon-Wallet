import 'package:dio/dio.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/data/services/address_service_impl.dart';
import 'package:horizon/data/services/bip39_service_impl.dart';
import 'package:horizon/data/services/bitcoind_service_impl.dart';
import 'package:horizon/data/services/cache_provider_impl.dart';
import 'package:horizon/data/services/encryption_service_web_worker_impl.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:horizon/data/services/imported_address_service_impl.dart';
import 'package:chrome_extension/tabs.dart';
import 'package:horizon/data/services/platform_service_extension_impl.dart';
import 'package:horizon/data/services/platform_service_web_impl.dart';
import "package:horizon/data/sources/repositories/address_repository_impl.dart";
import "package:horizon/domain/repositories/address_repository.dart";
import 'package:horizon/data/sources/local/db_manager.dart';

import 'package:horizon/data/services/mnemonic_service_impl.dart';
import 'package:horizon/data/services/transaction_service_impl.dart';
import 'package:horizon/data/services/wallet_service_impl.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/data/sources/repositories/account_repository_impl.dart';
import 'package:horizon/data/sources/repositories/account_settings_repository_impl.dart';
import 'package:horizon/data/sources/repositories/address_tx_repository_impl.dart';
import 'package:horizon/data/sources/repositories/balance_repository_impl.dart';
import 'package:horizon/data/sources/repositories/block_repository_impl.dart';
import 'package:horizon/data/sources/repositories/compose_repository_impl.dart';
import 'package:horizon/data/sources/repositories/fairminter_repository_impl.dart';
import 'package:horizon/data/sources/repositories/imported_address_repository_impl.dart';
import 'package:horizon/data/sources/repositories/node_info_repository_impl.dart';
import 'package:horizon/data/sources/repositories/utxo_repository_impl.dart';
import 'package:horizon/data/sources/repositories/wallet_repository_impl.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/account_settings_repository.dart';
import 'package:horizon/domain/repositories/address_tx_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/block_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/fairminter_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/node_info_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bip39.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/platform_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';

import 'package:horizon/domain/services/public_key_service.dart';
import 'package:horizon/data/services/public_key_service_impl.dart';

import 'package:horizon/domain/repositories/version_repository.dart';
import 'package:horizon/data/sources/repositories/version_repository_impl.dart';
import 'package:horizon/data/sources/repositories/version_repository_extension_impl.dart';

import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/data/sources/repositories/asset_repository_impl.dart';

import 'package:horizon/domain/repositories/order_repository.dart';
import 'package:horizon/data/sources/repositories/order_repository_impl.dart';

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

import 'package:horizon/domain/repositories/action_repository.dart';
import 'package:horizon/data/sources/repositories/action_repository_impl.dart';

import 'package:horizon/domain/repositories/dispenser_repository.dart';
import 'package:horizon/data/sources/repositories/dispenser_repository_impl.dart';

import "package:horizon/domain/repositories/fee_estimates_repository.dart";
import 'package:horizon/data/sources/repositories/fee_estimates_repository_mempool_space_impl.dart';

import 'package:horizon/data/sources/network/esplora_client.dart';
import 'package:horizon/data/sources/network/mempool_space_client.dart';

import 'package:horizon/domain/repositories/unified_address_repository.dart';
import 'package:horizon/data/sources/repositories/unified_address_repository_impl.dart';

import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/data/services/analytics_service_impl.dart';
import 'package:horizon/presentation/common/usecase/import_wallet_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_chained_transaction_usecase.dart';
import 'package:horizon/presentation/screens/close_dispenser/usecase/fetch_form_data.dart';

import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/get_virtual_size_usecase.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/compose_dispenser/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/fetch_open_dispensers_on_address.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/estimate_dispenses.dart';
import 'package:horizon/presentation/screens/compose_fairmint/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/compose_fairminter/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/compose_issuance/usecase/fetch_form_data.dart';

import 'package:logger/logger.dart' as logger;
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/data/logging/logger_impl.dart';
import 'package:horizon/domain/entities/extension_rpc.dart';
import 'package:horizon/domain/entities/address_rpc.dart';
import 'dart:convert';

// will need to move this import elsewhere for compile to native
import 'dart:html' as html;

import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/data/services/error_service_impl.dart';

Future<void> setup() async {
  GetIt injector = GetIt.I;

  injector.registerSingleton<Logger>(LoggerImpl(
    logger.Logger(
      filter: logger.ProductionFilter(),
      printer: logger.PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 120,
        colors: false,
        printEmojis: false,
        printTime: true,
      ),
      output: logger.ConsoleOutput(),
    ),
  ));

  Config config = ConfigImpl();

  injector.registerLazySingleton<Config>(() => config);

  final dio = Dio(BaseOptions(
    baseUrl: config.counterpartyApiBase,
    headers: {
      'Content-Type': 'application/json',
    },
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  // Add basic auth interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      String username = config.counterpartyApiUsername;
      String password = config.counterpartyApiPassword;
      String basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      options.headers['Authorization'] = basicAuth;
      return handler.next(options);
    },
  ));

  dio.interceptors.addAll([
    // RetryInterceptor(dio: dio, maxRetries: 3, initialDelayMs: 500),
    TimeoutInterceptor(),
    ConnectionErrorInterceptor(),
    BadResponseInterceptor(),
    BadCertificateInterceptor(),
    SimpleLogInterceptor(),
    RetryInterceptor(
      dio: dio, retries: 3,
      retryableExtraStatuses: {400}, // to handle backend bug with compose
      retryDelays: const [
        // set delays between retries (optional)
        Duration(seconds: 1), // wait 1 sec before first retry
        Duration(seconds: 1), // wait 2 sec before second retry
        Duration(seconds: 1), // wait 3 sec before third retry
      ],
    ), // Add the RetryInterceptor here
  ]);

  injector.registerLazySingleton<V2Api>(() => V2Api(dio));

  final esploraDio = Dio(BaseOptions(
    baseUrl: config.esploraBase,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  esploraDio.interceptors.addAll([
    TimeoutInterceptor(),
    ConnectionErrorInterceptor(),
    BadResponseInterceptor(),
    BadCertificateInterceptor(),
    SimpleLogInterceptor(),
    RetryInterceptor(
      dio: dio,
      retries: 4,
      retryDelays: const [
        Duration(seconds: 1), // wait 1 sec before first retry
        Duration(seconds: 2), // wait 2 sec before second retry
        Duration(seconds: 3), // wait 3 sec before third retry
        Duration(seconds: 5), // wait 3 sec before third retryh
      ],
    ), // Add the RetryInterceptor here
  ]);

  final mempoolspaceDio = Dio(BaseOptions(
    baseUrl: config.esploraBase,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  mempoolspaceDio.interceptors.addAll([
    RetryInterceptor(
      dio: mempoolspaceDio,
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1), // wait 1 sec before first retry
        Duration(seconds: 1), // wait 2 sec before second retry
        Duration(seconds: 1), // wait 3 sec before third retry
      ],
    ), // Add the RetryInterceptor here
  ]);

//   final blockCypherDio = Dio(BaseOptions(
//       baseUrl: config.blockCypherBase,
//       connectTimeout: const Duration(seconds: 5),
//       receiveTimeout: const Duration(seconds: 5)));
//
//
//   blockCypherDio.interceptors.add(InterceptorsWrapper(
//   onRequest: (options, handler) {
//     // Add the API key to all requests
//     options.queryParameters['token'] = <key>;
//     return handler.next(options);
//   },
// ));

  injector.registerSingleton<AnalyticsService>(PostHogWebAnalyticsService(
    config,
    const String.fromEnvironment('HORIZON_POSTHOG_API_KEY').isNotEmpty
        ? const String.fromEnvironment('HORIZON_POSTHOG_API_KEY')
        : null,
    const String.fromEnvironment('HORIZON_POSTHOG_API_HOST').isNotEmpty
        ? const String.fromEnvironment('HORIZON_POSTHOG_API_HOST')
        : null,
    GetIt.I.get<Logger>(),
  ));

  injector.registerSingleton<BitcoinRepository>(BitcoinRepositoryImpl(
    esploraApi: EsploraApi(dio: esploraDio),
    // blockCypherApi: BlockCypherApi(dio: blockCypherDio)
  ));

  injector.registerSingleton<CacheProvider>(HiveCache());

  injector.registerSingleton<DatabaseManager>(DatabaseManager());

  injector.registerSingleton<AddressTxRepository>(
      AddressTxRepositoryImpl(api: GetIt.I.get<V2Api>()));
  injector.registerSingleton<ComposeRepository>(
      ComposeRepositoryImpl(api: GetIt.I.get<V2Api>()));
  injector.registerSingleton<UtxoRepository>(UtxoRepositoryImpl(
      api: GetIt.I.get<V2Api>(),
      esploraApi: EsploraApi(dio: esploraDio),
      cacheProvider: GetIt.I.get<CacheProvider>()));
  injector.registerSingleton<BalanceRepository>(BalanceRepositoryImpl(
      api: GetIt.I.get<V2Api>(),
      utxoRepository: GetIt.I.get<UtxoRepository>(),
      bitcoinRepository: GetIt.I.get<BitcoinRepository>()));

  injector.registerSingleton<BlockRepository>(
      BlockRepositoryImpl(GetIt.I.get<V2Api>()));

  injector.registerSingleton<AssetRepository>(
      AssetRepositoryImpl(api: GetIt.I.get<V2Api>()));

  injector.registerSingleton<Bip39Service>(Bip39ServiceImpl());
  injector.registerSingleton<TransactionService>(
      TransactionServiceImpl(config: config));
  injector
      .registerSingleton<EncryptionService>(EncryptionServiceWebWorkerImpl());
  injector
      .registerSingleton<WalletService>(WalletServiceImpl(injector(), config));
  injector
      .registerSingleton<AddressService>(AddressServiceImpl(config: config));

  injector.registerSingleton<ImportedAddressService>(
      ImportedAddressServiceImpl(config: config));
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
  injector.registerSingleton<ImportedAddressRepository>(
      ImportedAddressRepositoryImpl(injector.get<DatabaseManager>().database));

  injector.registerSingleton<UnifiedAddressRepository>(
    UnifiedAddressRepositoryImpl(
      addressRepository: GetIt.I.get<AddressRepository>(),
      importedAddressRepository: GetIt.I.get<ImportedAddressRepository>(),
    ),
  );

  injector.registerSingleton<OrderRepository>(
      OrderRepositoryImpl(api: GetIt.I.get<V2Api>()));

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

  injector.registerSingleton<AccountSettingsRepository>(
      AccountSettingsRepositoryImpl(
    cacheProvider: GetIt.I.get<CacheProvider>(),
  ));

  injector.registerSingleton<DispenserRepository>(
    DispenserRepositoryImpl(
      api: GetIt.I.get<V2Api>(),
      logger: GetIt.I.get<Logger>(),
    ),
  );

  injector.registerSingleton<FairminterRepository>(
    FairminterRepositoryImpl(
      api: GetIt.I.get<V2Api>(),
      logger: GetIt.I.get<Logger>(),
    ),
  );

  injector.registerSingleton<FeeEstimatesRespository>(
      FeeEstimatesRespositoryMempoolSpaceImpl(
          mempoolSpaceApi: MempoolSpaceApi(
    dio: mempoolspaceDio,
    configRepository: config,
  )));

  injector.registerSingleton<NodeInfoRepository>(
      NodeInfoRepositoryImpl(GetIt.I.get<V2Api>()));

  injector.registerSingleton<GetFeeEstimatesUseCase>(GetFeeEstimatesUseCase(
      feeEstimatesRepository: GetIt.I.get<FeeEstimatesRespository>()));

  injector.registerSingleton<GetVirtualSizeUseCase>(GetVirtualSizeUseCase(
    transactionService: GetIt.I.get<TransactionService>(),
  ));

  injector.registerSingleton<EventsRepository>(EventsRepositoryImpl(
      api_: GetIt.I.get<V2Api>(),
      bitcoinRepository: GetIt.I.get<BitcoinRepository>(),
      cacheProvider: GetIt.I.get<CacheProvider>()));

  injector.registerSingleton<FetchDispenserFormDataUseCase>(
      FetchDispenserFormDataUseCase(
          getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>(),
          balanceRepository: injector.get<BalanceRepository>(),
          dispenserRepository: injector.get<DispenserRepository>()));

  injector.registerSingleton<FetchDispenseFormDataUseCase>(
      FetchDispenseFormDataUseCase(
          getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>()));

  injector.registerSingleton(FetchCloseDispenserFormDataUseCase(
      getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>(),
      dispenserRepository: injector.get<DispenserRepository>()));
  injector.registerSingleton<FetchOpenDispensersOnAddressUseCase>(
      FetchOpenDispensersOnAddressUseCase(
          dispenserRepository: GetIt.I.get<DispenserRepository>()));
  injector.registerSingleton<FetchComposeFairmintFormDataUseCase>(
      FetchComposeFairmintFormDataUseCase(
          getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>(),
          fairminterRepository: injector.get<FairminterRepository>()));

  injector
      .registerSingleton<ComposeTransactionUseCase>(ComposeTransactionUseCase(
    utxoRepository: GetIt.I.get<UtxoRepository>(),
    balanceRepository: injector.get<BalanceRepository>(),
    getVirtualSizeUseCase: GetIt.I.get<GetVirtualSizeUseCase>(),
  ));

  injector.registerSingleton<FetchFairminterFormDataUseCase>(
      FetchFairminterFormDataUseCase(
          assetRepository: injector.get<AssetRepository>(),
          getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>(),
          fairminterRepository: injector.get<FairminterRepository>()));

  injector.registerSingleton<FetchIssuanceFormDataUseCase>(
      FetchIssuanceFormDataUseCase(
          balanceRepository: injector.get<BalanceRepository>(),
          getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>()));

  injector.registerSingleton<FetchComposeAttachUtxoFormDataUseCase>(
      FetchComposeAttachUtxoFormDataUseCase(
          getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
          balanceRepository: injector.get<BalanceRepository>()));

  injector.registerSingleton<SignAndBroadcastTransactionUseCase>(
      SignAndBroadcastTransactionUseCase(
    addressRepository: GetIt.I.get<AddressRepository>(),
    importedAddressRepository: GetIt.I.get<ImportedAddressRepository>(),
    accountRepository: GetIt.I.get<AccountRepository>(),
    walletRepository: GetIt.I.get<WalletRepository>(),
    utxoRepository: GetIt.I.get<UtxoRepository>(),
    encryptionService: GetIt.I.get<EncryptionService>(),
    addressService: GetIt.I.get<AddressService>(),
    transactionService: GetIt.I.get<TransactionService>(),
    bitcoindService: GetIt.I.get<BitcoindService>(),
    transactionLocalRepository: GetIt.I.get<TransactionLocalRepository>(),
    importedAddressService: GetIt.I.get<ImportedAddressService>(),
  ));

  injector.registerSingleton<WriteLocalTransactionUseCase>(
      WriteLocalTransactionUseCase(
    transactionRepository: GetIt.I.get<TransactionRepository>(),
    transactionLocalRepository: GetIt.I.get<TransactionLocalRepository>(),
  ));

  injector.registerSingleton<SignChainedTransactionUseCase>(
      SignChainedTransactionUseCase(
    transactionService: GetIt.I.get<TransactionService>(),
  ));

  injector.registerSingleton<ActionRepository>(ActionRepositoryImpl());

  injector
      .registerSingleton<EstimateDispensesUseCase>(EstimateDispensesUseCase());

  injector.registerSingleton<ImportWalletUseCase>(ImportWalletUseCase(
    addressService: GetIt.I.get<AddressService>(),
    config: GetIt.I.get<Config>(),
    addressRepository: GetIt.I.get<AddressRepository>(),
    accountRepository: GetIt.I.get<AccountRepository>(),
    walletRepository: GetIt.I.get<WalletRepository>(),
    encryptionService: GetIt.I.get<EncryptionService>(),
  ));

  injector.registerLazySingleton<RPCGetAddressesSuccessCallback>(
      () => config.isWebExtension
          ? (args) {
              chrome.tabs.sendMessage(
                args.tabId,
                {
                  "id": args.requestId,
                  "addresses": args.addresses.map((address) {
                    return {
                      "address": address.address,
                      "type": switch (address.type) {
                        AddressRpcType.p2wpkh => "p2wpkh",
                        AddressRpcType.p2pkh => "p2pkh"
                      },
                      "publicKey": address.publicKey,
                    };
                  }).toList(),
                },
                null,
              );

              Future.delayed(const Duration(seconds: 0), html.window.close);
            }
          : (args) => GetIt.I<Logger>().debug("""
               RPCGetAddressesSuccessCallback called with:
                  tabId: ${args.tabId}
                  requestId: ${args.requestId}
                  addresses: ${args.addresses}
          """));

  injector.registerLazySingleton<RPCSignPsbtSuccessCallback>(
      () => config.isWebExtension
          ? (args) {
              chrome.tabs.sendMessage(
                args.tabId,
                {"id": args.requestId, "hex": args.signedPsbt},
                null,
              );

              Future.delayed(const Duration(seconds: 0), html.window.close);
            }
          : (args) => GetIt.I<Logger>().debug("""
               RPCGetSignPsbtSuccessCallback called with:
                  tabId: ${args.tabId}
                  requestId: ${args.requestId}
                  signedPsbt: ${args.signedPsbt}
          """));

  injector.registerLazySingleton<VersionRepository>(() => config.isWebExtension
      ? VersionRepositoryExtensionImpl(
          config: config, logger: GetIt.I<Logger>())
      : VersionRepositoryImpl(config: config));

  injector.registerSingleton<PublicKeyService>(
      PublicKeyServiceImpl(config: config));

  injector.registerSingleton<ErrorService>(
    ErrorServiceImpl(
      GetIt.I<Config>(),
      GetIt.I<Logger>(),
    ),
  );
  // Register the appropriate platform service
  if (GetIt.I.get<Config>().isWebExtension) {
    GetIt.I.registerSingleton<PlatformService>(PlatformServiceExtensionImpl());
  } else {
    GetIt.I.registerSingleton<PlatformService>(PlatformServiceWebImpl());
  }
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
      const timeoutDuration = Duration(seconds: 15);
      final formattedError = CustomDioException(
        requestOptions: err.requestOptions,
        error:
            'Timeout (${timeoutDuration.inSeconds}s) — Request Failed \n ${err.response?.data?['error']}',
        type: DioExceptionType.connectionTimeout,
      );

      GetIt.I<ErrorService>().captureException(
        formattedError,
        stackTrace: err.stackTrace,
      );

      GetIt.I<Logger>().debug(formattedError.toString());
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
      final formattedError = CustomDioException(
        requestOptions: err.requestOptions,
        error:
            'Connection Error — Request Failed ${err.response?.data?['error'] != null ? "\n\n ${err.response?.data?['error']}" : ""}',
        type: DioExceptionType.connectionError,
      );

      GetIt.I<ErrorService>().captureException(
        formattedError,
        stackTrace: err.stackTrace,
      );

      GetIt.I<Logger>().debug(formattedError.toString());
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
      final formattedError = CustomDioException(
        requestOptions: err.requestOptions,
        error: err.response?.data?['error'] != null
            ? "${err.response?.data?['error']}"
            : "Bad Response",
        type: DioExceptionType.badResponse,
      );

      GetIt.I<ErrorService>().captureException(
        formattedError,
        stackTrace: err.stackTrace,
      );

      GetIt.I<Logger>().debug(formattedError.toString());

      GetIt.I<Logger>().debug(formattedError.toString());
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
      // final requestPath = err.requestOptions.uri.toString();
      final formattedError = CustomDioException(
        requestOptions: err.requestOptions,
        error:
            'Bad Certificate — Request Failed ${err.response?.data?['error'] != null ? "\n\n ${err.response?.data?['error']}" : ""}',
        type: DioExceptionType.badCertificate,
      );
      GetIt.I<Logger>().debug(formattedError.toString());
      handler.next(formattedError);
    } else {
      handler.next(err);
    }
  }
}

class SimpleLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestInfo = '${options.method} ${options.uri}';

    GetIt.I<Logger>().debug('Request: $requestInfo');
    handler.next(options);
  }

  @override
  void onResponse(response, ResponseInterceptorHandler handler) {
    final responseInfo =
        '${response.requestOptions.method} ${response.requestOptions.uri} [${response.statusCode}]';
    GetIt.I<Logger>().debug('Response: $responseInfo');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final errorInfo =
        '${err.requestOptions.method} ${err.requestOptions.uri} [Error] ${err.message}';

    GetIt.I<ErrorService>().captureException(
      errorInfo,
      stackTrace: err.stackTrace,
    );

    GetIt.I<Logger>().debug('Error: $errorInfo');
    if (err.response != null) {
      final responseData = err.response?.data;
      GetIt.I<Logger>().debug('Response data: $responseData');
    }
    handler.next(err);
  }
}
