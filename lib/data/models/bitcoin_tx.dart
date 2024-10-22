// In data/models/bitcoin_tx_model.dart

import '../../domain/entities/bitcoin_tx.dart';

class PrevoutModel {
  final String scriptpubkey;
  final String scriptpubkeyAsm;
  final String scriptpubkeyType;
  final String? scriptpubkeyAddress;
  final int value;

  PrevoutModel({
    required this.scriptpubkey,
    required this.scriptpubkeyAsm,
    required this.scriptpubkeyType,
    this.scriptpubkeyAddress,
    required this.value,
  });

  factory PrevoutModel.fromJson(Map<String, dynamic> json) {
    return PrevoutModel(
      scriptpubkey: json['scriptpubkey'] as String,
      scriptpubkeyAsm: json['scriptpubkey_asm'] as String,
      scriptpubkeyType: json['scriptpubkey_type'] as String,
      scriptpubkeyAddress: json['scriptpubkey_address'] as String?,
      value: json['value'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'scriptpubkey': scriptpubkey,
        'scriptpubkey_asm': scriptpubkeyAsm,
        'scriptpubkey_type': scriptpubkeyType,
        'scriptpubkey_address': scriptpubkeyAddress,
        'value': value,
      };

  Prevout toDomain() => Prevout(
        scriptpubkey: scriptpubkey,
        scriptpubkeyAsm: scriptpubkeyAsm,
        scriptpubkeyType: scriptpubkeyType,
        scriptpubkeyAddress: scriptpubkeyAddress,
        value: value,
      );
}

class VinModel {
  final String txid;
  final int vout;
  final PrevoutModel? prevout;
  final String scriptsig;
  final String scriptsigAsm;
  final List<String>? witness;
  final bool isCoinbase;
  final int sequence;

  VinModel({
    required this.txid,
    required this.vout,
    required this.prevout,
    required this.scriptsig,
    required this.scriptsigAsm,
    required this.witness,
    required this.isCoinbase,
    required this.sequence,
  });

  factory VinModel.fromJson(Map<String, dynamic> json) {
    return VinModel(
      txid: json['txid'] as String,
      vout: json['vout'] as int,
      prevout: json["prevout"] != null
          ? PrevoutModel.fromJson(json['prevout'] as Map<String, dynamic>)
          : null,
      scriptsig: json['scriptsig'] as String,
      scriptsigAsm: json['scriptsig_asm'] as String,
      witness: json["witness"] != null
          ? List<String>.from(json['witness'] as List)
          : null,
      isCoinbase: json['is_coinbase'] as bool,
      sequence: json['sequence'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'txid': txid,
        'vout': vout,
        'prevout': prevout?.toJson(),
        'scriptsig': scriptsig,
        'scriptsig_asm': scriptsigAsm,
        'witness': witness,
        'is_coinbase': isCoinbase,
        'sequence': sequence,
      };

  Vin toDomain() => Vin(
        txid: txid,
        vout: vout,
        prevout: prevout?.toDomain(),
        scriptsig: scriptsig,
        scriptsigAsm: scriptsigAsm,
        witness: witness,
        isCoinbase: isCoinbase,
        sequence: sequence,
      );
}

class VoutModel {
  final String scriptpubkey;
  final String scriptpubkeyAsm;
  final String scriptpubkeyType;
  final String? scriptpubkeyAddress;
  final int value;

  VoutModel({
    required this.scriptpubkey,
    required this.scriptpubkeyAsm,
    required this.scriptpubkeyType,
    this.scriptpubkeyAddress,
    required this.value,
  });

  factory VoutModel.fromJson(Map<String, dynamic> json) {
    return VoutModel(
      scriptpubkey: json['scriptpubkey'] as String,
      scriptpubkeyAsm: json['scriptpubkey_asm'] as String,
      scriptpubkeyType: json['scriptpubkey_type'] as String,
      scriptpubkeyAddress: json['scriptpubkey_address'] as String?,
      value: json['value'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'scriptpubkey': scriptpubkey,
        'scriptpubkey_asm': scriptpubkeyAsm,
        'scriptpubkey_type': scriptpubkeyType,
        'scriptpubkey_address': scriptpubkeyAddress,
        'value': value,
      };

  Vout toDomain() => Vout(
        scriptpubkey: scriptpubkey,
        scriptpubkeyAsm: scriptpubkeyAsm,
        scriptpubkeyType: scriptpubkeyType,
        scriptpubkeyAddress: scriptpubkeyAddress,
        value: value,
      );
}

class StatusModel {
  final bool confirmed;
  final int? blockHeight;
  final String? blockHash;
  final int? blockTime;

  StatusModel({
    required this.confirmed,
    this.blockHeight,
    this.blockHash,
    this.blockTime,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      confirmed: json['confirmed'] as bool,
      blockHeight: json['block_height'] as int?,
      blockHash: json['block_hash'] as String?,
      blockTime: json['block_time'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'confirmed': confirmed,
        'block_height': blockHeight,
        'block_hash': blockHash,
        'block_time': blockTime,
      };

  Status toDomain() => Status(
        confirmed: confirmed,
        blockHeight: blockHeight,
        blockHash: blockHash,
        blockTime: blockTime,
      );
}

class BitcoinTxModel {
  final String txid;
  final int version;
  final int locktime;
  final List<VinModel> vin;
  final List<VoutModel> vout;
  final int size;
  final int weight;
  final int fee;
  final StatusModel status;

  BitcoinTxModel({
    required this.txid,
    required this.version,
    required this.locktime,
    required this.vin,
    required this.vout,
    required this.size,
    required this.weight,
    required this.fee,
    required this.status,
  });

  factory BitcoinTxModel.fromJson(Map<String, dynamic> json) {
    return BitcoinTxModel(
      txid: json['txid'] as String,
      version: json['version'] as int,
      locktime: json['locktime'] as int,
      vin: (json['vin'] as List)
          .map((v) => VinModel.fromJson(v as Map<String, dynamic>))
          .toList(),
      vout: (json['vout'] as List)
          .map((v) => VoutModel.fromJson(v as Map<String, dynamic>))
          .toList(),
      size: json['size'] as int,
      weight: json['weight'] as int,
      fee: json['fee'] as int,
      status: StatusModel.fromJson(json['status'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'txid': txid,
        'version': version,
        'locktime': locktime,
        'vin': vin.map((v) => v.toJson()).toList(),
        'vout': vout.map((v) => v.toJson()).toList(),
        'size': size,
        'weight': weight,
        'fee': fee,
        'status': status.toJson(),
      };

  BitcoinTx toDomain() => BitcoinTx(
        txid: txid,
        version: version,
        locktime: locktime,
        vin: vin.map((v) => v.toDomain()).toList(),
        vout: vout.map((v) => v.toDomain()).toList(),
        size: size,
        weight: weight,
        fee: fee,
        status: status.toDomain(),
      );
}
