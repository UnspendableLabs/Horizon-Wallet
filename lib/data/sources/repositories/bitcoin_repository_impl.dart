import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/failure.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/entities/address_info.dart';
import 'package:horizon/data/sources/network/esplora_client.dart';

class BitcoinRepositoryImpl extends BitcoinRepository {
  final EsploraApi _esploraApi;

  BitcoinRepositoryImpl({required EsploraApi esploraApi})
      : _esploraApi = esploraApi;

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
  Future<Either<Failure, List<BitcoinTx>>> getConfirmedTransactionsPaginated(
      String address, String? lastSeenTxid) async {
    try {
      final transactions = await _esploraApi.getConfirmedTransactionsForAddress(
          address,
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

//   Future<List<BitcoinTx>> _fetchAllTransactionsForAddressBlockCypher(
//       String address) async {
//     final allTransactions = <BitcoinTx>[];
//     int? lastBlock;
//     bool hasMore = true;
//
//     while (hasMore) {
//       final transactions = await _blockCypherApi
//           .getConfirmedTransactionsForAddress(address, lastBlock);
//       if (transactions.isEmpty) {
//         hasMore = false;
//       } else {
//         allTransactions.addAll(transactions.map((tx) => tx.toDomain()));
//         lastBlock = transactions.last.status.blockHeight;
//         await Future.delayed(Duration(seconds: 30));
//       }
//     }
//
//     return allTransactions;
//   }
//
}

// class BlockCypherApi {
//   final Dio _dio;
//   final _confirmedTxCache = <String, List<BitcoinTxModel>>{};
//
//   BlockCypherApi({required Dio dio}) : _dio = dio;
//
//   Future<List<BitcoinTxModel>> getTransactionsForAddress(String address) async {
//     try {
//       final response = await _dio.get('/addrs/$address/full?limit=2000');
//       final List<dynamic> txList = response.data['txs'] as List<dynamic>;
//       return txList.map((tx) => _convertToCustomFormat(tx)).toList();
//     } on DioException catch (e) {
//       _handleDioException(e);
//     }
//   }
//   //
//   // Future<List<BitcoinTxModel>> getMempoolTransactionsForAddress(
//   //     String address) async {
//   //   try {
//   //     final response =
//   //         await _dio.get('/addrs/$address/full?limit=50&unspentOnly=true');
//   //     final List<dynamic> txList = response.data['txs'] as List<dynamic>;
//   //     return txList
//   //         .where((tx) => tx['confirmations'] == 0)
//   //         .map((tx) => _convertToCustomFormat(tx))
//   //         .toList();
//   //   } on DioException catch (e) {
//   //     _handleDioException(e);
//   //   }
//   // }
//
//   Future<List<BitcoinTxModel>> getConfirmedTransactionsForAddress(
//     String address,
//     int? lastBlock,
//   ) async {
//     try {
//       String url = '/addrs/$address/full?limit=2000';
//       if (lastBlock != null) {
//         url += '&before=$lastBlock';
//       }
//
//       if (lastBlock == null) {
//         final cacheKey = '$address:$lastBlock';
//         if (_confirmedTxCache.containsKey(cacheKey)) {
//           return _confirmedTxCache[cacheKey]!;
//         }
//       }
//
//       final response = await _dio.get(url);
//       final List<dynamic> txList = response.data['txs'] as List<dynamic>;
//       final transactions = txList
//           .where((tx) => tx['confirmations'] > 0)
//           .map((tx) => _convertToCustomFormat(tx))
//           .toList();
//
//       if (lastBlock != null) {
//         final cacheKey = '$address:$lastBlock';
//         _confirmedTxCache[cacheKey] = transactions;
//       }
//
//       return transactions;
//     } on DioException catch (e) {
//       _handleDioException(e);
//     }
//   }
//
//   Future<BitcoinTx> getTransaction(String txid) async {
//     try {
//       final response = await _dio.get('/txs/$txid');
//       return _convertToCustomFormat(response.data).toDomain();
//     } on DioException catch (e) {
//       _handleDioException(e);
//     }
//   }
//
//   Future<String> getTransactionHex(String txid) async {
//     try {
//       final response = await _dio.get('/txs/$txid?includeHex=true');
//       return response.data['hex'] as String;
//     } on DioException catch (e) {
//       _handleDioException(e);
//     }
//   }
//
//   // Future<Map<String, double>> getFeeEstimates() async {
//   //   try {
//   //     final response = await _dio.get('$_baseUrl');
//   //     final Map<String, dynamic> data = response.data as Map<String, dynamic>;
//   //     return {
//   //       '1': data['high_fee_per_kb'] / 1000,
//   //       '6': data['medium_fee_per_kb'] / 1000,
//   //       '24': data['low_fee_per_kb'] / 1000,
//   //     };
//   //   } on DioException catch (e) {
//   //     _handleDioException(e);
//   //   }
//   // }
//
//   Future<int> getBlockHeight() async {
//     try {
//       final response = await _dio.get("");
//       return response.data['height'] as int;
//     } on DioException catch (e) {
//       _handleDioException(e);
//     }
//   }
//
//   BitcoinTxModel _convertToCustomFormat(Map<String, dynamic> blockCypherTx) {
//     return BitcoinTxModel(
//       txid: blockCypherTx['hash'],
//       version: blockCypherTx['ver'],
//       locktime: 0,
//       vin: _convertInputs(blockCypherTx['inputs']),
//       vout: _convertOutputs(blockCypherTx['outputs']),
//       size: blockCypherTx['size'],
//       weight: blockCypherTx['weight'] ??
//           blockCypherTx['size'] * 4, // Estimate weight if not provided
//       fee: blockCypherTx['fees'],
//       status: StatusModel(
//         confirmed: blockCypherTx['confirmations'] > 0,
//         blockHeight: blockCypherTx['block_height'],
//         blockHash: blockCypherTx['block_hash'],
//         blockTime: blockCypherTx['confirmed'] != null
//             ? DateTime.parse(blockCypherTx['confirmed'])
//                     .millisecondsSinceEpoch ~/
//                 1000
//             : null,
//       ),
//     );
//   }
//
//   List<VinModel> _convertInputs(List<dynamic> inputs) {
//     return inputs
//         .map((input) => VinModel(
//               txid: input['prev_hash'],
//               vout: input['output_index'],
//               prevout: PrevoutModel(
//                 scriptpubkey: input['script'] ?? '',
//                 scriptpubkeyAsm: '', // BlockCypher doesn't provide this
//                 scriptpubkeyType: input['script_type'] ?? '',
//                 scriptpubkeyAddress: input['addresses']?.first,
//                 value: input['output_value'] ?? 0,
//               ),
//               scriptsig: input['script'] ?? '',
//               scriptsigAsm: '', // BlockCypher doesn't provide this
//               witness: [], // BlockCypher doesn't provide witness data in this format
//               isCoinbase:
//                   false, // We'd need to check if this is a coinbase transaction
//               sequence: input['sequence'] ??
//                   4294967295, // Default to max sequence if not provided
//             ))
//         .toList();
//   }
//
//   List<VoutModel> _convertOutputs(List<dynamic> outputs) {
//     return outputs
//         .map((output) => VoutModel(
//               scriptpubkey: output['script'],
//               scriptpubkeyAsm: '', // BlockCypher doesn't provide this
//               scriptpubkeyType: output['script_type'],
//               scriptpubkeyAddress: output['addresses']?.first,
//               value: output['value'],
//             ))
//         .toList();
//   }
//
//   Never _handleDioException(DioException e) {
//     if (e.type == DioExceptionType.connectionTimeout ||
//         e.type == DioExceptionType.sendTimeout ||
//         e.type == DioExceptionType.receiveTimeout) {
//       throw const NetworkFailure(message: 'Connection timed out');
//     } else if (e.response != null) {
//       throw ServerFailure(
//           message: 'Server error: ${e.response?.statusCode}',
//           statusCode: e.response?.statusCode);
//     } else {
//       throw UnexpectedFailure(
//           message: 'An unexpected error occurred: ${e.message}');
//     }
//   }
// }
