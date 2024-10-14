import "package:horizon/domain/entities/dispenser.dart";
import 'package:json_annotation/json_annotation.dart';

part "dispenser.g.dart";

// DispenserModel class
@JsonSerializable(fieldRename: FieldRename.snake)
class DispenserModel {
  final int txIndex;
  final String txHash;
  final int blockIndex;
  final String source;
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int satoshirate;
  final int status;
  final int giveRemaining;
  final String? oracleAddress;
  final String? lastStatusTxHash;
  final String? closeBlockIndex; // String type
  final String origin;
  final int dispenseCount;
  final String? lastStatusTxSource;
  final bool confirmed;
  // Verbose fields
  final int? blockTime;
  final String? giveQuantityNormalized;
  final String? giveRemainingNormalized;
  final String? escrowQuantityNormalized;
  final String? satoshirateNormalized;

  DispenserModel({
    required this.txIndex,
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
    this.closeBlockIndex,
    required this.origin,
    required this.dispenseCount,
    this.lastStatusTxSource,
    required this.confirmed,
    // Verbose fields
    this.blockTime,
    this.giveQuantityNormalized,
    this.giveRemainingNormalized,
    this.escrowQuantityNormalized,
    this.satoshirateNormalized,
  });

  factory DispenserModel.fromJson(Map<String, dynamic> json) =>
      _$DispenserModelFromJson(json);

  Dispenser toDomain() {
    return Dispenser(
      txIndex: txIndex,
      txHash: txHash,
      blockIndex: blockIndex,
      source: source,
      asset: asset,
      giveQuantity: giveQuantity,
      escrowQuantity: escrowQuantity,
      satoshirate: satoshirate,
      status: status,
      giveRemaining: giveRemaining,
      oracleAddress: oracleAddress,
      lastStatusTxHash: lastStatusTxHash,
      origin: origin,
      dispenseCount: dispenseCount,
      lastStatusTxSource: lastStatusTxSource,
      closeBlockIndex:
          closeBlockIndex != null ? int.tryParse(closeBlockIndex!) : null,
      confirmed: confirmed,
      blockTime: blockTime,
      giveQuantityNormalized: giveQuantityNormalized,
      giveRemainingNormalized: giveRemainingNormalized,
      escrowQuantityNormalized: escrowQuantityNormalized,
      satoshirateNormalized: satoshirateNormalized,
    );
  }
}
