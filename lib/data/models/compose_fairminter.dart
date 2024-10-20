import 'package:horizon/domain/entities/compose_fairminter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'compose_fairminter.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeFairminterVerboseModel {
  final String name;
  final String data;
  final int btcIn;
  final int btcOut;
  final int btcChange;
  final int btcFee;
  final String rawtransaction;
  final ComposeFairminterVerboseParamsModel params;
  // final FairmintUnpackedVerbose unpackedData;

  ComposeFairminterVerboseModel({
    required this.rawtransaction,
    required this.params,
    required this.name,
    // required this.unpackedData,
    required this.btcIn,
    required this.btcOut,
    required this.btcChange,
    required this.btcFee,
    required this.data,
  });

  factory ComposeFairminterVerboseModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeFairminterVerboseModelFromJson(json);

  ComposeFairminterResponse toDomain() => ComposeFairminterResponse(
        rawtransaction: rawtransaction,
        name: name,
        data: data,
        btcIn: btcIn,
        btcOut: btcOut,
        btcChange: btcChange,
        btcFee: btcFee,
        params: params.toDomain(),
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
        divisible: divisible,
      );
}
