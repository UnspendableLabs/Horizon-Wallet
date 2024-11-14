import "package:horizon/domain/entities/order.dart" as d;
import 'package:freezed_annotation/freezed_annotation.dart';

part "order.g.dart";

@JsonSerializable(fieldRename: FieldRename.snake)
class Order {
  final int? txIndex;
  final String txHash;
  final int? blockIndex;
  final String source;
  final String giveAsset;
  final int giveQuantity;
  final int giveRemaining;
  final String getAsset;
  final int getQuantity;
  final int getRemaining;
  final int expiration;
  final int expireIndex;
  final int feeRequired;
  final int feeRequiredRemaining;
  final int feeProvided;
  final int feeProvidedRemaining;
  final String status;
  final int givePrice;
  final int getPrice;
  final bool confirmed;

  Order({
    this.txIndex,
    required this.txHash,
    this.blockIndex,
    required this.source,
    required this.giveAsset,
    required this.giveQuantity,
    required this.giveRemaining,
    required this.getAsset,
    required this.getQuantity,
    required this.getRemaining,
    required this.expiration,
    required this.expireIndex,
    required this.feeRequired,
    required this.feeRequiredRemaining,
    required this.feeProvided,
    required this.feeProvidedRemaining,
    required this.status,
    required this.givePrice,
    required this.getPrice,
    required this.confirmed,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderVerbose extends Order {
  // final AssetInfo giveAssetInfo;
  // final AssetInfo getAssetInfo;
  final String giveQuantityNormalized;
  final String getQuantityNormalized;
  final String getRemainingNormalized;
  final String giveRemainingNormalized;
  final String feeProvidedNormalized;
  final String feeRequiredNormalized;
  final String feeRequiredRemainingNormalized;
  final String feeProvidedRemainingNormalized;
  final String givePriceNormalized;
  final String getPriceNormalized;

  OrderVerbose({
    super.txIndex,
    required super.txHash,
    super.blockIndex,
    required super.source,
    required super.giveAsset,
    required super.giveQuantity,
    required super.giveRemaining,
    required super.getAsset,
    required super.getQuantity,
    required super.getRemaining,
    required super.expiration,
    required super.expireIndex,
    required super.feeRequired,
    required super.feeRequiredRemaining,
    required super.feeProvided,
    required super.feeProvidedRemaining,
    required super.status,
    required super.givePrice,
    required super.getPrice,
    required super.confirmed,
    // required this.giveAssetInfo,
    // required this.getAssetInfo,
    required this.giveQuantityNormalized,
    required this.getQuantityNormalized,
    required this.getRemainingNormalized,
    required this.giveRemainingNormalized,
    required this.feeProvidedNormalized,
    required this.feeRequiredNormalized,
    required this.feeRequiredRemainingNormalized,
    required this.feeProvidedRemainingNormalized,
    required this.givePriceNormalized,
    required this.getPriceNormalized,
  });

  factory OrderVerbose.fromJson(Map<String, dynamic> json) =>
      _$OrderVerboseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OrderVerboseToJson(this);

  d.Order toDomain() {
    return d.Order(
        txHash: txHash,
        source: source,
        giveAsset: giveAsset,
        giveQuantity: giveQuantity,
        giveRemaining: giveRemaining,
        getAsset: getAsset,
        getQuantity: getQuantity,
        getRemaining: getRemaining,
        expiration: expiration,
        expireIndex: expireIndex,
        feeRequired: feeRequired,
        feeRequiredRemaining: feeRequiredRemaining,
        feeProvided: feeProvided,
        feeProvidedRemaining: feeProvidedRemaining,
        status: status,
        givePrice: givePrice,
        getPrice: getPrice,
        confirmed: confirmed,
        giveQuantityNormalized: giveQuantityNormalized,
        getQuantityNormalized: getQuantityNormalized,
        getRemainingNormalized: getRemainingNormalized,
        giveRemainingNormalized: giveRemainingNormalized,
        feeProvidedNormalized: feeProvidedNormalized,
        feeRequiredNormalized: feeRequiredNormalized,
        feeRequiredRemainingNormalized: feeRequiredRemainingNormalized,
        feeProvidedRemainingNormalized: feeProvidedRemainingNormalized,
        givePriceNormalized: givePriceNormalized,
        getPriceNormalized: getPriceNormalized);
  }
}
