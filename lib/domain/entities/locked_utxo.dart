class LockedUtxo {
  final String id;
  final String txHash;
  final String txid;
  final int vout;
  final String address;
  final int value;
  final DateTime lockedAt;

  LockedUtxo({
    required this.id,
    required this.txHash,
    required this.txid,
    required this.vout,
    required this.address,
    required this.value,
    required this.lockedAt,
  });
}
