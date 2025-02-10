// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compose_attach_utxo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComposeAttachUtxoResponseModel _$ComposeAttachUtxoResponseModelFromJson(
        Map<String, dynamic> json) =>
    ComposeAttachUtxoResponseModel(
      rawtransaction: json['rawtransaction'] as String,
      params: ComposeAttachUtxoResponseParamsModel.fromJson(
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

Map<String, dynamic> _$ComposeAttachUtxoResponseModelToJson(
        ComposeAttachUtxoResponseModel instance) =>
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

ComposeAttachUtxoResponseParamsModel
    _$ComposeAttachUtxoResponseParamsModelFromJson(Map<String, dynamic> json) =>
        ComposeAttachUtxoResponseParamsModel(
          source: json['source'] as String,
          asset: json['asset'] as String,
          quantity: (json['quantity'] as num).toInt(),
          quantityNormalized: json['quantity_normalized'] as String,
          destinationVout: json['destination_vout'] as String?,
          assetInfo: AssetInfoModel.fromJson(
              json['asset_info'] as Map<String, dynamic>),
          utxoValue: (json['utxo_value'] as num?)?.toInt(),
        );

Map<String, dynamic> _$ComposeAttachUtxoResponseParamsModelToJson(
        ComposeAttachUtxoResponseParamsModel instance) =>
    <String, dynamic>{
      'source': instance.source,
      'asset': instance.asset,
      'quantity': instance.quantity,
      'quantity_normalized': instance.quantityNormalized,
      'destination_vout': instance.destinationVout,
      'asset_info': instance.assetInfo,
      'utxo_value': instance.utxoValue,
    };
