class AddressStats {
  final int txCount;
  final int fundedTxoCount;
  final int fundedTxoSum;
  final int spentTxoCount;
  final int spentTxoSum;

  AddressStats({
    required this.txCount,
    required this.fundedTxoCount,
    required this.fundedTxoSum,
    required this.spentTxoCount,
    required this.spentTxoSum,
  });
}
