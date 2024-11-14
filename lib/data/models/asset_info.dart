import 'package:json_annotation/json_annotation.dart';
import 'package:horizon/domain/entities/asset_info.dart' as e;
part 'asset_info.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetInfoModel {
  final bool divisible;
  final String? assetLongname;
  final String? description;
  final bool locked;
  final String? issuer;

  AssetInfoModel({
    required this.divisible,
    this.assetLongname,
    required this.description,
    required this.locked,
    this.issuer,
  });

  factory AssetInfoModel.fromJson(Map<String, dynamic> json) =>
      _$AssetInfoModelFromJson(json);

  e.AssetInfo toDomain() {
    return e.AssetInfo(
        divisible: divisible,
        assetLongname: assetLongname,
        description: description,
        issuer: issuer);
  }
}
