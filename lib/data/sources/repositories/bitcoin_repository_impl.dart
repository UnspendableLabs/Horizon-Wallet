import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/failure.dart';
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
  Future<Either<Failure, Map<String, double>>> getFeeEstimates({
    required HttpConfig httpConfig,
  }) async {
    try {
      final feeEstimates = await _esploraApi(httpConfig).getFeeEstimates();
      return Right(feeEstimates);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AddressInfo>> getAddressInfo({
    required String address,
    required HttpConfig httpConfig,
  }) async {
    try {
      final addressInfo = await _esploraApi(httpConfig).getAddressInfo(address);
      return Right(addressInfo.toEntity());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BitcoinTx>> getTransaction({
    required String txid,
    required HttpConfig httpConfig,
  }) async {
    try {
      final tx = await _esploraApi(httpConfig).getTransaction(txid);
      return Right(tx);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getTransactionHex({
    required String txid,
    required HttpConfig httpConfig,
  }) async {
    try {
      final tx = await _esploraApi(httpConfig).getTransactionHex(txid);
      return Right(tx);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BitcoinTx>>> getTransactions({
    required List<String> addresses,
    required HttpConfig httpConfig,
  }) async {
    try {
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

      return Right(uniqueTransactions);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BitcoinTx>>> getMempoolTransactions({
    required List<String> addresses,
    required HttpConfig httpConfig,
  }) async {
    try {
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

      return Right(uniqueTransactions);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BitcoinTx>>> getConfirmedTransactionsPaginated({
    required String address,
    String? lastSeenTxid,
    required HttpConfig httpConfig,
  }) async {
    try {
      final transactions = await _esploraApi(httpConfig)
          .getConfirmedTransactionsForAddress(address,
              lastSeenTxid: lastSeenTxid);

      final txs = transactions.map((tx) => tx.toDomain()).toList();

      return Right(txs);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BitcoinTx>>> getConfirmedTransactions({
    required List<String> addresses,
    required HttpConfig httpConfig,
  }) async {
    try {
      final allTransactions = await Future.wait(addresses.map(
          (address) => _fetchAllTransactionsForAddress(address, httpConfig)));

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

      return Right(uniqueTransactions);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getBlockHeight({
    required HttpConfig httpConfig,
  }) async {
    try {
      final blockHeight = await _esploraApi(httpConfig).getBlockHeight();
      return Right(blockHeight);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  Future<List<BitcoinTx>> _fetchAllTransactionsForAddress(
    String address,
    HttpConfig httpConfig,
  ) async {
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
  }
}
