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
}
