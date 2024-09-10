import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/data/models/bitcoin_tx.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/failure.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';

import 'package:horizon/domain/entities/address_info.dart';
import 'package:horizon/data/models/address_info.dart';

class BitcoinRepositoryImpl extends BitcoinRepository {
  final EsploraApi _esploraApi;
  BitcoinRepositoryImpl({required EsploraApi esploraApi})
      : _esploraApi = esploraApi;

  @override
  Future<Either<Failure, AddressInfo>> getAddressInfo(String address) async {
    try {
      final addressInfo = await _esploraApi.getAddressInfo(address);
      return Right(addressInfo.toEntity());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getFeeEstimates() async {
    try {
      final feeEstimates = await _esploraApi.getFeeEstimates();
      return Right(feeEstimates);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BitcoinTx>> getTransaction(String txid) async {
    try {
      final tx = await _esploraApi.getTransaction(txid);
      return Right(tx);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getTransactionHex(String txid) async {
    try {
      final tx = await _esploraApi.getTransactionHex(txid);
      return Right(tx);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BitcoinTx>>> getTransactions(
      List<String> addresses) async {
    try {
      final allTransactions = await Future.wait(addresses
          .map((address) => _esploraApi.getTransactionsForAddress(address)));

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
  Future<Either<Failure, List<BitcoinTx>>> getMempoolTransactions(
      List<String> addresses) async {
    try {
      final allTransactions = await Future.wait(addresses.map(
          (address) => _esploraApi.getMempoolTransactionsForAddress(address)));

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
  Future<Either<Failure, List<BitcoinTx>>> getConfirmedTransactions(
      List<String> addresses) async {
    try {
      final allTransactions = await Future.wait(
          addresses.map((address) => _fetchAllTransactionsForAddress(address)));

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
  Future<Either<Failure, int>> getBlockHeight() async {
    try {
      final blockHeight = await _esploraApi.getBlockHeight();
      return Right(blockHeight);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      print('IS THIS THE ERROR? $e');
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  Future<List<BitcoinTx>> _fetchAllTransactionsForAddress(
      String address) async {
    final allTransactions = <BitcoinTx>[];
    String? lastSeenTxid;
    bool hasMore = true;

    while (hasMore) {
      final transactions = await _esploraApi.getConfirmedTransactionsForAddress(
          address,
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

class EsploraApi {
  final Dio _dio;

  final _confirmedTxCache = <String, List<BitcoinTxModel>>{};

  EsploraApi({required Dio dio}) : _dio = dio;

  Future<List<BitcoinTxModel>> getTransactionsForAddress(String address) async {
    try {
      final response = await _dio.get('/address/$address/txs');
      final List<dynamic> txList = response.data as List<dynamic>;
      return txList
          .map((tx) => BitcoinTxModel.fromJson(tx as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<List<BitcoinTxModel>> getMempoolTransactionsForAddress(
      String address) async {
    try {
      final response = await _dio.get('/address/$address/txs/mempool');
      final List<dynamic> txList = response.data as List<dynamic>;
      return txList
          .map((tx) => BitcoinTxModel.fromJson(tx as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<List<BitcoinTxModel>> getConfirmedTransactionsForAddress(
      String address,
      {String? lastSeenTxid}) async {
    try {
      if (lastSeenTxid != null) {
        // Check cache first
        final cacheKey = '$address:$lastSeenTxid';
        if (_confirmedTxCache.containsKey(cacheKey)) {
          return _confirmedTxCache[cacheKey]!;
        }
      }

      String url = '/address/$address/txs/chain';
      if (lastSeenTxid != null) {
        url += '/$lastSeenTxid';
      }
      final response = await _dio.get(url);
      final List<dynamic> txList = response.data as List<dynamic>;
      final transactions = txList
          .map((tx) => BitcoinTxModel.fromJson(tx as Map<String, dynamic>))
          .toList();

      if (lastSeenTxid != null) {
        final cacheKey = '$address:$lastSeenTxid';
        _confirmedTxCache[cacheKey] = transactions;
      }

      return transactions;
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<BitcoinTx> getTransaction(String txid) async {
    try {
      final response = await _dio.get('/tx/$txid');
      final tx = BitcoinTxModel.fromJson(response.data as Map<String, dynamic>);
      return tx.toDomain();
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<String> getTransactionHex(String txid) async {
    try {
      final response = await _dio.get('/tx/$txid/hex');
      return response.data as String;
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<Map<String, double>> getFeeEstimates() async {
    try {
      final response = await _dio.get('/fee-estimates');
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;

      // Convert the dynamic values to double
      return data.map((key, value) => MapEntry(key, (value as num).toDouble()));
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<int> getBlockHeight() async {
    try {
      final response = await _dio.get('/blocks/tip/height');
      return int.parse(response.data);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<AddressInfoModel> getAddressInfo(String address) async {
    try {
      final response = await _dio.get('/address/$address');
      return AddressInfoModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Never _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw const NetworkFailure(message: 'Connection timed out');
    } else if (e.response != null) {
      throw ServerFailure(
          message: 'Server error: ${e.response?.statusCode}',
          statusCode: e.response?.statusCode);
    } else {
      throw UnexpectedFailure(
          message: 'An unexpected error occurred: ${e.message}');
    }
  }
}
