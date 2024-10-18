class Block {
  final int blockIndex;
  final String blockHash;
  final int blockTime;
  final String previousBlockHash;
  final int difficulty;
  final String ledgerHash;
  final String txlistHash;
  final String messagesHash;
  final int transactionCount;
  final bool confirmed;

  const Block(
      {required this.blockIndex,
      required this.blockTime,
      required this.blockHash,
      required this.previousBlockHash,
      required this.difficulty,
      required this.ledgerHash,
      required this.txlistHash,
      required this.messagesHash,
      required this.transactionCount,
      required this.confirmed});
}
