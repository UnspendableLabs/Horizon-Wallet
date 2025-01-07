import 'package:dio/dio.dart';
import 'package:horizon/data/models/bitcoin_tx.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/failure.dart';
import 'package:horizon/data/models/address_info.dart';
import 'package:horizon/domain/services/error_service.dart';

class EsploraUtxoStatus {
  final bool confirmed;
  final int? blockHeight;
  final String? blockHash;
  final int? blockTime;

  EsploraUtxoStatus({
    required this.confirmed,
    this.blockHeight,
    this.blockHash,
    this.blockTime,
  });

  factory EsploraUtxoStatus.fromJson(Map<String, dynamic> json) {
    return EsploraUtxoStatus(
      confirmed: json['confirmed'] as bool,
      blockHeight: json['block_height'] as int?,
      blockHash: json['block_hash'] as String?,
      blockTime: json['block_time'] as int?,
    );
  }
}

class EsploraUtxo {
  final String txid;
  final int vout;
  final EsploraUtxoStatus status;
  final int value;

  EsploraUtxo({
    required this.txid,
    required this.vout,
    required this.status,
    required this.value,
  });

  factory EsploraUtxo.fromJson(Map<String, dynamic> json) {
    return EsploraUtxo(
      txid: json['txid'] as String,
      vout: json['vout'] as int,
      status:
          EsploraUtxoStatus.fromJson(json['status'] as Map<String, dynamic>),
      value: json['value'] as int,
    );
  }
}

class EsploraApi {
  final Dio _dio;
  final ErrorService errorService;
  final _confirmedTxCache = <String, List<BitcoinTxModel>>{};

  EsploraApi({
    required Dio dio,
    required this.errorService,
  }) : _dio = dio;

  Future<List<EsploraUtxo>> getUtxosForAddress(String address) async {
    try {
      final response = await _dio.get('/address/$address/utxo');
      final List<dynamic> utxos = response.data as List<dynamic>;
      return utxos
          .map((utxo) => EsploraUtxo.fromJson(utxo as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

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
      String url = '/address/$address/txs/chain';
      if (lastSeenTxid != null) {
        url += '/$lastSeenTxid';
        final cacheKey = '$address:$lastSeenTxid';
        if (_confirmedTxCache.containsKey(cacheKey)) {
          return _confirmedTxCache[cacheKey]!;
        }
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

  Future<AddressInfoModel> getAddressInfo(String address) async {
    try {
      final response = await _dio.get('/address/$address');
      return AddressInfoModel.fromJson(response.data as Map<String, dynamic>);
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

  Never _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      errorService.addBreadcrumb(
        type: 'error',
        category: 'esplora',
        message:
            "${e.type} - ${e.message} - ${e.response?.statusCode} - ${e.requestOptions.uri}",
      );
      throw const NetworkFailure(message: 'Connection timed out');
    } else if (e.response != null) {
      errorService.addBreadcrumb(
        type: 'error',
        category: 'error',
        message:
            "${e.type} - ${e.message} - ${e.response?.statusCode} - ${e.requestOptions.uri}",
      );
      throw ServerFailure(
          message: 'Server error: ${e.response?.statusCode}',
          statusCode: e.response?.statusCode);
    } else {
      errorService.addBreadcrumb(
        type: 'error',
        category: 'esplora',
        message:
            "${e.type} - ${e.message} - ${e.response?.statusCode} - ${e.requestOptions.uri}",
      );
      throw UnexpectedFailure(
          message: 'An unexpected error occurred: ${e.message}');
    }
  }
}
