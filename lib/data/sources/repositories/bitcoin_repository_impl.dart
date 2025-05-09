import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/failure.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/entities/address_info.dart';
import 'package:horizon/data/sources/network/esplora_client.dart';
import 'package:dio/dio.dart' hide Options;
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:horizon/data/sources/network/esplora_client.dart';

class BitcoinRepositoryImpl extends BitcoinRepository {
  static final mainnet = EsploraApi(
      dio: Dio(BaseOptions(
    // TODO: read from config
    baseUrl: "https://api.unspendablelabs.com:3000",
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  )));

  static final testnet = EsploraApi(
      dio: Dio(BaseOptions(
    // TODO: read from config
    baseUrl: 'https://testnet4.counterparty.io:43000',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  )));

  EsploraApi _esploraApi(Options options) {
    return switch (options) {
      Mainnet() => mainnet,
      Testnet4() => testnet,
      Custom(esplora: var esplora) => EsploraApi(
            dio: Dio(BaseOptions(
          baseUrl: esplora,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
        ))),
    };
  }

  @override
  Future<Either<Failure, Map<String, double>>> getFeeEstimates({
    required Options options,
  }) async {
    try {
      final feeEstimates = await _esploraApi(options).getFeeEstimates();
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
    required Options options,
  }) async {
    try {
      final addressInfo = await _esploraApi(options).getAddressInfo(address);
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
    required Options options,
  }) async {
    try {
      final tx = await _esploraApi(options).getTransaction(txid);
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
    required Options options,
  }) async {
    try {
      final tx = await _esploraApi(options).getTransactionHex(txid);
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
    required Options options,
  }) async {
    try {
      final allTransactions = await Future.wait(addresses.map((address) =>
          _esploraApi(options).getTransactionsForAddress(address)));

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
    required Options options,
  }) async {
    try {
      final allTransactions = await Future.wait(addresses.map((address) =>
          _esploraApi(options).getMempoolTransactionsForAddress(address)));

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
    required Options options,
  }) async {
    try {
      final transactions = await _esploraApi(options)
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
    required Options options,
  }) async {
    try {
      final allTransactions = await Future.wait(addresses
          .map((address) => _fetchAllTransactionsForAddress(address, options)));

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
    required Options options,
  }) async {
    try {
      final blockHeight = await _esploraApi(options).getBlockHeight();
      return Right(blockHeight);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  Future<List<BitcoinTx>> _fetchAllTransactionsForAddress(
    String address,
    Options options,
  ) async {
    final allTransactions = <BitcoinTx>[];
    String? lastSeenTxid;
    bool hasMore = true;
    while (hasMore) {
      final transactions = await _esploraApi(options)
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
