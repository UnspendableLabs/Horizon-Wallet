class Dispenser {
  final String assetName;
  final String openAddress;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final int status;

  Dispenser({
    required this.assetName,
    required this.openAddress,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.status,
  });
}
