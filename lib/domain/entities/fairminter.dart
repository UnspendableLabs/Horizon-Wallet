import 'package:equatable/equatable.dart';

class Fairminter extends Equatable {
  final String txHash;
  final int? txIndex;
  final int? blockIndex;
  final String source;
  final String? asset;
  final String? assetParent;
  final String? assetLongname;
  final String? description;
  final int? price;
  final int? quantityByPrice;
  final int? hardCap;
  final bool? burnPayment;
  final int? maxMintPerTx;
  final int? premintQuantity;
  final int? startBlock;
  final int? endBlock;
  final int? mintedAssetCommissionInt;
  final int? softCap;
  final int? softCapDeadlineBlock;
  final bool? lockDescription;
  final bool? lockQuantity;
  final bool? divisible;
  final bool? preMinted;
  final String? status;
  final int? earnedQuantity;
  final int? commission;
  final int? paidQuantity;
  final bool? confirmed;
  final int? blockTime;

  const Fairminter({
    required this.txHash,
    required this.txIndex,
    this.blockIndex,
    required this.source,
    required this.asset,
    this.assetParent,
    this.assetLongname,
    this.description,
    this.price,
    required this.quantityByPrice,
    required this.hardCap,
    this.burnPayment,
    required this.maxMintPerTx,
    required this.premintQuantity,
    required this.startBlock,
    required this.endBlock,
    required this.mintedAssetCommissionInt,
    required this.softCap,
    required this.softCapDeadlineBlock,
    this.lockDescription,
    this.lockQuantity,
    this.divisible,
    this.preMinted,
    this.status,
    this.earnedQuantity,
    this.commission,
    this.paidQuantity,
    this.confirmed,
    this.blockTime,
  });

  @override
  List<Object?> get props => [txHash];
}
