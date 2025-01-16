// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compose_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComposeOrderResponseModel _$ComposeOrderResponseModelFromJson(
        Map<String, dynamic> json) =>
    ComposeOrderResponseModel(
      rawtransaction: json['rawtransaction'] as String,
      params: ComposeOrderResponseParamsModel.fromJson(
          json['params'] as Map<String, dynamic>),
      name: json['name'] as String,
      btcIn: (json['btc_in'] as num).toInt(),
      btcOut: (json['btc_out'] as num).toInt(),
      btcChange: (json['btc_change'] as num).toInt(),
      btcFee: (json['btc_fee'] as num).toInt(),
      data: json['data'] as String,
      signedTxEstimatedSize: SignedTxEstimatedSizeModel.fromJson(
          json['signed_tx_estimated_size'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ComposeOrderResponseModelToJson(
        ComposeOrderResponseModel instance) =>
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

ComposeOrderResponseParamsModel _$ComposeOrderResponseParamsModelFromJson(
        Map<String, dynamic> json) =>
    ComposeOrderResponseParamsModel(
      source: json['source'] as String,
      giveAsset: json['give_asset'] as String,
      giveQuantity: (json['give_quantity'] as num).toInt(),
      giveQuantityNormalized: json['give_quantity_normalized'] as String,
      getQuantity: (json['get_quantity'] as num).toInt(),
      getQuantityNormalized: json['get_quantity_normalized'] as String,
      getAsset: json['get_asset'] as String,
    );

Map<String, dynamic> _$ComposeOrderResponseParamsModelToJson(
        ComposeOrderResponseParamsModel instance) =>
    <String, dynamic>{
      'source': instance.source,
      'give_asset': instance.giveAsset,
      'give_quantity': instance.giveQuantity,
      'give_quantity_normalized': instance.giveQuantityNormalized,
      'get_quantity': instance.getQuantity,
      'get_quantity_normalized': instance.getQuantityNormalized,
      'get_asset': instance.getAsset,
    };
