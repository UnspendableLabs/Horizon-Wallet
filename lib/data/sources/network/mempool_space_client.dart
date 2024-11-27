import 'package:dio/dio.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

class MempoolSpaceFeesRecommendedResponse {
  final int fastestFee;
  final int halfHourFee;
  final int hourFee;
  final int economyFee;
  final int minimumFee;
  MempoolSpaceFeesRecommendedResponse({
    required this.fastestFee,
    required this.halfHourFee,
    required this.hourFee,
    required this.economyFee,
    required this.minimumFee,
  });
  factory MempoolSpaceFeesRecommendedResponse.fromJson(
      Map<String, dynamic> json) {
    return MempoolSpaceFeesRecommendedResponse(
      fastestFee: json['fastestFee'] as int,
      halfHourFee: json['halfHourFee'] as int,
      hourFee: json['hourFee'] as int,
      economyFee: json['economyFee'] as int,
      minimumFee: json['minimumFee'] as int,
    );
  }
}

class MempoolSpaceApi {
  final Dio _dio;
  final Config _configRepository;

  MempoolSpaceApi({required Dio dio, required Config configRepository})
      : _dio = dio,
        _configRepository = configRepository;

  Future<MempoolSpaceFeesRecommendedResponse> getFeeEstimates() async {
    String url = switch (_configRepository.network) {
      Network.mainnet => 'https://mempool.space/api/v1/fees/recommended',
      Network.testnet => 'https://mempool.space/api/v1/fees/recommended',
      Network.regtest => throw UnsupportedError(
          'MempoolSpace.getFeeEstimates not supported on regtest network.')
    };

    final response = await _dio.get(url);
    return MempoolSpaceFeesRecommendedResponse.fromJson(response.data);
  }

  Future<MempoolSpaceTransaction> getTransactionInfo(String txid) async {
    String url = switch (_configRepository.network) {
      Network.mainnet => 'https://mempool.space/api/tx/$txid',
      Network.testnet => 'https://mempool.space/api/tx/$txid',
      Network.regtest => throw UnsupportedError(
          'MempoolSpace.getTransactionInfo not supported on regtest network.')
    };

    final response = await _dio.get(url);
    return MempoolSpaceTransaction.fromJson(response.data);
  }
}

class MempoolSpaceTransaction {
  final String txid;
  final int version;
  final int locktime;
  final List<TransactionInput> vin;
  final List<TransactionOutput> vout;
  final int size;
  final int weight;
  final int sigops;
  final int fee;
  final TransactionStatus status;

  MempoolSpaceTransaction({
    required this.txid,
    required this.version,
    required this.locktime,
    required this.vin,
    required this.vout,
    required this.size,
    required this.weight,
    required this.sigops,
    required this.fee,
    required this.status,
  });

  factory MempoolSpaceTransaction.fromJson(Map<String, dynamic> json) {
    return MempoolSpaceTransaction(
      txid: json['txid'] as String,
      version: json['version'] as int,
      locktime: json['locktime'] as int,
      vin: (json['vin'] as List)
          .map((v) => TransactionInput.fromJson(v))
          .toList(),
      vout: (json['vout'] as List)
          .map((v) => TransactionOutput.fromJson(v))
          .toList(),
      size: json['size'] as int,
      weight: json['weight'] as int,
      sigops: json['sigops'] as int,
      fee: json['fee'] as int,
      status: TransactionStatus.fromJson(json['status']),
    );
  }
}

class TransactionInput {
  final String txid;
  final int vout;
  final PrevOut prevout;
  final String scriptsig;
  final String scriptsig_asm;
  final List<String> witness;
  final bool is_coinbase;
  final int sequence;

  TransactionInput({
    required this.txid,
    required this.vout,
    required this.prevout,
    required this.scriptsig,
    required this.scriptsig_asm,
    required this.witness,
    required this.is_coinbase,
    required this.sequence,
  });

  factory TransactionInput.fromJson(Map<String, dynamic> json) {
    return TransactionInput(
      txid: json['txid'] as String,
      vout: json['vout'] as int,
      prevout: PrevOut.fromJson(json['prevout']),
      scriptsig: json['scriptsig'] as String,
      scriptsig_asm: json['scriptsig_asm'] as String,
      witness: (json['witness'] as List).map((w) => w as String).toList(),
      is_coinbase: json['is_coinbase'] as bool,
      sequence: json['sequence'] as int,
    );
  }
}

class PrevOut {
  final String scriptpubkey;
  final String scriptpubkey_asm;
  final String scriptpubkey_type;
  final String? scriptpubkey_address;
  final int value;

  PrevOut({
    required this.scriptpubkey,
    required this.scriptpubkey_asm,
    required this.scriptpubkey_type,
    this.scriptpubkey_address,
    required this.value,
  });

  factory PrevOut.fromJson(Map<String, dynamic> json) {
    return PrevOut(
      scriptpubkey: json['scriptpubkey'] as String,
      scriptpubkey_asm: json['scriptpubkey_asm'] as String,
      scriptpubkey_type: json['scriptpubkey_type'] as String,
      scriptpubkey_address: json['scriptpubkey_address'] as String?,
      value: json['value'] as int,
    );
  }
}

class TransactionOutput {
  final String scriptpubkey;
  final String scriptpubkey_asm;
  final String scriptpubkey_type;
  final String? scriptpubkey_address;
  final int value;

  TransactionOutput({
    required this.scriptpubkey,
    required this.scriptpubkey_asm,
    required this.scriptpubkey_type,
    this.scriptpubkey_address,
    required this.value,
  });

  factory TransactionOutput.fromJson(Map<String, dynamic> json) {
    return TransactionOutput(
      scriptpubkey: json['scriptpubkey'] as String,
      scriptpubkey_asm: json['scriptpubkey_asm'] as String,
      scriptpubkey_type: json['scriptpubkey_type'] as String,
      scriptpubkey_address: json['scriptpubkey_address'] as String?,
      value: json['value'] as int,
    );
  }
}

class TransactionStatus {
  final bool confirmed;
  final int block_height;
  final String block_hash;
  final int block_time;

  TransactionStatus({
    required this.confirmed,
    required this.block_height,
    required this.block_hash,
    required this.block_time,
  });

  factory TransactionStatus.fromJson(Map<String, dynamic> json) {
    return TransactionStatus(
      confirmed: json['confirmed'] as bool,
      block_height: json['block_height'] as int,
      block_hash: json['block_hash'] as String,
      block_time: json['block_time'] as int,
    );
  }
}
