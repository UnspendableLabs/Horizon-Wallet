import 'package:fpdart/fpdart.dart';
import 'package:horizon/data/sources/repositories/network_error_helpers.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/network_error.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/entities/address_info.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/data/sources/network/esplora_client.dart';
import 'package:horizon/data/sources/network/esplora_client_factory.dart';

class BitcoinRepositoryImpl extends BitcoinRepository {
  // chat, i wondre if it won't be perofmant to create a new client on every call?
  // maybe it needs to be singleton, or memoized?
  final EsploraClientFactory esploraClientFactory;

  BitcoinRepositoryImpl({required this.esploraClientFactory});

  EsploraApi _esploraApi(HttpConfig httpConfig) {
    return esploraClientFactory.getClient(httpConfig);
  }

  @override
  TaskEither<NetworkError, Map<String, double>> getFeeEstimates({
    required HttpConfig httpConfig,
  }) {
    return handleNetworkCall(() async {
      return await _esploraApi(httpConfig).getFeeEstimates();
    });
  }

  @override
  TaskEither<NetworkError, AddressInfo> getAddressInfo({
    required String address,
    required HttpConfig httpConfig,
  }) {
    return handleNetworkCall(() async {
      final addressInfo = await _esploraApi(httpConfig).getAddressInfo(address);
      return addressInfo.toEntity();
    });
  }

  @override
  TaskEither<NetworkError, BitcoinTx> getTransaction({
    required String txid,
    required HttpConfig httpConfig,
  }) {
    return handleNetworkCall(() async {
      return await _esploraApi(httpConfig).getTransaction(txid);
    });
  }

  @override
  TaskEither<NetworkError, String> getTransactionHex({
    required String txid,
    required HttpConfig httpConfig,
  }) {
    return handleNetworkCall(() async {
      return await _esploraApi(httpConfig).getTransactionHex(txid);
    });
  }

  @override
  TaskEither<NetworkError, List<BitcoinTx>> getTransactions({
    required List<String> addresses,
    required HttpConfig httpConfig,
  }) {
    return handleNetworkCall(() async {
      final allTransactions = await Future.wait(addresses.map((address) =>
          _esploraApi(httpConfig).getTransactionsForAddress(address)));

      final flattenedTransactions = allTransactions.expand((i) => i).toList();

      final uniqueTransactions = flattenedTransactions
          .fold<Map<String, BitcoinTx>>({}, (map, tx) {
            map.putIfAbsent(tx.txid,
                () => tx.toDomain()); // possible there could be collisions?
            return map;
          })
          .values
          .toList();
      // Sort transactions by block height in descending order
      uniqueTransactions.sort((a, b) {
        // Assuming BitcoinTx has a blockHeight property
        // Put unconfirmed transactions (null block height) at the beginning
        // ( but they should all be confirmed )
        if (a.status.blockHeight == null) return -1;
        if (b.status.blockHeight == null) return 1;
        return b.status.blockHeight!.compareTo(a.status.blockHeight!);
      });

      return uniqueTransactions;
    });
  }

  @override
  TaskEither<NetworkError, List<BitcoinTx>> getMempoolTransactions({
    required List<String> addresses,
    required HttpConfig httpConfig,
  }) {
    return handleNetworkCall(() async {
      final allTransactions = await Future.wait(addresses.map((address) =>
          _esploraApi(httpConfig).getMempoolTransactionsForAddress(address)));

      final flattenedTransactions = allTransactions.expand((i) => i).toList();

      final uniqueTransactions = flattenedTransactions
          .fold<Map<String, BitcoinTx>>({}, (map, tx) {
            map.putIfAbsent(tx.txid,
                () => tx.toDomain()); // possible there could be collisions?
            return map;
          })
          .values
          .toList();

      // Sort transactions by block height in descending order
      uniqueTransactions.sort((a, b) {
        // Assuming BitcoinTx has a blockHeight property
        // Put unconfirmed transactions (null block height) at the beginning
        // ( but they should all be confirmed )
        if (a.status.blockHeight == null) return -1;
        if (b.status.blockHeight == null) return 1;
        return b.status.blockHeight!.compareTo(a.status.blockHeight!);
      });
      return uniqueTransactions;
    });
  }

  @override
  TaskEither<NetworkError, List<BitcoinTx>> getConfirmedTransactionsPaginated({
    required String address,
    String? lastSeenTxid,
    required HttpConfig httpConfig,
  }) {
    return handleNetworkCall(() async {
      final transactions = await _esploraApi(httpConfig)
          .getConfirmedTransactionsForAddress(address,
              lastSeenTxid: lastSeenTxid);

      final txs = transactions.map((tx) => tx.toDomain()).toList();

      return txs;
    });
  }

  @override
  TaskEither<NetworkError, List<BitcoinTx>> getConfirmedTransactions({
    required List<String> addresses,
    required HttpConfig httpConfig,
  }) {
    return TaskEither.Do(($) async {
      final allTransactions = await Future.wait(addresses.map((address) =>
          $(_fetchAllTransactionsForAddress(address, httpConfig))));

      final uniqueTransactions = allTransactions
          .expand((txList) => txList)
          .fold<Map<String, BitcoinTx>>({}, (map, tx) {
            map.putIfAbsent(tx.txid, () => tx);
            return map;
          })
          .values
          .toList();

      // Sort transactions by block height in descending order
      uniqueTransactions.sort((a, b) {
        // Assuming BitcoinTx has a blockHeight property
        // Put unconfirmed transactions (null block height) at the beginning
        // ( but they should all be confirmed )
        if (a.status.blockHeight == null) return -1;
        if (b.status.blockHeight == null) return 1;
        return b.status.blockHeight!.compareTo(a.status.blockHeight!);
      });

      return uniqueTransactions;
    });
  }

  @override
  TaskEither<NetworkError, int> getBlockHeight({
    required HttpConfig httpConfig,
  }) {
    return handleNetworkCall(() async {
      return await _esploraApi(httpConfig).getBlockHeight();
    });
  }

  TaskEither<NetworkError, List<BitcoinTx>> _fetchAllTransactionsForAddress(
    String address,
    HttpConfig httpConfig,
  ) {
    return handleNetworkCall(() async {
      final allTransactions = <BitcoinTx>[];
      String? lastSeenTxid;
      bool hasMore = true;
      while (hasMore) {
        final transactions = await _esploraApi(httpConfig)
            .getConfirmedTransactionsForAddress(address,
                lastSeenTxid: lastSeenTxid);
        if (transactions.isEmpty) {
          hasMore = false;
        } else {
          allTransactions.addAll(transactions.map((tx) => tx.toDomain()));
          lastSeenTxid = transactions.last.txid;
        }
      }

      return allTransactions;
    });
  }
}
