// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compose_fairmint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComposeFairmintVerboseModel _$ComposeFairmintVerboseModelFromJson(
        Map<String, dynamic> json) =>
    ComposeFairmintVerboseModel(
      rawtransaction: json['rawtransaction'] as String,
      params: ComposeFairmintVerboseParamsModel.fromJson(
          json['params'] as Map<String, dynamic>),
      name: json['name'] as String,
      signedTxEstimatedSize: SignedTxEstimatedSizeModel.fromJson(
          json['signed_tx_estimated_size'] as Map<String, dynamic>),
      btcIn: (json['btc_in'] as num).toInt(),
      btcOut: (json['btc_out'] as num).toInt(),
      btcChange: (json['btc_change'] as num?)?.toInt(),
      btcFee: (json['btc_fee'] as num).toInt(),
      data: json['data'] as String,
    );

Map<String, dynamic> _$ComposeFairmintVerboseModelToJson(
        ComposeFairmintVerboseModel instance) =>
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

ComposeFairmintVerboseParamsModel _$ComposeFairmintVerboseParamsModelFromJson(
        Map<String, dynamic> json) =>
    ComposeFairmintVerboseParamsModel(
      source: json['source'] as String,
      asset: (json['asset'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      quantityNormalized: json['quantity_normalized'] as String,
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ComposeFairmintVerboseParamsModelToJson(
        ComposeFairmintVerboseParamsModel instance) =>
    <String, dynamic>{
      'source': instance.source,
      'asset': instance.asset,
      'quantity': instance.quantity,
      'quantity_normalized': instance.quantityNormalized,
      'asset_info': instance.assetInfo,
    };
