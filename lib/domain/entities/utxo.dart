class Utxo {
  final int vout;
  final int height;
  final int value;
  final int confirmations;
  final double amount;
  final String txid;
  final String address;

  Utxo(
      {required this.vout,
      required this.height,
      required this.value,
      required this.confirmations,
      required this.amount,
      required this.txid,
      required this.address});
}
