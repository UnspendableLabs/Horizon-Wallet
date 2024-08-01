import "package:equatable/equatable.dart";

class TransactionUnpacked extends Equatable {
  final String messageType;

  const TransactionUnpacked({required this.messageType});

  @override
  List<Object?> get props => [];
}

// {"messageType":"enhanced_send","messageData":{"asset":"XCP","quantity":10,"address":"tb1qdlj8pxvva4ws7364geu86h87lhahxedhk538gd","memo":null}}

class EnhancedSendUnpacked extends TransactionUnpacked {
  final String asset;
  final int quantity;
  final String address;
  final String? memo;
  const EnhancedSendUnpacked(
      {required this.asset,
      required this.quantity,
      required this.address,
      required this.memo})
      : super(
          messageType: "enhanced_send",
        );

  @override
  List<Object?> get props => [messageType, asset, quantity, address, memo];
}

class TransactionUnpackedVerbose extends TransactionUnpacked {
  // final String btcAmountNormalized;
  const TransactionUnpackedVerbose({
    // required this.btcAmountNormalized,
    required super.messageType,
  });
  @override
  List<Object?> get props => [
        messageType,
      ];
}

class EnhancedSendUnpackedVerbose extends TransactionUnpackedVerbose {
  final String asset;
  final int quantity;
  final String address;
  final String? memo;
  final String quantityNormalized;
  const EnhancedSendUnpackedVerbose({
    required this.asset,
    required this.quantity,
    required this.address,
    this.memo,
    required this.quantityNormalized,
  }) : super(
          messageType: "enhanced_send",
        );
  @override
  List<Object?> get props =>
      [messageType, asset, quantity, address, memo, quantityNormalized];
}
