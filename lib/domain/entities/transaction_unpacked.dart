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

class EnhancedSendUnpackedVerbose extends TransactionUnpacked {
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

class IssuanceUnpackedVerbose extends TransactionUnpacked {
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

class DispenserUnpackedVerbose extends TransactionUnpacked {
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

// dispense unnpacked is basically empty
class DispenseUnpackedVerbose extends TransactionUnpacked {
  const DispenseUnpackedVerbose() : super(messageType: "dispense");
}

class FairmintUnpackedVerbose extends TransactionUnpacked {
  final String? asset;
  final int? price;
  const FairmintUnpackedVerbose({required this.asset, required this.price})
      : super(messageType: "fairmint");
}

class FairminterUnpackedVerbose extends TransactionUnpacked {
  final String? asset;
  const FairminterUnpackedVerbose({required this.asset})
      : super(messageType: "fairminter");
}

class OrderUnpacked extends TransactionUnpacked {
  final String giveAsset;
  final int giveQuantity;
  final String getAsset;
  final int getQuantity;
  final int expiration;
  final int feeRequired;
  final String status;
  final String giveQuantityNormalized;
  final String getQuantityNormalized;
  final String feeRequiredNormalized;
  // final AssetInfo giveAssetInfo;
  // final AssetInfo getAssetInfo;

  const OrderUnpacked({
    required this.giveAsset,
    required this.giveQuantity,
    required this.getAsset,
    required this.getQuantity,
    required this.expiration,
    required this.feeRequired,
    required this.status,
    required this.giveQuantityNormalized,
    required this.getQuantityNormalized,
    required this.feeRequiredNormalized,
    // required this.giveAssetInfo,
    // required this.getAssetInfo,
  }) : super(messageType: "order");

  @override
  List<Object?> get props => [
        messageType,
        giveAsset,
        giveQuantity,
        getAsset,
        getQuantity,
        expiration,
        feeRequired,
        status,
        giveQuantityNormalized,
        getQuantityNormalized,
        feeRequiredNormalized,
        // giveAssetInfo,
        // getAssetInfo,
      ];
}

class CancelUnpacked extends TransactionUnpacked {
  final String orderHash;
  final String status;

  const CancelUnpacked({
    required this.orderHash,
    required this.status,
  }) : super(messageType: "cancel");

  @override
  List<Object?> get props => [orderHash, status];
}

class AttachUnpackedVerbose extends TransactionUnpacked {
  final String asset;
  final String? destinationVout;
  final String quantityNormalized;
  // final AssetInfo assetInfo;
  const AttachUnpackedVerbose({
    required this.asset,
    required this.destinationVout,
    required this.quantityNormalized,
    // required this.assetInfo,
  }) : super(messageType: "attach");
}

class DetachUnpackedVerbose extends TransactionUnpacked {
  final String destination;
  const DetachUnpackedVerbose({required this.destination})
      : super(messageType: "detach");
}

class MoveToUtxoUnpackedVerbose extends TransactionUnpacked {
  const MoveToUtxoUnpackedVerbose() : super(messageType: "utxo_move");
}

class MpmaSendDestination extends Equatable {
  final String asset;
  final String destination;
  final int quantity;
  final String? memo;
  final bool? memoIsHex;
  // final AssetInfo assetInfo;
  final String? quantityNormalized;

  const MpmaSendDestination({
    required this.asset,
    required this.destination,
    required this.quantity,
    this.memo,
    this.memoIsHex,
    // required this.assetInfo,
    this.quantityNormalized,
  });

  @override
  List<Object?> get props => [
        asset,
        destination,
        quantity,
        memo,
        memoIsHex,
        // assetInfo,
        quantityNormalized,
      ];
}

class MpmaSendUnpackedVerbose extends TransactionUnpacked {
  final List<MpmaSendDestination> messageData;

  const MpmaSendUnpackedVerbose({
    required this.messageData,
  }) : super(messageType: "mpma_send");

  @override
  List<Object?> get props => [messageType, messageData];
}
