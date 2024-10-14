import "package:horizon/domain/entities/dispenser.dart";
import 'package:json_annotation/json_annotation.dart';

part "dispenser.g.dart";

@JsonSerializable(fieldRename: FieldRename.snake)
class DispenserModel extends Dispenser {
  DispenserModel({
    required super.txIndex,
    required super.txHash,
    required super.blockIndex,
    required super.source,
    required super.asset,
    required super.giveQuantity,
    required super.escrowQuantity,
    required super.satoshiRate,
    required super.status,
    required super.giveRemaining,
    super.oracleAddress,
    super.lastStatusTxHash,
    required super.origin,
    required super.dispenseCount,
    super.lastStatusTxSource,
    super.closeBlockIndex,
    required super.confirmed,
    // Verbose fields
    super.blockTime,
    // AssetInfo? assetInfo,
    super.giveQuantityNormalized,
    super.giveRemainingNormalized,
    super.escrowQuantityNormalized,
    super.satoshiRateNormalized,
  });

  /// Connect the generated `fromJson` function with the class constructor.
  factory DispenserModel.fromJson(Map<String, dynamic> json) =>
      _$DispenserModelFromJson(json);

  /// Connect the generated `toJson` function with the class to produce a JSON map.
  Map<String, dynamic> toJson() => _$DispenserModelToJson(this);

   Dispenser toDomain() {
    return Dispenser(
      txIndex: txIndex,
      txHash: txHash,
      blockIndex: blockIndex,
      source: source,
      asset: asset,
      giveQuantity: giveQuantity,
      escrowQuantity: escrowQuantity,
      satoshiRate: satoshiRate,
      status: status,
      giveRemaining: giveRemaining,
      oracleAddress: oracleAddress,
      lastStatusTxHash: lastStatusTxHash,
      origin: origin,
      dispenseCount: dispenseCount,
      lastStatusTxSource: lastStatusTxSource,
      closeBlockIndex: closeBlockIndex,
      confirmed: confirmed,
      blockTime: blockTime,
      giveQuantityNormalized: giveQuantityNormalized,
      giveRemainingNormalized: giveRemainingNormalized,
      escrowQuantityNormalized: escrowQuantityNormalized,
      satoshiRateNormalized: satoshiRateNormalized,
    );
  }
}
