class BlockCypherResponseWrapper {
  final String address;
  final int totalReceived;
  final int balance;
  final int unconfirmedBalance;
  final int finalBalance;
  final int nTx;
  final int unconfirmedNTx;
  final int finalNTx;

  const BlockCypherResponseWrapper(
      {required this.address,
      required this.totalReceived,
      required this.balance,
      required this.unconfirmedBalance,
      required this.finalBalance,
      required this.nTx,
      required this.unconfirmedNTx,
      required this.finalNTx});

  factory BlockCypherResponseWrapper.fromJson(Map<String, dynamic> data) {
    final address = data['address'] as String;
    final totalReceived = data['total_received'] as int;
    final balance = data['balance'] as int;
    final unconfirmedBalance = data['unconfirmed_balance'] as int;
    final finalBalance = data['final_balance'] as int;
    final nTx = data['n_tx'] as int;
    final unconfirmedNTx = data['unconfirmed_n_tx'] as int;
    final finalNTx = data['final_n_tx'] as int;

    return BlockCypherResponseWrapper(
        address: address,
        totalReceived: totalReceived,
        balance: balance,
        unconfirmedBalance: unconfirmedBalance,
        finalBalance: finalBalance,
        nTx: nTx,
        unconfirmedNTx: unconfirmedNTx,
        finalNTx: finalNTx);
  }
}
