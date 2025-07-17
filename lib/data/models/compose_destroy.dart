import 'package:horizon/data/models/asset_info.dart';
import 'package:horizon/data/models/signed_tx_estimated_size.dart';
import 'package:horizon/domain/entities/compose_destroy.dart';
import 'package:json_annotation/json_annotation.dart';

part 'compose_destroy.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeDestroyResponseModel {
  final String name;
  final String? data;
  final int btcIn;
  final int btcOut;
  int? btcChange;
  final int btcFee;
  final String rawtransaction;
  final String psbt;
  final ComposeDestroyParamsModel params;
  final SignedTxEstimatedSizeModel signedTxEstimatedSize;

  ComposeDestroyResponseModel({
    required this.psbt,
    required this.rawtransaction,
    required this.params,
    required this.name,
    required this.btcIn,
    required this.btcOut,
    this.btcChange,
    required this.btcFee,
    this.data,
    required this.signedTxEstimatedSize,
  });

  factory ComposeDestroyResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeDestroyResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ComposeDestroyResponseModelToJson(this);

  ComposeDestroyResponse toDomain() => ComposeDestroyResponse(
        name: name,
        data: data,
        rawtransaction: rawtransaction,
        psbt: psbt,
        btcFee: btcFee,
        params: params.toDomain(),
        signedTxEstimatedSize: signedTxEstimatedSize.toDomain(),
      );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeDestroyParamsModel {
  final String source;
  final String asset;
  final int quantity;
  final String quantityNormalized;
  final String tag;
  final bool skipValidation;
  final AssetInfoModel assetInfo;

  ComposeDestroyParamsModel({
    required this.source,
    required this.asset,
    required this.quantity,
    required this.quantityNormalized,
    required this.tag,
    required this.skipValidation,
    required this.assetInfo,
  });

  factory ComposeDestroyParamsModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeDestroyParamsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ComposeDestroyParamsModelToJson(this);

  ComposeDestroyResponseParams toDomain() => ComposeDestroyResponseParams(
        source: source,
        asset: asset,
        quantity: quantity,
        quantityNormalized: quantityNormalized,
        tag: tag,
        skipValidation: skipValidation,
        assetInfo: assetInfo.toDomain(),
      );
}
