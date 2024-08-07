import 'package:dio/dio.dart';
import 'package:fpdart/src/either.dart';
import 'package:horizon/data/models/bitcoin_tx.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/failure.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';

class BitcoinRepositoryImpl extends BitcoinRepository {
  final EsploraApi _esploraApi;

  BitcoinRepositoryImpl({required EsploraApi esploraApi})
      : _esploraApi = esploraApi;

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

      return Right(uniqueTransactions);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}

class EsploraApi {
  final Dio _dio;

  EsploraApi({required Dio dio}) : _dio = dio;

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

  Future<BitcoinTx> getTransaction(String txid) async {
    try {
      final response = await _dio.get('/tx/$txid');
      final tx = BitcoinTxModel.fromJson(response.data as Map<String, dynamic>);
      return tx.toDomain();
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
