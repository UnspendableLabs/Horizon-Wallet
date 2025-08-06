class MultiAddressBalanceEntry {
  final String? address;
  final int quantity;
  final String quantityNormalized;
  final String? utxo;
  final String? utxoAddress;

  MultiAddressBalanceEntry(
      {required this.address,
      required this.quantity,
      required this.quantityNormalized,
      this.utxo,
      this.utxoAddress});

  @override
  String toString() {
    return 'MultiAddressBalanceEntry { '
        'address: ${address ?? "null"}, '
        'quantity (raw): $quantity, '
        'quantityNormalized: $quantityNormalized, '
        'utxo: ${utxo ?? "null"}, '
        'utxoAddress: ${utxoAddress ?? "null"} '
        '}';
  }
}
