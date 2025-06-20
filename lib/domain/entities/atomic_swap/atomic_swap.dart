class AtomicSwap {
  final String assetName;
  final BigInt assetQuantity;
  final BigInt price;
  final BigInt pricePerUnit;

  AtomicSwap(
      {required this.assetName,
      required this.assetQuantity,
      required this.price,
      required this.pricePerUnit});
}
