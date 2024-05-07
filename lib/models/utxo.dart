class UniUTXO {
  /**
   * {"vout": 1, "height": 2588388, "value":
500000, "confirmations": 222760, "amount": 0.005, "txid":
"2230518d56744d03aca65fa09f58b1e9217cc5ce0521738bb2163b3bf8fa0261"}
   */
  int vout;
  int height;
  int value;
  int confirmations;
  double amount;
  String txid;

  UniUTXO({
    required this.vout,
    required this.height,
    required this.value,
    required this.confirmations,
    required this.amount,
    required this.txid,
  });

  factory UniUTXO.fromJson(Map<String, dynamic> data) {
    final vout = data['vout'] as int;
    final height = data['height'] as int;
    final value = data['value'] as int;
    final confirmations = data['confirmations'] as int;
    final amount = data['amount'] as double;
    final txid = data['txid'] as String;
    return UniUTXO(vout: vout, height: height, value: value, confirmations: confirmations, amount: amount, txid: txid);
  }
}
