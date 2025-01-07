// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compose_sweep.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComposeSweepResponseModel _$ComposeSweepResponseModelFromJson(
        Map<String, dynamic> json) =>
    ComposeSweepResponseModel(
      rawtransaction: json['rawtransaction'] as String,
      params: ComposeSweepParamsModel.fromJson(
          json['params'] as Map<String, dynamic>),
      name: json['name'] as String,
      btcIn: (json['btc_in'] as num).toInt(),
      btcOut: (json['btc_out'] as num).toInt(),
      btcChange: (json['btc_change'] as num).toInt(),
      btcFee: (json['btc_fee'] as num).toInt(),
      data: json['data'] as String?,
    );

Map<String, dynamic> _$ComposeSweepResponseModelToJson(
        ComposeSweepResponseModel instance) =>
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

ComposeSweepParamsModel _$ComposeSweepParamsModelFromJson(
        Map<String, dynamic> json) =>
    ComposeSweepParamsModel(
      source: json['source'] as String,
      destination: json['destination'] as String,
      flags: (json['flags'] as num).toInt(),
      memo: json['memo'] as String,
      skipValidation: json['skip_validation'] as bool,
    );

Map<String, dynamic> _$ComposeSweepParamsModelToJson(
        ComposeSweepParamsModel instance) =>
    <String, dynamic>{
      'source': instance.source,
      'destination': instance.destination,
      'flags': instance.flags,
      'memo': instance.memo,
      'skip_validation': instance.skipValidation,
    };
