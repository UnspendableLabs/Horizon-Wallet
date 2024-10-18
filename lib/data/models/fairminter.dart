import "package:horizon/domain/entities/fairminter.dart";
import 'package:json_annotation/json_annotation.dart';

part "fairminter.g.dart";

@JsonSerializable(fieldRename: FieldRename.snake)
class FairminterModel {
  final String txHash;
  final int txIndex;
  final int? blockIndex;
  final String source;
  final String asset;
  final String? assetParent;
  final String? assetLongname;
  final String? description;
  final int? price;
  final int quantityByPrice;
  final int hardCap;
  final bool? burnPayment;
  final int maxMintPerTx;
  final int premintQuantity;
  final int startBlock;
  final int endBlock;
  final int mintedAssetCommissionInt;
  final int softCap;
  final int softCapDeadlineBlock;
  final bool? lockDescription;
  final bool? lockQuantity;
  final bool? divisible;
  final bool? preMinted;
  final String? status;
  final int? earnedQuantity;
  final int? commission;
  final int paidQuantity;
  final bool? confirmed;
  final int? blockTime;

  const FairminterModel({
    required this.txHash,
    required this.txIndex,
    required this.blockIndex,
    required this.source,
    required this.asset,
    required this.assetParent,
    required this.assetLongname,
    required this.description,
    required this.price,
    required this.quantityByPrice,
    required this.hardCap,
    required this.burnPayment,
    required this.maxMintPerTx,
    required this.premintQuantity,
    required this.startBlock,
    required this.endBlock,
    required this.mintedAssetCommissionInt,
    required this.softCap,
    required this.softCapDeadlineBlock,
    required this.lockDescription,
    required this.lockQuantity,
    required this.divisible,
    required this.preMinted,
    required this.status,
    required this.earnedQuantity,
    required this.commission,
    required this.paidQuantity,
    required this.confirmed,
    required this.blockTime,
  });

  factory FairminterModel.fromJson(Map<String, dynamic> json) =>
      _$FairminterModelFromJson(json);

  Fairminter toDomain() {
    return Fairminter(
      txHash: txHash,
      txIndex: txIndex,
      blockIndex: blockIndex,
      source: source,
      asset: asset,
      assetParent: assetParent,
      assetLongname: assetLongname,
      description: description,
      price: price,
      quantityByPrice: quantityByPrice,
      hardCap: hardCap,
      burnPayment: burnPayment,
      maxMintPerTx: maxMintPerTx,
      premintQuantity: premintQuantity,
      startBlock: startBlock,
      endBlock: endBlock,
      mintedAssetCommissionInt: mintedAssetCommissionInt,
      softCap: softCap,
      softCapDeadlineBlock: softCapDeadlineBlock,
      lockDescription: lockDescription,
      lockQuantity: lockQuantity,
      divisible: divisible,
      preMinted: preMinted,
      status: status,
      earnedQuantity: earnedQuantity,
      commission: commission,
      paidQuantity: paidQuantity,
      confirmed: confirmed,
      blockTime: blockTime,
    );
  }
}
