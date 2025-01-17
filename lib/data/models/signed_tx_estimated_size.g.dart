// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signed_tx_estimated_size.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignedTxEstimatedSizeModel _$SignedTxEstimatedSizeModelFromJson(
        Map<String, dynamic> json) =>
    SignedTxEstimatedSizeModel(
      vsize: (json['vsize'] as num).toInt(),
      adjustedVsize: (json['adjusted_vsize'] as num).toInt(),
      sigopsCount: (json['sigops_count'] as num).toInt(),
    );

Map<String, dynamic> _$SignedTxEstimatedSizeModelToJson(
        SignedTxEstimatedSizeModel instance) =>
    <String, dynamic>{
      'vsize': instance.vsize,
      'adjusted_vsize': instance.adjustedVsize,
      'sigops_count': instance.sigopsCount,
    };
