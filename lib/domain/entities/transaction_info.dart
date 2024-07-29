import "transaction_unpacked.dart";
import "package:equatable/equatable.dart";

sealed class TransactionInfoDomain {}

class TransactionInfoDomainLocal extends TransactionInfoDomain {
  final String raw;
  final DateTime submittedAt;
  TransactionInfoDomainLocal({required this.raw, required this.submittedAt});
}

class TransactionInfoDomainMempool extends TransactionInfoDomain {}

class TransactionInfoDomainConfirmed extends TransactionInfoDomain {
  final int blockHeight;
  final int blockTime;
  TransactionInfoDomainConfirmed({
    required this.blockHeight,
    required this.blockTime,
  });
}

class TransactionInfo extends Equatable {
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

  @override
  List<Object?> get props =>
      [hash, source, destination, btcAmount, fee, data, unpackedData, domain];
}
