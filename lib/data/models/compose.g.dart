// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compose.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComposeDispenseParamsModel _$ComposeDispenseParamsModelFromJson(
        Map<String, dynamic> json) =>
    ComposeDispenseParamsModel(
      address: json['address'] as String,
      dispenser: json['dispenser'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$ComposeDispenseParamsModelToJson(
        ComposeDispenseParamsModel instance) =>
    <String, dynamic>{
      'address': instance.address,
      'dispenser': instance.dispenser,
      'quantity': instance.quantity,
    };

ComposeDispenseResponseParamsModel _$ComposeDispenseResponseParamsModelFromJson(
        Map<String, dynamic> json) =>
    ComposeDispenseResponseParamsModel(
      source: json['source'] as String,
      destination: json['destination'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$ComposeDispenseResponseParamsModelToJson(
        ComposeDispenseResponseParamsModel instance) =>
    <String, dynamic>{
      'source': instance.source,
      'destination': instance.destination,
      'quantity': instance.quantity,
    };

ComposeDispenseResponseModel _$ComposeDispenseResponseModelFromJson(
        Map<String, dynamic> json) =>
    ComposeDispenseResponseModel(
      params: ComposeDispenseResponseParamsModel.fromJson(
          json['params'] as Map<String, dynamic>),
      rawtransaction: json['rawtransaction'] as String,
      psbt: json['psbt'] as String,
      name: json['name'] as String,
      btcIn: (json['btc_in'] as num).toInt(),
      btcOut: (json['btc_out'] as num).toInt(),
      btcChange: (json['btc_change'] as num?)?.toInt(),
      btcFee: (json['btc_fee'] as num).toInt(),
      signedTxEstimatedSize: SignedTxEstimatedSizeModel.fromJson(
          json['signed_tx_estimated_size'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ComposeDispenseResponseModelToJson(
        ComposeDispenseResponseModel instance) =>
    <String, dynamic>{
      'rawtransaction': instance.rawtransaction,
      'psbt': instance.psbt,
      'name': instance.name,
      'btc_in': instance.btcIn,
      'btc_out': instance.btcOut,
      'btc_change': instance.btcChange,
      'btc_fee': instance.btcFee,
      'signed_tx_estimated_size': instance.signedTxEstimatedSize,
      'params': instance.params,
    };
