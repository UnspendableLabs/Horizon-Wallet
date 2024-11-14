// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compose_cancel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComposeCancelResponseModel _$ComposeCancelResponseModelFromJson(
        Map<String, dynamic> json) =>
    ComposeCancelResponseModel(
      rawtransaction: json['rawtransaction'] as String,
      params: ComposeCancelResponseParamsModel.fromJson(
          json['params'] as Map<String, dynamic>),
      name: json['name'] as String,
      btcIn: (json['btc_in'] as num).toInt(),
      btcOut: (json['btc_out'] as num).toInt(),
      btcChange: (json['btc_change'] as num).toInt(),
      btcFee: (json['btc_fee'] as num).toInt(),
      data: json['data'] as String,
    );

Map<String, dynamic> _$ComposeCancelResponseModelToJson(
        ComposeCancelResponseModel instance) =>
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

ComposeCancelResponseParamsModel _$ComposeCancelResponseParamsModelFromJson(
        Map<String, dynamic> json) =>
    ComposeCancelResponseParamsModel(
      source: json['source'] as String,
      offerHash: json['offer_hash'] as String,
    );

Map<String, dynamic> _$ComposeCancelResponseParamsModelToJson(
        ComposeCancelResponseParamsModel instance) =>
    <String, dynamic>{
      'source': instance.source,
      'offer_hash': instance.offerHash,
    };
