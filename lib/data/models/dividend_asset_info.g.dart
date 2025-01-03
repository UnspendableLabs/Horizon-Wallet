// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dividend_asset_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DividendAssetInfoModel _$DividendAssetInfoModelFromJson(
        Map<String, dynamic> json) =>
    DividendAssetInfoModel(
      divisible: json['divisible'] as bool,
      assetLongname: json['asset_longname'] as String?,
      description: json['description'] as String?,
      locked: json['locked'] as bool,
      issuer: json['issuer'] as String?,
    );

Map<String, dynamic> _$DividendAssetInfoModelToJson(
        DividendAssetInfoModel instance) =>
    <String, dynamic>{
      'divisible': instance.divisible,
      'asset_longname': instance.assetLongname,
      'description': instance.description,
      'locked': instance.locked,
      'issuer': instance.issuer,
    };
