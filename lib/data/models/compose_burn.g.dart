// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compose_burn.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComposeBurnResponseModel _$ComposeBurnResponseModelFromJson(
        Map<String, dynamic> json) =>
    ComposeBurnResponseModel(
      rawtransaction: json['rawtransaction'] as String,
      params: ComposeBurnParamsModel.fromJson(
          json['params'] as Map<String, dynamic>),
      name: json['name'] as String,
      btcIn: (json['btc_in'] as num).toInt(),
      btcOut: (json['btc_out'] as num).toInt(),
      btcChange: (json['btc_change'] as num?)?.toInt(),
      btcFee: (json['btc_fee'] as num).toInt(),
      data: json['data'] as String?,
      signedTxEstimatedSize: SignedTxEstimatedSizeModel.fromJson(
          json['signed_tx_estimated_size'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ComposeBurnResponseModelToJson(
        ComposeBurnResponseModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'data': instance.data,
      'btc_in': instance.btcIn,
      'btc_out': instance.btcOut,
      'btc_change': instance.btcChange,
      'btc_fee': instance.btcFee,
      'rawtransaction': instance.rawtransaction,
      'params': instance.params,
      'signed_tx_estimated_size': instance.signedTxEstimatedSize,
    };

ComposeBurnParamsModel _$ComposeBurnParamsModelFromJson(
        Map<String, dynamic> json) =>
    ComposeBurnParamsModel(
      source: json['source'] as String,
      quantity: (json['quantity'] as num).toInt(),
      overburn: json['overburn'] as bool,
      skipValidation: json['skip_validation'] as bool,
    );

Map<String, dynamic> _$ComposeBurnParamsModelToJson(
        ComposeBurnParamsModel instance) =>
    <String, dynamic>{
      'source': instance.source,
      'quantity': instance.quantity,
      'overburn': instance.overburn,
      'skip_validation': instance.skipValidation,
    };
