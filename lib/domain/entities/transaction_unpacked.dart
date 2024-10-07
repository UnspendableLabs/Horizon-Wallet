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

class IssuanceUnpacked extends TransactionUnpacked {
  final int assetId;
  final String asset;
  final String? subassetLongname;
  final int quantity;
  final bool divisible;
  final bool lock;
  final bool reset;
  final bool callable;
  final int callDate;
  final double callPrice;
  final String description;
  final String status;

  const IssuanceUnpacked(
      {required this.assetId,
      required this.asset,
      this.subassetLongname,
      required this.quantity,
      required this.divisible,
      required this.lock,
      required this.reset,
      required this.callable,
      required this.callDate,
      required this.callPrice,
      required this.description,
      required this.status})
      : super(messageType: "issuance");

  @override
  List<Object?> get props => [
        assetId,
        asset,
        subassetLongname,
        quantity,
        divisible,
        lock,
        reset,
        callable,
        callDate,
        callPrice,
        description,
        status
      ];
}

class IssuanceUnpackedVerbose extends TransactionUnpackedVerbose {
  final int assetId;
  final String asset;
  final String? subassetLongname;
  final int quantity;
  final bool divisible;
  final bool lock;
  final bool reset;
  final bool callable;
  final int callDate;
  final double callPrice;
  final String description;
  final String status;
  final String quantityNormalized;

  const IssuanceUnpackedVerbose(
      {required this.assetId,
      required this.asset,
      this.subassetLongname,
      required this.quantity,
      required this.divisible,
      required this.lock,
      required this.reset,
      required this.callable,
      required this.callDate,
      required this.callPrice,
      required this.description,
      required this.status,
      required this.quantityNormalized})
      : super(messageType: "issuance");

  @override
  List<Object?> get props => [
        assetId,
        asset,
        subassetLongname,
        quantity,
        divisible,
        lock,
        reset,
        callable,
        callDate,
        callPrice,
        description,
        status,
        quantityNormalized
      ];
}

class DispenserUnpacked extends TransactionUnpacked {
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final String status;

  const DispenserUnpacked({
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.status,
  }) : super(messageType: "dispenser");

  // Optionally add other methods like from API mappings
}

class DispenserUnpackedVerbose extends TransactionUnpackedVerbose {
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final String status;
  final String giveQuantityNormalized;
  final String escrowQuantityNormalized;
  // final String mainchainrateNormalized;

  const DispenserUnpackedVerbose({
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.status,
    required this.giveQuantityNormalized,
    required this.escrowQuantityNormalized,
    // required this.mainchainrateNormalized,
  }) : super(messageType: "dispenser");
}
