class Issuance {
  final int txIndex;
  final String txHash;
  final int msgIndex;
  final int blockIndex;
  final String asset;
  final int quantity;
  final int divisible;
  final String source;
  final String issuer;
  final int transfer;
  final int callable;
  final int callDate;
  final double callPrice;
  final String description;
  final int feePaid;
  final int locked;
  final String status;
  final String? assetLongname;
  final int reset;

  const Issuance({
    required this.txIndex,
    required this.txHash,
    required this.msgIndex,
    required this.blockIndex,
    required this.asset,
    required this.quantity,
    required this.divisible,
    required this.source,
    required this.issuer,
    required this.transfer,
    required this.callable,
    required this.callDate,
    required this.callPrice,
    required this.description,
    required this.feePaid,
    required this.locked,
    required this.status,
    this.assetLongname,
    required this.reset,
  });
}
