import 'package:dio/dio.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/data/services/mempool_price_service_impl.dart';

import 'package:horizon/data/services/secure_kv_service_impl.dart';
import 'package:horizon/domain/entities/address_rpc.dart';
import 'package:horizon/domain/services/mempool_price_service.dart';
import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';

import 'package:horizon/data/sources/repositories/in_memory_key_repository_impl.dart';
import 'package:horizon/domain/services/database_manager_service.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';

import 'package:horizon/data/services/address_service/address_service_factory.dart';
import 'package:horizon/data/services/bip39_service/bip39_service_factory.dart';
import 'package:horizon/data/services/encryption_service/encryption_service_factory.dart';
import 'package:horizon/data/services/bitcoind_service_impl.dart';
import 'package:horizon/data/services/cache_provider_impl.dart';
// import 'package:horizon/data/services/encryption_service_web_worker_impl.dart';
// import 'package:horizon/data/services/imported_address_service_impl.dart';
import 'package:horizon/data/services/imported_address_service/imported_address_service_factory.dart';
// import 'package:chrome_extension/tabs.dart';
// import 'package:horizon/data/services/platform_service_extension_impl.dart';
import 'package:horizon/data/services/platform_service/platform_service_factory.dart';
import "package:horizon/data/sources/repositories/address_repository_impl.dart";

import 'package:horizon/data/sources/repositories/estimate_xcp_fee_repository_impl.dart';
import "package:horizon/domain/repositories/address_repository.dart";
import 'package:horizon/data/sources/local/database_manager/database_manager_factory.dart';
// import 'package:horizon/data/sources/local/database_manager_native.dart';

// import 'package:horizon/data/services/mnemonic_service_impl.dart';
import 'package:horizon/data/services/mnemonic_service/mnemonic_service_factory.dart';
// import 'package:horizon/data/services/transaction_service_impl.dart';
import 'package:horizon/data/services/transaction_service/transaction_service_factory.dart';
// import 'package:horizon/data/services/wallet_service_impl.dart';
import 'package:horizon/data/sources/repositories/account_settings_repository_impl.dart';
import 'package:horizon/data/sources/repositories/address_tx_repository_impl.dart';
import 'package:horizon/data/sources/repositories/balance_repository_impl.dart';
import 'package:horizon/data/sources/repositories/block_repository_impl.dart';
import 'package:horizon/data/sources/repositories/compose_repository_impl.dart';
import 'package:horizon/data/sources/repositories/fairminter_repository_impl.dart';
import 'package:horizon/data/sources/repositories/imported_address_repository_impl.dart';
import 'package:horizon/data/sources/repositories/node_info_repository_impl.dart';
import 'package:horizon/data/sources/repositories/utxo_repository_impl.dart';
import 'package:horizon/domain/repositories/account_settings_repository.dart';
import 'package:horizon/domain/repositories/address_tx_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/block_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/estimate_xcp_fee_repository.dart';
import 'package:horizon/domain/repositories/fairminter_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/node_info_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bip39.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/platform_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';

// import 'package:horizon/data/services/public_key_service_impl.dart';

import 'package:horizon/domain/services/seed_service.dart';
import 'package:horizon/data/services/seed_service_impl.dart';

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

import 'package:horizon/domain/repositories/asset_search_repository.dart';
import 'package:horizon/data/sources/repositories/asset_search_repository_impl.dart';

import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/data/sources/repositories/config_repository_impl.dart';

import 'package:horizon/domain/repositories/action_repository.dart';
import 'package:horizon/data/sources/repositories/action_repository_impl.dart';

import 'package:horizon/domain/repositories/dispenser_repository.dart';
import 'package:horizon/data/sources/repositories/dispenser_repository_impl.dart';

import "package:horizon/domain/repositories/fee_estimates_repository.dart";
import 'package:horizon/data/sources/repositories/fee_estimates_repository_mempool_space_impl.dart';

import "package:horizon/domain/repositories/atomic_swap_repository.dart";
import 'package:horizon/data/sources/repositories/atomic_swap_repository_impl.dart';

import 'package:horizon/data/sources/network/mempool_space_client_factory.dart';

import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/usecase/set_mnemonic_usecase.dart';
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
import 'package:horizon/presentation/screens/compose_dividend/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/compose_fairmint/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/compose_fairminter/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/compose_issuance/usecase/fetch_form_data.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:logger/logger.dart' as logger;
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/data/logging/logger_impl.dart';
import 'package:horizon/domain/entities/extension_rpc.dart';
import 'package:horizon/domain/entities/network.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:chrome_extension/chrome.dart';
import 'dart:html' as html;

// will need to move this import elsewhere for compile to native
// import 'dart:html' as html;

import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/data/services/error_service_impl.dart';

import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/data/sources/repositories/settings_repository_impl.dart';

import 'package:horizon/domain/repositories/mnemonic_repository.dart';
import 'package:horizon/data/sources/repositories/mnemonic_repository_impl.dart';

import 'package:horizon/domain/repositories/account_v2_repository.dart';
import 'package:horizon/data/sources/repositories/account_repository_v2_impl.dart';

import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/data/sources/repositories/wallet_config_repository_impl.dart';

import "package:horizon/domain/repositories/address_v2_repository.dart";
import 'package:horizon/data/sources/repositories/address_v2_repository_impl.dart';

import 'package:horizon/data/sources/network/counterparty_client_factory.dart';
import 'package:horizon/data/sources/network/esplora_client_factory.dart';
import 'package:horizon/data/sources/network/horizon_explorer_client_factory.dart';

class AnalyticsServiceStub implements AnalyticsService {
  @override
  void trackEvent(String eventName, {Map<String, Object>? properties}) {}
  @override
  void reset() {}
  @override
  void trackAnonymousEvent(String eventName,
      {Map<String, Object>? properties}) {}
}

void setup() {
  GetIt injector = GetIt.I;

  injector.registerSingleton<Logger>(LoggerSilent(
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

  bool dioRetryEvaluatorFunc(error, retryCount) {
// the retry function is called on each retry, and it logs a single issue in sentry per error (rather than multiple entries for the same error)
// it provides a single, customizable place to catch all dio errors
// we are able to catch the original error + message without the need to parse the dio specific data
// we should eventually move this to a more generic onError handler but for now we get enough info from the original error to be able to address the error
    GetIt.I<ErrorService>().captureException(
      error,
      message: """
            Original error before retry:
            Status Code: ${error.response?.statusCode ?? 'No status code (connection failed)'}
            URL: ${error.requestOptions.uri}
            Type: ${error.type}
            Response: ${error.response?.data ?? 'No response (connection failed)'}
            App Version: ${config.version}
          """,
      context: {
        'errorType': error.type.toString(),
        'statusCode':
            error.response?.statusCode?.toString() ?? 'connection_failed',
        'path': error.requestOptions.path,
        'retryCount': retryCount.toString(),
        'response': error.response,
        'appVersion': config.version,
      },
    );

    final shouldRetry = error.response?.statusCode == 400 ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError;

    return shouldRetry;
  }

  // final dio = Dio(BaseOptions(
  //   baseUrl: config.counterpartyApiBase,
  //   headers: {
  //     'Content-Type': 'application/json',
  //   },
  //   connectTimeout: const Duration(seconds: 5),
  //   receiveTimeout: const Duration(seconds: 3),
  // ));

  // this is no longer required
  // Add basic auth interceptor
  // dio.interceptors.add(InterceptorsWrapper(
  //   onRequest: (options, handler) {
  //     String username = config.counterpartyApiUsername;
  //     String password = config.counterpartyApiPassword;
  //     String basicAuth =
  //         'Basic ${base64Encode(utf8.encode('$username:$password'))}';
  //     options.headers['Authorization'] = basicAuth;
  //     return handler.next(options);
  //   },
  // ));

  // dio.interceptors.addAll([
  //   TimeoutInterceptor(),
  //   ConnectionErrorInterceptor(),
  //   BadResponseInterceptor(),
  //   BadCertificateInterceptor(),
  //   // SimpleLogInterceptor(),
  //   RetryInterceptor(
  //     dio: dio,
  //     retries: 3,
  //     retryDelays: const [
  //       // set delays between retries (optional)
  //       Duration(seconds: 1), // wait 1 sec before first retry
  //       Duration(seconds: 1), // wait 2 sec before second retry
  //       Duration(seconds: 1), // wait 3 sec before third retry
  //     ],
  //     retryEvaluator: dioRetryEvaluatorFunc,
  //   )
  // ]);

  // injector.registerLazySingleton<V2Api>(() => V2Api(dio));

  // final esploraDio = Dio(BaseOptions(
  //   baseUrl: config.esploraBase,
  //   connectTimeout: const Duration(seconds: 5),
  //   receiveTimeout: const Duration(seconds: 3),
  // ));
  //
  // esploraDio.interceptors.addAll([
  //   TimeoutInterceptor(),
  //   ConnectionErrorInterceptor(),
  //   BadResponseInterceptor(),
  //   BadCertificateInterceptor(),
  //   // SimpleLogInterceptor(),
  //   RetryInterceptor(
  //     dio: esploraDio,
  //     retries: 4,
  //     retryDelays: const [
  //       Duration(seconds: 1), // wait 1 sec before first retry
  //       Duration(seconds: 2), // wait 2 sec before second retry
  //       Duration(seconds: 3), // wait 3 sec before third retry
  //       Duration(seconds: 4), // wait 4 sec before fourth retry
  //     ],
  //     retryEvaluator: dioRetryEvaluatorFunc,
  //   ),
  // ]);
  //
  // final mempoolspaceDio = Dio(BaseOptions(
  //   baseUrl: config.esploraBase,
  //   connectTimeout: const Duration(seconds: 5),
  //   receiveTimeout: const Duration(seconds: 3),
  // ));

  // mempoolspaceDio.interceptors.addAll([
  //   RetryInterceptor(
  //     dio: mempoolspaceDio,
  //     retries: 3,
  //     retryDelays: const [
  //       Duration(seconds: 1), // wait 1 sec before first retry
  //       Duration(seconds: 1), // wait 2 sec before second retry
  //       Duration(seconds: 1), // wait 3 sec before third retry
  //     ],
  //     retryEvaluator: dioRetryEvaluatorFunc,
  //   ), // Add the RetryInterceptor here
  // ]);

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

  injector.registerSingleton<AnalyticsService>(AnalyticsServiceStub());

  injector.registerSingleton<ErrorService>(
    ErrorServiceImpl(
      GetIt.I<Config>(),
      GetIt.I<Logger>(),
    ),
  );
  GetIt.I.get<ErrorService>().initialize();

  injector.registerSingleton<HorizonExplorerClientFactory>(
      HorizonExplorerClientFactory());
  injector.registerSingleton<EsploraClientFactory>(EsploraClientFactory());
  injector.registerSingleton<CounterpartyClientFactory>(
      CounterpartyClientFactory());
  injector.registerSingleton<MempoolSpaceClientFactory>(
      MempoolSpaceClientFactory());

  injector
      .registerSingleton<AssetSearchRepository>(AssetSearchRepositoryImpl());

  injector.registerSingleton<BitcoinRepository>(BitcoinRepositoryImpl(
    esploraClientFactory: GetIt.I.get<EsploraClientFactory>(),
    // esploraApi: EsploraApi(
    //   dio: esploraDio,
    // ),
    // blockCypherApi: BlockCypherApi(dio: blockCypherDio)
  ));
  injector.registerSingleton<CacheProvider>(HiveCache());

  injector.registerSingleton<SettingsRepository>(SettingsRepositoryImpl());

  injector.registerSingleton<DatabaseManager>(createDatabaseManager());

  injector.registerSingleton<AddressTxRepository>(AddressTxRepositoryImpl(
    counterpartyClientFactory: GetIt.I.get<CounterpartyClientFactory>(),
  ));
  injector.registerSingleton<ComposeRepository>(ComposeRepositoryImpl());
  injector.registerSingleton<EstimateXcpFeeRepository>(
      EstimateXcpFeeRepositoryImpl());
  injector.registerSingleton<UtxoRepository>(
      UtxoRepositoryImpl(cacheProvider: GetIt.I.get<CacheProvider>()));
  injector.registerSingleton<BalanceRepository>(BalanceRepositoryImpl(
      counterpartyClientFactory: GetIt.I.get<CounterpartyClientFactory>(),
      utxoRepository: GetIt.I.get<UtxoRepository>(),
      bitcoinRepository: GetIt.I.get<BitcoinRepository>()));

  injector.registerSingleton<BlockRepository>(BlockRepositoryImpl());

  injector.registerSingleton<AssetRepository>(AssetRepositoryImpl());

  injector.registerSingleton<Bip39Service>(createBip39Service());
  injector.registerSingleton<TransactionService>(createTransactionService());
  injector.registerSingleton<EncryptionService>(createEncryptionService());
  // injector.registerSingleton<WalletService>(
  //     createWalletService(encryptionService: injector(), config: config));
  injector.registerSingleton<AddressService>(createAddressService());

  injector.registerSingleton<ImportedAddressService>(
      createImportedAddressService());
  injector.registerSingleton<MnemonicService>(
      createMnemonicService(bip39Service: GetIt.I.get<Bip39Service>()));
  injector.registerSingleton<BitcoindService>(
      BitcoindServiceCounterpartyProxyImpl());

  injector.registerSingleton<WalletConfigRepository>(
      WalletConfigRepositoryImpl(injector.get<DatabaseManager>().database));

  injector.registerSingleton<ImportedAddressRepository>(
      ImportedAddressRepositoryImpl(injector.get<DatabaseManager>().database));

  injector.registerSingleton<SecureKVService>(
      SecureKVServiceImpl(const FlutterSecureStorage()));

  injector.registerSingleton<InMemoryKeyRepository>(InMemoryKeyRepositoryImpl(
    secureKVService: GetIt.I.get<SecureKVService>(),
  ));

  injector.registerSingleton<AccountV2Repository>(
      AccountV2RepositoryImpl(injector.get<DatabaseManager>().database));

  injector.registerSingleton<MnemonicRepository>(
      MnemonicRepositoryImpl(secureKVService: GetIt.I<SecureKVService>()));

  injector.registerSingleton<AddressRepositoryDeprecated>(AddressRepositoryImpl(
    injector.get<DatabaseManager>().database,
  ));

  injector.registerSingleton<OrderRepository>(OrderRepositoryImpl());

  injector
      .registerSingleton<TransactionRepository>(TransactionRepositoryImpl());

  injector.registerSingleton<TransactionLocalRepository>(
      TransactionLocalRepositoryImpl(
          transactionDao:
              TransactionsDao(injector.get<DatabaseManager>().database)));

  injector.registerSingleton<AccountSettingsRepository>(
      AccountSettingsRepositoryImpl(
    cacheProvider: GetIt.I.get<CacheProvider>(),
  ));

  injector.registerSingleton<DispenserRepository>(
    DispenserRepositoryImpl(
      logger: GetIt.I.get<Logger>(),
    ),
  );

  injector.registerSingleton<FairminterRepository>(
    FairminterRepositoryImpl(
      logger: GetIt.I.get<Logger>(),
    ),
  );

  injector.registerSingleton<FeeEstimatesRespository>(
      FeeEstimatesRespositoryMempoolSpaceImpl(
          mempoolSpaceClientFactory: GetIt.I.get<MempoolSpaceClientFactory>()));

  injector.registerSingleton<NodeInfoRepository>(NodeInfoRepositoryImpl());

  injector.registerSingleton<GetFeeEstimatesUseCase>(GetFeeEstimatesUseCase(
      feeEstimatesRepository: GetIt.I.get<FeeEstimatesRespository>()));

  injector.registerSingleton<GetVirtualSizeUseCase>(GetVirtualSizeUseCase(
    transactionService: GetIt.I.get<TransactionService>(),
  ));

  injector.registerSingleton<EventsRepository>(EventsRepositoryImpl(
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

  injector.registerSingleton<FetchDividendFormDataUseCase>(
      FetchDividendFormDataUseCase(
          getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>(),
          balanceRepository: injector.get<BalanceRepository>(),
          assetRepository: injector.get<AssetRepository>(),
          estimateXcpFeeRepository: GetIt.I.get<EstimateXcpFeeRepository>()));

  injector.registerSingleton<SeedService>(SeedServiceImpl());

  injector
      .registerSingleton<ComposeTransactionUseCase>(ComposeTransactionUseCase(
    utxoRepository: GetIt.I.get<UtxoRepository>(),
    balanceRepository: injector.get<BalanceRepository>(),
    errorService: injector.get<ErrorService>(),
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
          estimateXcpFeeRepository: GetIt.I.get<EstimateXcpFeeRepository>(),
          balanceRepository: injector.get<BalanceRepository>()));

  injector.registerSingleton<SignAndBroadcastTransactionUseCase>(
      SignAndBroadcastTransactionUseCase());

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

  injector.registerLazySingleton<RPCGetAddressesSuccessCallback>(
      // () => (args) => GetIt.I<Logger>().debug("""
      //          RPCGetAddressesSuccessCallback called with:
      //             tabId: ${args.tabId}
      //             requestId: ${args.requestId}
      //             addresses: ${args.addresses}
      //     """));
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
      () => (args) => GetIt.I<Logger>().debug("""
               RPCGetSignPsbtSuccessCallback called with:
                  tabId: ${args.tabId}
                  requestId: ${args.requestId}
                  signedPsbt: ${args.signedPsbt}
          """));
  //     () => config.isWebExtension
  //         ? (args) {
  //             chrome.tabs.sendMessage(
  //               args.tabId,
  //               {"id": args.requestId, "hex": args.signedPsbt},
  //               null,
  //             );
  //
  //             Future.delayed(const Duration(seconds: 0), html.window.close);
  //           }
  //         : (args) => GetIt.I<Logger>().debug("""
  //          RPCGetSignPsbtSuccessCallback called with:
  //             tabId: ${args.tabId}
  //             requestId: ${args.requestId}
  //             signedPsbt: ${args.signedPsbt}
  //     """));
  //
  // injector.registerLazySingleton<RPCSignMessageSuccessCallback>(
  //     () => (args) => GetIt.I<Logger>().debug("""
  //              RPCSignMessageSuccessCallback called with:
  //                 tabId: ${args.tabId}
  //                 requestId: ${args.requestId}
  //                 signature: ${args.signature}
  //                 messageHash: ${args.messageHash}
  //                 address: ${args.address}
  //         """));
  // () => config.isWebExtension
  //     ? (args) {
  //         chrome.tabs.sendMessage(
  //           args.tabId,
  //           {
  //             "id": args.requestId,
  //             "signature": args.signature,
  //             "messageHash": args.messageHash,
  //             "address": args.address
  //           },
  //           null,
  //         );
  //
  //         Future.delayed(const Duration(seconds: 0), html.window.close);
  //       }
  //     : (args) => GetIt.I<Logger>().debug("""
  //          RPCSignMessageSuccessCallback called with:
  //             tabId: ${args.tabId}
  //             requestId: ${args.requestId}
  //             signature: ${args.signature}
  //             messageHash: ${args.messageHash}
  //             address: ${args.address}
  //     """));

  injector.registerLazySingleton<VersionRepository>(() => config.isWebExtension
      ? VersionRepositoryExtensionImpl(
          config: config, logger: GetIt.I<Logger>())
      : VersionRepositoryImpl(config: config));

  // Register the appropriate platform service
  // if (GetIt.I.get<Config>().isWebExtension) {
  //   GetIt.I.registerSingleton<PlatformService>(PlatformServiceExtensionImpl());
  // } else {
  GetIt.I.registerSingleton<PlatformService>(
      createPlatformService(config: GetIt.I<Config>()));
  // }

  injector.registerSingleton<SetMnemonicUseCase>(SetMnemonicUseCase(
      encryptionService: GetIt.I<EncryptionService>(),
      inMemoryKeyRepository: GetIt.I<InMemoryKeyRepository>(),
      mnemonicRepository: GetIt.I<MnemonicRepository>()));

  injector.registerSingleton<AddressV2Repository>(AddressV2RepositoryImpl());

  injector.registerSingleton<AtomicSwapRepository>(AtomicSwapRepositoryImpl());

  injector.registerSingleton<SessionStateCubit>(SessionStateCubit(
      kvService: GetIt.I<SecureKVService>(),
      encryptionService: GetIt.I<EncryptionService>(),
      inMemoryKeyRepository: GetIt.I<InMemoryKeyRepository>(),
      cacheProvider: GetIt.I<CacheProvider>(),
      // walletRepository: GetIt.I<WalletRepository>(),
      // accountRepository: GetIt.I<AccountRepository>(),
      // addressRepository: GetIt.I<AddressRepository>(),
      // importedAddressRepository: GetIt.I<ImportedAddressRepository>(),
      analyticsService: GetIt.I<AnalyticsService>()));

  injector.registerSingleton<MempoolPriceService>(MempoolPriceServiceImpl(
      mempoolSpaceClientFactory: GetIt.I.get<MempoolSpaceClientFactory>()));
}

class CustomDioException extends DioException {
  CustomDioException({
    required super.requestOptions,
    required String super.error,
    required super.type,
    super.response,
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
        response: err.response,
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
        response: err.response,
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
        response: err.response,
      );

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
        response: err.response,
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

    GetIt.I<Logger>().debug('Error: $errorInfo');
    if (err.response != null) {
      final responseData = err.response?.data;
      GetIt.I<Logger>().debug('Response data: $responseData');
    }
    handler.next(err);
  }
}
