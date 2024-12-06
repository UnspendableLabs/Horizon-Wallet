// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bitcoin_decoded_tx.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DecodedTxModel _$DecodedTxModelFromJson(Map<String, dynamic> json) =>
    DecodedTxModel(
      txid: json['txid'] as String,
      hash: json['hash'] as String,
      version: (json['version'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      vsize: (json['vsize'] as num).toInt(),
      weight: (json['weight'] as num).toInt(),
      locktime: (json['locktime'] as num).toInt(),
      vin: (json['vin'] as List<dynamic>)
          .map((e) => VinModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      vout: (json['vout'] as List<dynamic>)
          .map((e) => VoutModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DecodedTxModelToJson(DecodedTxModel instance) =>
    <String, dynamic>{
      'txid': instance.txid,
      'hash': instance.hash,
      'version': instance.version,
      'size': instance.size,
      'vsize': instance.vsize,
      'weight': instance.weight,
      'locktime': instance.locktime,
      'vin': instance.vin,
      'vout': instance.vout,
    };

VinModel _$VinModelFromJson(Map<String, dynamic> json) => VinModel(
      txid: json['txid'] as String,
      vout: (json['vout'] as num).toInt(),
      scriptSig:
          ScriptSigModel.fromJson(json['scriptSig'] as Map<String, dynamic>),
      txinwitness: (json['txinwitness'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      sequence: (json['sequence'] as num).toInt(),
    );

Map<String, dynamic> _$VinModelToJson(VinModel instance) => <String, dynamic>{
      'txid': instance.txid,
      'vout': instance.vout,
      'scriptSig': instance.scriptSig,
      'txinwitness': instance.txinwitness,
      'sequence': instance.sequence,
    };

VoutModel _$VoutModelFromJson(Map<String, dynamic> json) => VoutModel(
      value: (json['value'] as num).toDouble(),
      n: (json['n'] as num).toInt(),
      scriptPubKey: ScriptPubKeyModel.fromJson(
          json['scriptPubKey'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VoutModelToJson(VoutModel instance) => <String, dynamic>{
      'value': instance.value,
      'n': instance.n,
      'scriptPubKey': instance.scriptPubKey,
    };

ScriptSigModel _$ScriptSigModelFromJson(Map<String, dynamic> json) =>
    ScriptSigModel(
      asm: json['asm'] as String,
      hex: json['hex'] as String,
    );

Map<String, dynamic> _$ScriptSigModelToJson(ScriptSigModel instance) =>
    <String, dynamic>{
      'asm': instance.asm,
      'hex': instance.hex,
    };

ScriptPubKeyModel _$ScriptPubKeyModelFromJson(Map<String, dynamic> json) =>
    ScriptPubKeyModel(
      asm: json['asm'] as String,
      desc: json['desc'] as String,
      hex: json['hex'] as String,
      address: json['address'] as String?,
      type: json['type'] as String,
    );

Map<String, dynamic> _$ScriptPubKeyModelToJson(ScriptPubKeyModel instance) =>
    <String, dynamic>{
      'asm': instance.asm,
      'desc': instance.desc,
      'hex': instance.hex,
      'address': instance.address,
      'type': instance.type,
    };
