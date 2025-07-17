import 'package:horizon/data/models/asset_info.dart';
import 'package:horizon/data/models/signed_tx_estimated_size.dart';
import 'package:horizon/domain/entities/compose_attach_utxo.dart';
import 'package:json_annotation/json_annotation.dart';

part 'compose_attach_utxo.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeAttachUtxoResponseModel {
  final String name;
  final String data;
  final int btcIn;
  final int btcOut;
  final int btcChange;
  final int btcFee;
  final String rawtransaction;
  final String psbt;
  final ComposeAttachUtxoResponseParamsModel params;
  final SignedTxEstimatedSizeModel signedTxEstimatedSize;

  ComposeAttachUtxoResponseModel({
    required this.psbt,
    required this.rawtransaction,
    required this.params,
    required this.name,
    required this.btcIn,
    required this.btcOut,
    required this.btcChange,
    required this.btcFee,
    required this.data,
    required this.signedTxEstimatedSize,
  });

  factory ComposeAttachUtxoResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeAttachUtxoResponseModelFromJson(json);

  ComposeAttachUtxoResponse toDomain() => ComposeAttachUtxoResponse(
        name: name,
        data: data,
        psbt: psbt,
        rawtransaction: rawtransaction,
        btcFee: btcFee,
        params: params.toDomain(),
        signedTxEstimatedSize: signedTxEstimatedSize.toDomain(),
      );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeAttachUtxoResponseParamsModel {
  final String source;
  final String asset;
  final int quantity;
  final String quantityNormalized;
  final String? destinationVout;
  final AssetInfoModel assetInfo;

  ComposeAttachUtxoResponseParamsModel(
      {required this.source,
      required this.asset,
      required this.quantity,
      required this.quantityNormalized,
      this.destinationVout,
      required this.assetInfo});

  factory ComposeAttachUtxoResponseParamsModel.fromJson(
          Map<String, dynamic> json) =>
      _$ComposeAttachUtxoResponseParamsModelFromJson(json);

  ComposeAttachUtxoResponseParams toDomain() => ComposeAttachUtxoResponseParams(
        source: source,
        asset: asset,
        quantity: quantity,
        quantityNormalized: quantityNormalized,
        destinationVout: destinationVout,
        assetInfo: assetInfo.toDomain(),
      );
}
