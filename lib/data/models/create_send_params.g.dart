// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_send_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendAssetParams _$SendAssetParamsFromJson(Map<String, dynamic> json) =>
    SendAssetParams(
      source: json['source'] as String,
      destination: json['destination'] as String,
      asset: json['asset'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$SendAssetParamsToJson(SendAssetParams instance) =>
    <String, dynamic>{
      'source': instance.source,
      'destination': instance.destination,
      'asset': instance.asset,
      'quantity': instance.quantity,
    };
