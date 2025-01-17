// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compose_dividend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComposeDividendResponseModel _$ComposeDividendResponseModelFromJson(
        Map<String, dynamic> json) =>
    ComposeDividendResponseModel(
      rawtransaction: json['rawtransaction'] as String,
      params: ComposeDividendParamsModel.fromJson(
          json['params'] as Map<String, dynamic>),
      name: json['name'] as String,
      btcIn: (json['btc_in'] as num).toInt(),
      btcOut: (json['btc_out'] as num).toInt(),
      btcChange: (json['btc_change'] as num).toInt(),
      btcFee: (json['btc_fee'] as num).toInt(),
      data: json['data'] as String?,
      signedTxEstimatedSize: SignedTxEstimatedSizeModel.fromJson(
          json['signed_tx_estimated_size'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ComposeDividendResponseModelToJson(
        ComposeDividendResponseModel instance) =>
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

ComposeDividendParamsModel _$ComposeDividendParamsModelFromJson(
        Map<String, dynamic> json) =>
    ComposeDividendParamsModel(
      source: json['source'] as String,
      asset: json['asset'] as String,
      quantityPerUnit: (json['quantity_per_unit'] as num).toInt(),
      dividendAsset: json['dividend_asset'] as String,
      quantityPerUnitNormalized: json['quantity_per_unit_normalized'] as String,
      skipValidation: json['skip_validation'] as bool,
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
      dividendAssetInfo: DividendAssetInfoModel.fromJson(
          json['dividend_asset_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ComposeDividendParamsModelToJson(
        ComposeDividendParamsModel instance) =>
    <String, dynamic>{
      'source': instance.source,
      'asset': instance.asset,
      'quantity_per_unit': instance.quantityPerUnit,
      'dividend_asset': instance.dividendAsset,
      'quantity_per_unit_normalized': instance.quantityPerUnitNormalized,
      'skip_validation': instance.skipValidation,
      'asset_info': instance.assetInfo,
      'dividend_asset_info': instance.dividendAssetInfo,
    };
