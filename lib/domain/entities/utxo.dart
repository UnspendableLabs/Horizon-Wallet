class Utxo {
  final int vout;
  final int? height;
  final int value;
  final String txid;
  final String address;

  Utxo(
      {required this.vout,
      required this.height,
      required this.value,
      required this.txid,
      required this.address});
}
