// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compose_movetoutxo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComposeMoveToUtxoResponseModel _$ComposeMoveToUtxoResponseModelFromJson(
        Map<String, dynamic> json) =>
    ComposeMoveToUtxoResponseModel(
      rawtransaction: json['rawtransaction'] as String,
      params: ComposeMoveToUtxoResponseParamsModel.fromJson(
          json['params'] as Map<String, dynamic>),
      name: json['name'] as String,
      btcIn: (json['btc_in'] as num).toInt(),
      btcOut: (json['btc_out'] as num).toInt(),
      btcChange: (json['btc_change'] as num).toInt(),
      btcFee: (json['btc_fee'] as num).toInt(),
      data: json['data'] as String?,
    );

Map<String, dynamic> _$ComposeMoveToUtxoResponseModelToJson(
        ComposeMoveToUtxoResponseModel instance) =>
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

ComposeMoveToUtxoResponseParamsModel
    _$ComposeMoveToUtxoResponseParamsModelFromJson(Map<String, dynamic> json) =>
        ComposeMoveToUtxoResponseParamsModel(
          source: json['source'] as String,
          destination: json['destination'] as String,
          skipValidation: json['skip_validation'] as bool,
        );

Map<String, dynamic> _$ComposeMoveToUtxoResponseParamsModelToJson(
        ComposeMoveToUtxoResponseParamsModel instance) =>
    <String, dynamic>{
      'source': instance.source,
      'destination': instance.destination,
      'skip_validation': instance.skipValidation,
    };
