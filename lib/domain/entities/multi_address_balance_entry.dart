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
}
