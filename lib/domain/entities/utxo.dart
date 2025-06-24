class UtxoID {
  final int vout;
  final String txid;

  UtxoID({required this.vout, required this.txid});

}

class Utxo {
  final int vout;
  final int? height;
  final int value;
  final String txid;
  final String address;

  Utxo(
      {required this.vout,
      this.height,
      required this.value,
      required this.txid,
      required this.address});
  @override
  String toString() {
    return 'Utxo(vout: $vout, height: $height, value: $value, txid: $txid, address: $address)';
  }
}
