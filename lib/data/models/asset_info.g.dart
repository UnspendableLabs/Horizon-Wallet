// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetInfoModel _$AssetInfoModelFromJson(Map<String, dynamic> json) =>
    AssetInfoModel(
      divisible: json['divisible'] as bool,
      assetLongname: json['asset_longname'] as String?,
      description: json['description'] as String,
      locked: json['locked'] as bool,
      issuer: json['issuer'] as String?,
    );

Map<String, dynamic> _$AssetInfoModelToJson(AssetInfoModel instance) =>
    <String, dynamic>{
      'divisible': instance.divisible,
      'asset_longname': instance.assetLongname,
      'description': instance.description,
      'locked': instance.locked,
      'issuer': instance.issuer,
    };
