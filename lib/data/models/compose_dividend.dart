import 'package:horizon/data/models/asset_info.dart';
import 'package:horizon/data/models/dividend_asset_info.dart';
import 'package:horizon/domain/entities/compose_dividend.dart';
import 'package:json_annotation/json_annotation.dart';

part 'compose_dividend.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeDividendResponseModel {
  final String name;
  final String? data;
  final int btcIn;
  final int btcOut;
  final int btcChange;
  final int btcFee;
  final String rawtransaction;
  final ComposeDividendParamsModel params;

  ComposeDividendResponseModel({
    required this.rawtransaction,
    required this.params,
    required this.name,
    required this.btcIn,
    required this.btcOut,
    required this.btcChange,
    required this.btcFee,
    this.data,
  });

  factory ComposeDividendResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeDividendResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ComposeDividendResponseModelToJson(this);

  ComposeDividendResponse toDomain() => ComposeDividendResponse(
        name: name,
        data: data,
        rawtransaction: rawtransaction,
        btcFee: btcFee,
        params: params.toDomain(),
      );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeDividendParamsModel {
  final String source;
  final String asset;
  final int quantityPerUnit;
  final String dividendAsset;
  final String quantityPerUnitNormalized;
  final bool skipValidation;
  final AssetInfoModel assetInfo;
  final DividendAssetInfoModel dividendAssetInfo;

  ComposeDividendParamsModel({
    required this.source,
    required this.asset,
    required this.quantityPerUnit,
    required this.dividendAsset,
    required this.quantityPerUnitNormalized,
    required this.skipValidation,
    required this.assetInfo,
    required this.dividendAssetInfo,
  });

  factory ComposeDividendParamsModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeDividendParamsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ComposeDividendParamsModelToJson(this);

  ComposeDividendResponseParams toDomain() => ComposeDividendResponseParams(
        source: source,
        asset: asset,
        quantityPerUnit: quantityPerUnit,
        dividendAsset: dividendAsset,
        quantityPerUnitNormalized: quantityPerUnitNormalized,
        dividendAssetInfo: dividendAssetInfo.toDomain(),
        assetInfo: assetInfo.toDomain(),
      );
}
