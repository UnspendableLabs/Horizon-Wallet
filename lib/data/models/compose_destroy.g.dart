// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compose_destroy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComposeDestroyResponseModel _$ComposeDestroyResponseModelFromJson(
        Map<String, dynamic> json) =>
    ComposeDestroyResponseModel(
      psbt: json['psbt'] as String,
      rawtransaction: json['rawtransaction'] as String,
      params: ComposeDestroyParamsModel.fromJson(
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

Map<String, dynamic> _$ComposeDestroyResponseModelToJson(
        ComposeDestroyResponseModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'data': instance.data,
      'btc_in': instance.btcIn,
      'btc_out': instance.btcOut,
      'btc_change': instance.btcChange,
      'btc_fee': instance.btcFee,
      'rawtransaction': instance.rawtransaction,
      'psbt': instance.psbt,
      'params': instance.params,
      'signed_tx_estimated_size': instance.signedTxEstimatedSize,
    };

ComposeDestroyParamsModel _$ComposeDestroyParamsModelFromJson(
        Map<String, dynamic> json) =>
    ComposeDestroyParamsModel(
      source: json['source'] as String,
      asset: json['asset'] as String,
      quantity: (json['quantity'] as num).toInt(),
      quantityNormalized: json['quantity_normalized'] as String,
      tag: json['tag'] as String,
      skipValidation: json['skip_validation'] as bool,
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ComposeDestroyParamsModelToJson(
        ComposeDestroyParamsModel instance) =>
    <String, dynamic>{
      'source': instance.source,
      'asset': instance.asset,
      'quantity': instance.quantity,
      'quantity_normalized': instance.quantityNormalized,
      'tag': instance.tag,
      'skip_validation': instance.skipValidation,
      'asset_info': instance.assetInfo,
    };
