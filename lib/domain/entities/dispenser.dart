import "package:horizon/domain/entities/asset_info.dart";

class Dispenser {
  final int txIndex;
  final String txHash;
  final int? blockIndex;
  final String source;
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int satoshirate;
  final int status;
  final int giveRemaining;
  final String? oracleAddress;
  final String? lastStatusTxHash;
  final String origin;
  final int dispenseCount;
  final String? lastStatusTxSource;
  final int? closeBlockIndex;
  final bool? confirmed;

  final int? blockTime;
  final String giveQuantityNormalized;
  final String giveRemainingNormalized;
  final String escrowQuantityNormalized;
  final String satoshirateNormalized;
  final AssetInfo assetInfo;

  Dispenser(
      {required this.txIndex,
      required this.txHash,
      required this.blockIndex,
      required this.source,
      required this.asset,
      required this.giveQuantity,
      required this.escrowQuantity,
      required this.satoshirate,
      required this.status,
      required this.giveRemaining,
      this.oracleAddress,
      this.lastStatusTxHash,
      required this.origin,
      required this.dispenseCount,
      this.lastStatusTxSource,
      this.closeBlockIndex,
      this.confirmed,
      // Verbose fields
      this.blockTime,
      // this.assetInfo,
      required this.giveQuantityNormalized,
      required this.giveRemainingNormalized,
      required this.escrowQuantityNormalized,
      required this.satoshirateNormalized,
      required this.assetInfo});
}
