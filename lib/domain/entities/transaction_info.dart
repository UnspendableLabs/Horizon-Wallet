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
  List<Object?> get props => [
        hash,
        source,
        destination,
        btcAmount,
        fee,
        data,
        domain,
        btcAmountNormalized
      ];
}

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

  @override
  TransactionInfoIssuance copyWith({
    String? hash,
    String? source,
    String? destination,
    int? btcAmount,
    int? fee,
    String? data,
    TransactionInfoDomain? domain,
    IssuanceUnpackedVerbose? unpackedData,
    String? btcAmountNormalized,
  }) {
    return TransactionInfoIssuance(
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

class TransactionInfoDispense extends TransactionInfo {
  final DispenseUnpackedVerbose unpackedData;

  const TransactionInfoDispense({
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
  TransactionInfoDispense copyWith({
    String? hash,
    String? source,
    String? destination,
    int? btcAmount,
    int? fee,
    String? data,
    TransactionInfoDomain? domain,
    DispenseUnpackedVerbose? unpackedData,
    String? btcAmountNormalized,
  }) {
    return TransactionInfoDispense(
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

class TransactionInfoFairmint extends TransactionInfo {
  final FairmintUnpackedVerbose unpackedData;

  const TransactionInfoFairmint({
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

  @override
  TransactionInfoFairmint copyWith({
    String? hash,
    String? source,
    String? destination,
    int? btcAmount,
    int? fee,
    String? data,
    TransactionInfoDomain? domain,
    FairmintUnpackedVerbose? unpackedData,
    String? btcAmountNormalized,
  }) {
    return TransactionInfoFairmint(
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

class TransactionInfoFairminter extends TransactionInfo {
  final FairminterUnpackedVerbose unpackedData;

  const TransactionInfoFairminter({
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

  @override
  TransactionInfoFairminter copyWith({
    String? hash,
    String? source,
    String? destination,
    int? btcAmount,
    int? fee,
    String? data,
    TransactionInfoDomain? domain,
    FairminterUnpackedVerbose? unpackedData,
    String? btcAmountNormalized,
  }) {
    return TransactionInfoFairminter(
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

class TransactionInfoOrder extends TransactionInfo {
  final OrderUnpacked unpackedData;
  const TransactionInfoOrder({
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
  @override
  TransactionInfoOrder copyWith({
    String? hash,
    String? source,
    String? destination,
    int? btcAmount,
    int? fee,
    String? data,
    TransactionInfoDomain? domain,
    OrderUnpacked? unpackedData,
    String? btcAmountNormalized,
  }) {
    return TransactionInfoOrder(
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

class TransactionInfoCancel extends TransactionInfo {
  final CancelUnpacked unpackedData;
  const TransactionInfoCancel({
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
  @override
  TransactionInfoCancel copyWith({
    String? hash,
    String? source,
    String? destination,
    int? btcAmount,
    int? fee,
    String? data,
    TransactionInfoDomain? domain,
    CancelUnpacked? unpackedData,
    String? btcAmountNormalized,
  }) {
    return TransactionInfoCancel(
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

class TransactionInfoAttach extends TransactionInfo {
  final AttachUnpackedVerbose unpackedData;
  const TransactionInfoAttach({
    required super.hash,
    required super.source,
    required super.destination,
    required super.btcAmount,
    required super.fee,
    required super.data,
    required super.domain,
    required this.unpackedData,
    required super.btcAmountNormalized,
  });
  @override
  List<Object?> get props => [unpackedData, ...super.props];
  @override
  TransactionInfoAttach copyWith({
    String? hash,
    String? source,
    String? destination,
    int? btcAmount,
    int? fee,
    String? data,
    TransactionInfoDomain? domain,
    AttachUnpackedVerbose? unpackedData,
    String? btcAmountNormalized,
  }) {
    return TransactionInfoAttach(
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

class TransactionInfoDetach extends TransactionInfo {
  final DetachUnpackedVerbose unpackedData;
  const TransactionInfoDetach({
    required super.hash,
    required super.source,
    required super.destination,
    required super.btcAmount,
    required super.fee,
    required super.data,
    required super.domain,
    required this.unpackedData,
    required super.btcAmountNormalized,
  });
  @override
  List<Object?> get props => [unpackedData, ...super.props];
  @override
  TransactionInfoDetach copyWith({
    String? hash,
    String? source,
    String? destination,
    int? btcAmount,
    int? fee,
    String? data,
    TransactionInfoDomain? domain,
    DetachUnpackedVerbose? unpackedData,
    String? btcAmountNormalized,
  }) {
    return TransactionInfoDetach(
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

class TransactionInfoMoveToUtxo extends TransactionInfo {
  const TransactionInfoMoveToUtxo({
    required super.hash,
    required super.source,
    required super.destination,
    required super.btcAmount,
    required super.fee,
    required super.data,
    required super.domain,
    required super.btcAmountNormalized,
  });
  @override
  List<Object?> get props => [...super.props];
  @override
  TransactionInfoMoveToUtxo copyWith({
    String? hash,
    String? source,
    String? destination,
    int? btcAmount,
    int? fee,
    String? data,
    TransactionInfoDomain? domain,
    String? btcAmountNormalized,
  }) {
    return TransactionInfoMoveToUtxo(
      hash: hash ?? this.hash,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      btcAmount: btcAmount ?? this.btcAmount,
      fee: fee ?? this.fee,
      data: data ?? this.data,
      domain: domain ?? this.domain,
      btcAmountNormalized: btcAmountNormalized ?? this.btcAmountNormalized,
    );
  }
}

class TransactionInfoMpmaSend extends TransactionInfo {
  final MpmaSendUnpackedVerbose unpackedData;

  const TransactionInfoMpmaSend({
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
  TransactionInfoMpmaSend copyWith({
    String? hash,
    String? source,
    String? destination,
    int? btcAmount,
    int? fee,
    String? data,
    TransactionInfoDomain? domain,
    MpmaSendUnpackedVerbose? unpackedData,
    String? btcAmountNormalized,
  }) {
    return TransactionInfoMpmaSend(
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

class TransactionInfoAssetDestruction extends TransactionInfo {
  final AssetDestructionUnpackedVerbose unpackedData;
  const TransactionInfoAssetDestruction({
    required super.hash,
    required super.source,
    required super.destination,
    required super.btcAmount,
    required super.fee,
    required super.data,
    required super.domain,
    required this.unpackedData,
    required super.btcAmountNormalized,
  });

  @override
  List<Object?> get props => [unpackedData, ...super.props];

  @override
  TransactionInfoAssetDestruction copyWith({
    String? hash,
    String? source,
    String? destination,
    int? btcAmount,
    int? fee,
    String? data,
    TransactionInfoDomain? domain,
    AssetDestructionUnpackedVerbose? unpackedData,
    String? btcAmountNormalized,
  }) {
    return TransactionInfoAssetDestruction(
        hash: hash ?? this.hash,
        source: source ?? this.source,
        destination: destination ?? this.destination,
        btcAmount: btcAmount ?? this.btcAmount,
        fee: fee ?? this.fee,
        data: data ?? this.data,
        domain: domain ?? this.domain,
        unpackedData: unpackedData ?? this.unpackedData,
        btcAmountNormalized: btcAmountNormalized ?? this.btcAmountNormalized);
  }
}
