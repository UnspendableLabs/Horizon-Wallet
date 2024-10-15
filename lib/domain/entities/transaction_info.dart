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
  final String btcAmountNormalized;

  // final TransactionUnpacked? unpackedData;

  const TransactionInfo({
    required this.hash,
    required this.source,
    required this.destination,
    required this.btcAmount,
    required this.fee,
    required this.data,
    // required this.unpackedData,
    required this.domain,
    required this.btcAmountNormalized,
  });

  TransactionInfo copyWith({
    String? hash,
    String? source,
    String? destination,
    int? btcAmount,
    int? fee,
    String? data,
    TransactionInfoDomain? domain,
    String? btcAmountNormalized,

    // TransactionUnpacked? unpackedData,
  }) {
    return TransactionInfo(
        hash: hash ?? this.hash,
        source: source ?? this.source,
        destination: destination ?? this.destination,
        btcAmount: btcAmount ?? this.btcAmount,
        fee: fee ?? this.fee,
        data: data ?? this.data,
        domain: domain ?? this.domain,
        btcAmountNormalized: btcAmountNormalized ?? this.btcAmountNormalized
        // unpackedData: unpackedData ?? this.unpackedData,
        );
  }

  @override
  List<Object?> get props =>
      [hash, source, destination, btcAmount, fee, data, domain, btcAmountNormalized];
}

// class TransactionInfoVerbose extends TransactionInfo {
//   final String btcAmountNormalized;
//
//   const TransactionInfoVerbose({
//     required super.hash,
//     required super.source,
//     required super.destination,
//     required super.btcAmount,
//     required super.fee,
//     required super.data,
//     required super.domain,
//     required this.btcAmountNormalized,
//     // required super.unpackedData,
//   });
//   @override
//   List<Object?> get props => [btcAmountNormalized, ...super.props];
//
//   @override
//   TransactionInfoVerbose copyWith({
//     String? hash,
//     String? source,
//     String? destination,
//     int? btcAmount,
//     int? fee,
//     String? data,
//     TransactionInfoDomain? domain,
//     String? btcAmountNormalized,
//     // TransactionUnpacked? unpackedData,
//   }) {
//     return TransactionInfoVerbose(
//       hash: hash ?? this.hash,
//       source: source ?? this.source,
//       destination: destination ?? this.destination,
//       btcAmount: btcAmount ?? this.btcAmount,
//       fee: fee ?? this.fee,
//       data: data ?? this.data,
//       domain: domain ?? this.domain,
//       btcAmountNormalized: btcAmountNormalized ?? this.btcAmountNormalized,
//       // unpackedData: unpackedData ?? this.unpackedData,
//     );
//   }
// }

class TransactionInfoEnhancedSend extends TransactionInfo {
  final EnhancedSendUnpackedVerbose unpackedData;

  const TransactionInfoEnhancedSend({
    required super.hash,
    required super.source,
    required super.destination,
    required super.btcAmount,
    required super.fee,
    required super.data,
    required super.domain,
    required super.btcAmountNormalized,
    required this.unpackedData,
    // required super.unpackedData,
  });
  @override
  List<Object?> get props => [unpackedData, ...super.props];

  @override
  TransactionInfoEnhancedSend copyWith({
    String? hash,
    String? source,
    String? destination,
    int? btcAmount,
    int? fee,
    String? data,
    TransactionInfoDomain? domain,
    String? btcAmountNormalized,
    EnhancedSendUnpackedVerbose? unpackedData, // TODO: shouldn't be optinal
    // TransactionUnpacked? unpackedData,
  }) {
    return TransactionInfoEnhancedSend(
      hash: hash ?? this.hash,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      btcAmount: btcAmount ?? this.btcAmount,
      fee: fee ?? this.fee,
      data: data ?? this.data,
      domain: domain ?? this.domain,
      unpackedData: unpackedData ?? this.unpackedData,
      btcAmountNormalized: btcAmountNormalized ?? this.btcAmountNormalized,
      // unpackedData: unpackedData ?? this.unpackedData,
    );
  }
}


class TransactionInfoIssuance extends TransactionInfo {
  final IssuanceUnpackedVerbose unpackedData;

  const TransactionInfoIssuance({
    required super.hash,
    required super.source,
    required super.destination,
    required super.btcAmount,
    required super.fee,
    required super.data,
    required super.domain,
    required this.unpackedData,
    required super.btcAmountNormalized,
    // required super.unpackedData,
  });

  @override
  List<Object?> get props => [unpackedData, ...super.props];
}


class TransactionInfoDispenser extends TransactionInfo {
  final DispenserUnpackedVerbose unpackedData;

  const TransactionInfoDispenser({
    required super.hash,
    required super.source,
    required super.destination,
    required super.btcAmount,
    required super.fee,
    required super.data,
    required super.domain,
    required super.btcAmountNormalized,
    required this.unpackedData,
  });

  @override
  List<Object?> get props => [unpackedData, ...super.props];

  @override
  TransactionInfoDispenser copyWith({
    String? hash,
    String? source,
    String? destination,
    int? btcAmount,
    int? fee,
    String? data,
    TransactionInfoDomain? domain,
    DispenserUnpackedVerbose? unpackedData,
    String? btcAmountNormalized,
      
  }) {
    return TransactionInfoDispenser(
      hash: hash ?? this.hash,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      btcAmount: btcAmount ?? this.btcAmount,
      fee: fee ?? this.fee,
      data: data ?? this.data,
      domain: domain ?? this.domain,
      unpackedData: unpackedData ?? this.unpackedData,
      btcAmountNormalized: btcAmountNormalized ?? this.btcAmountNormalized,
    );
  }
}

