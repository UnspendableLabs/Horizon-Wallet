// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compose_detach_utxo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComposeDetachUtxoResponseModel _$ComposeDetachUtxoResponseModelFromJson(
        Map<String, dynamic> json) =>
    ComposeDetachUtxoResponseModel(
      rawtransaction: json['rawtransaction'] as String,
      params: ComposeDetachUtxoResponseParamsModel.fromJson(
          json['params'] as Map<String, dynamic>),
      name: json['name'] as String,
      btcIn: (json['btc_in'] as num).toInt(),
      btcOut: (json['btc_out'] as num).toInt(),
      btcChange: (json['btc_change'] as num).toInt(),
      btcFee: (json['btc_fee'] as num).toInt(),
      data: json['data'] as String,
    );

Map<String, dynamic> _$ComposeDetachUtxoResponseModelToJson(
        ComposeDetachUtxoResponseModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'data': instance.data,
      'btc_in': instance.btcIn,
      'btc_out': instance.btcOut,
      'btc_change': instance.btcChange,
      'btc_fee': instance.btcFee,
      'rawtransaction': instance.rawtransaction,
      'params': instance.params,
    };

ComposeDetachUtxoResponseParamsModel
    _$ComposeDetachUtxoResponseParamsModelFromJson(Map<String, dynamic> json) =>
        ComposeDetachUtxoResponseParamsModel(
          source: json['source'] as String,
          destination: json['destination'] as String,
          skipValidation: json['skip_validation'] as bool,
        );

Map<String, dynamic> _$ComposeDetachUtxoResponseParamsModelToJson(
        ComposeDetachUtxoResponseParamsModel instance) =>
    <String, dynamic>{
      'source': instance.source,
      'destination': instance.destination,
      'skip_validation': instance.skipValidation,
    };
