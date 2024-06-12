class Utxo {
  final int vout;
  final int height;
  final int value;
  final int confirmations;
  final double amount;
  final String txid;

  Utxo(
      {required this.vout,
      required this.height,
      required this.value,
      required this.confirmations,
      required this.amount,
      required this.txid});
}
