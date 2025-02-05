class Transaction {
  final String txHash;
  final int txIndex;
  final int blockIndex;
  final String? blockHash;
  final int blockTime;
  final String source;
  final String? destination;
  final double btcAmount;
  final int fee;
  final String data;
  final bool supported;

  const Transaction({
    required this.txHash,
    required this.txIndex,
    required this.blockIndex,
    required this.blockHash,
    required this.blockTime,
    required this.source,
    required this.destination,
    required this.btcAmount,
    required this.fee,
    required this.data,
    required this.supported,
  });
}
