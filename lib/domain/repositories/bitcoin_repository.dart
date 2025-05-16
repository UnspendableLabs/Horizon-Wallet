import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/address_info.dart';
import 'package:horizon/domain/entities/http_config.dart';

abstract class BitcoinRepository {
  Future<List<BitcoinTx>> getMempoolTransactions({
    required List<String> addresses,
    required HttpConfig httpConfig,
  });

  Future<List<BitcoinTx>> getConfirmedTransactions({
    required List<String> addresses,
    required HttpConfig httpConfig,
  });

  Future<List<BitcoinTx>> getConfirmedTransactionsPaginated({
    required String address,
    String? lastSeenTxid,
    required HttpConfig httpConfig,
  });

  Future<List<BitcoinTx>> getTransactions({
    required List<String> addresses,
    required HttpConfig httpConfig,
  });

  Future<BitcoinTx> getTransaction({
    required String txid,
    required HttpConfig httpConfig,
  });

  Future<Map<String, double>> getFeeEstimates({
    required HttpConfig httpConfig,
  });

  Future<String> getTransactionHex({
    required String txid,
    required HttpConfig httpConfig,
  });

  Future<int> getBlockHeight({
    required HttpConfig httpConfig,
  });

  Future<AddressInfo> getAddressInfo({
    required String address,
    required HttpConfig httpConfig,
  });
}

extension BitcoinRepositoryX on BitcoinRepository {
  TaskEither<String, List<BitcoinTx>> getMempoolTransactionsT({
    required List<String> addresses,
    required HttpConfig httpConfig,
    required String Function(Object error) onError,
  }) =>
      TaskEither.tryCatch(
        () => getMempoolTransactions(
            addresses: addresses, httpConfig: httpConfig),
        (e, _) => onError(e),
      );

  TaskEither<String, List<BitcoinTx>> getConfirmedTransactionsT({
    required List<String> addresses,
    required HttpConfig httpConfig,
    required String Function(Object error) onError,
  }) =>
      TaskEither.tryCatch(
        () => getConfirmedTransactions(
            addresses: addresses, httpConfig: httpConfig),
        (e, _) => onError(e),
      );

  TaskEither<String, List<BitcoinTx>> getConfirmedTransactionsPaginatedT({
    required String address,
    String? lastSeenTxid,
    required HttpConfig httpConfig,
    required String Function(Object error) onError,
  }) =>
      TaskEither.tryCatch(
        () => getConfirmedTransactionsPaginated(
          address: address,
          lastSeenTxid: lastSeenTxid,
          httpConfig: httpConfig,
        ),
        (e, _) => onError(e),
      );

  TaskEither<String, List<BitcoinTx>> getTransactionsT({
    required List<String> addresses,
    required HttpConfig httpConfig,
    required String Function(Object error) onError,
  }) =>
      TaskEither.tryCatch(
        () => getTransactions(addresses: addresses, httpConfig: httpConfig),
        (e, _) => onError(e),
      );

  TaskEither<String, BitcoinTx> getTransactionT({
    required String txid,
    required HttpConfig httpConfig,
    required String Function(Object error) onError,
  }) =>
      TaskEither.tryCatch(
        () => getTransaction(txid: txid, httpConfig: httpConfig),
        (e, _) => onError(e),
      );

  TaskEither<String, Map<String, double>> getFeeEstimatesT({
    required HttpConfig httpConfig,
    required String Function(Object error) onError,
  }) =>
      TaskEither.tryCatch(
        () => getFeeEstimates(httpConfig: httpConfig),
        (e, _) => onError(e),
      );

  TaskEither<String, String> getTransactionHexT({
    required String txid,
    required HttpConfig httpConfig,
    required String Function(Object error) onError,
  }) =>
      TaskEither.tryCatch(
        () => getTransactionHex(txid: txid, httpConfig: httpConfig),
        (e, _) => onError(e),
      );

  TaskEither<String, int> getBlockHeightT({
    required HttpConfig httpConfig,
    required String Function(Object error) onError,
  }) =>
      TaskEither.tryCatch(
        () => getBlockHeight(httpConfig: httpConfig),
        (e, _) => onError(e),
      );

  TaskEither<String, AddressInfo> getAddressInfoT({
    required String address,
    required HttpConfig httpConfig,
    required String Function(Object error) onError,
  }) =>
      TaskEither.tryCatch(
        () => getAddressInfo(address: address, httpConfig: httpConfig),
        (e, _) => onError(e),
      );
}
