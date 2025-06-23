class AtomicSwap {
  final String id;

  final String assetName;
  final BigInt assetQuantity;
  final BigInt price;
  final BigInt pricePerUnit;

  AtomicSwap(
      {required this.id,
      required this.assetName,
      required this.assetQuantity,
      required this.price,
      required this.pricePerUnit});

  @override
  String toString() {
    return 'AtomicSwap('
        'id: $id, '
        'assetName: $assetName, '
        'assetQuantity: $assetQuantity, '
        'price: $price, '
        'pricePerUnit: $pricePerUnit'
        ')';
  }
}
