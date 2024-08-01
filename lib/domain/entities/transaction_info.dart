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
  final int? btcAmount;
  final int? fee;
  final String data;
  final TransactionInfoDomain domain;

  final TransactionUnpacked? unpackedData;

  const TransactionInfo(
      {required this.hash,
      required this.source,
      required this.destination,
      required this.btcAmount,
      required this.fee,
      required this.data,
      required this.unpackedData,
      required this.domain});

  TransactionInfo copyWith({
    String? hash,
    String? source,
    String? destination,
    int? btcAmount,
    int? fee,
    String? data,
    TransactionInfoDomain? domain,
    TransactionUnpacked? unpackedData,
  }) {
    return TransactionInfo(
      hash: hash ?? this.hash,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      btcAmount: btcAmount ?? this.btcAmount,
      fee: fee ?? this.fee,
      data: data ?? this.data,
      domain: domain ?? this.domain,
      unpackedData: unpackedData ?? this.unpackedData,
    );
  }

  @override
  List<Object?> get props =>
      [hash, source, destination, btcAmount, fee, data, unpackedData, domain];
}

class TransactionInfoVerbose extends TransactionInfo {
  final String btcAmountNormalized;

  const TransactionInfoVerbose({
    required this.btcAmountNormalized,
    required super.hash,
    required super.source,
    required super.destination,
    required super.btcAmount,
    required super.fee,
    required super.data,
    required super.domain,
    required super.unpackedData,
  });
  @override
  List<Object?> get props => [btcAmountNormalized, ...super.props];
}
