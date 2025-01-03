import 'package:json_annotation/json_annotation.dart';
import 'package:horizon/domain/entities/dividend_asset_info.dart';
part 'dividend_asset_info.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DividendAssetInfoModel {
  final bool divisible;
  final String? assetLongname;
  final String? description;
  final bool locked;
  final String? issuer;

  DividendAssetInfoModel({
    required this.divisible,
    this.assetLongname,
    required this.description,
    required this.locked,
    this.issuer,
  });

  factory DividendAssetInfoModel.fromJson(Map<String, dynamic> json) =>
      _$DividendAssetInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$DividendAssetInfoModelToJson(this);

  DividendAssetInfo toDomain() {
    return DividendAssetInfo(
        divisible: divisible,
        assetLongname: assetLongname,
        description: description,
        issuer: issuer);
  }
}
