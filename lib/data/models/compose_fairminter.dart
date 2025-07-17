import 'package:horizon/data/models/signed_tx_estimated_size.dart';
import 'package:horizon/domain/entities/compose_fairminter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'compose_fairminter.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeFairminterVerboseModel {
  final String name;
  final String data;
  final int btcIn;
  final int btcOut;
  final int? btcChange;
  final int btcFee;
  final String rawtransaction;
  final String psbt;
  final ComposeFairminterVerboseParamsModel params;
  final SignedTxEstimatedSizeModel signedTxEstimatedSize;

  ComposeFairminterVerboseModel({
    required this.rawtransaction,
    required this.psbt,
    required this.params,
    required this.name,
    required this.btcIn,
    required this.btcOut,
    this.btcChange,
    required this.btcFee,
    required this.data,
    required this.signedTxEstimatedSize,
  });

  factory ComposeFairminterVerboseModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeFairminterVerboseModelFromJson(json);

  ComposeFairminterResponse toDomain() => ComposeFairminterResponse(
        rawtransaction: rawtransaction,
        psbt: psbt,
        name: name,
        data: data,
        btcIn: btcIn,
        btcOut: btcOut,
        btcChange: btcChange,
        btcFee: btcFee,
        params: params.toDomain(),
        signedTxEstimatedSize: signedTxEstimatedSize.toDomain(),
      );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeFairminterVerboseParamsModel {
  final String source;
  final String asset;
  final String? assetParent;
  final int? price;
  final int? quantityByPrice;
  final int? maxMintPerTx;
  final int? hardCap;
  final int? premintQuantity;
  final int? startBlock;
  final int? endBlock;
  final int? softCap;
  final int? softCapDeadlineBlock;
  final int? mintedAssetCommission;
  final bool? burnPayment;
  final bool? lockDescription;
  final bool? lockQuantity;
  final bool? divisible;
  final String? description;
  final String? maxMintPerTxNormalized;
  final String? hardCapNormalized;

  ComposeFairminterVerboseParamsModel({
    required this.source,
    required this.asset,
    this.assetParent,
    this.price,
    this.quantityByPrice,
    this.maxMintPerTx,
    this.hardCap,
    this.premintQuantity,
    this.startBlock,
    this.endBlock,
    this.softCap,
    this.softCapDeadlineBlock,
    this.mintedAssetCommission,
    this.burnPayment,
    this.lockDescription,
    this.lockQuantity,
    this.divisible,
    this.description,
    this.maxMintPerTxNormalized,
    this.hardCapNormalized,
  });

  factory ComposeFairminterVerboseParamsModel.fromJson(
          Map<String, dynamic> json) =>
      _$ComposeFairminterVerboseParamsModelFromJson(json);

  ComposeFairminterParams toDomain() => ComposeFairminterParams(
        source: source,
        asset: asset,
        assetParent: assetParent,
        price: price,
        quantityByPrice: quantityByPrice,
        maxMintPerTx: maxMintPerTx,
        hardCap: hardCap,
        premintQuantity: premintQuantity,
        startBlock: startBlock,
        endBlock: endBlock,
        softCap: softCap,
        softCapDeadlineBlock: softCapDeadlineBlock,
        mintedAssetCommission: mintedAssetCommission,
        burnPayment: burnPayment,
        lockQuantity: lockQuantity,
        divisible: divisible,
        maxMintPerTxNormalized: maxMintPerTxNormalized,
        hardCapNormalized: hardCapNormalized,
      );
}
