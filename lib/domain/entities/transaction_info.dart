import "transaction_unpacked.dart";

abstract class TransactionInfoDomain {}

class TransactionInfoDomainLocal extends TransactionInfoDomain {
  final String raw;
  TransactionInfoDomainLocal({required this.raw});
}

class TransactionInfoDomainMempool extends TransactionInfoDomain {}

class TransactionInfoDomainConfirmed extends TransactionInfoDomain {
  final int blockHeight;
  final int blockTime;
  final int confirmations;
  TransactionInfoDomainConfirmed(
      {required this.blockHeight,
      required this.blockTime,
      required this.confirmations});
}

class TransactionInfo {
  final String hash;
  final String source;
  final String? destination;
  final int btcAmount;
  final int fee;
  final String data;
  final TransactionInfoDomain domain;

  final TransactionUnpacked unpackedData;

  const TransactionInfo(
      {required this.hash,
      required this.source,
      required this.destination,
      required this.btcAmount,
      required this.fee,
      required this.data,
      required this.unpackedData,
      required this.domain});
}
