import "package:horizon/data/sources/network/api/v2_api.dart" as api;
import "package:horizon/domain/entities/transaction_unpacked.dart";

class UnpackedVerboseMapper {
  static TransactionUnpacked toDomain(api.TransactionUnpackedVerbose u) {
    switch (u.messageType) {
      case "enhanced_send":
        return EnhancedSendUnpackedVerboseMapper.toDomain(
            u as api.EnhancedSendUnpackedVerbose);
      case "issuance":
        return IssuanceUnpackedVerboseMapper.toDomain(
            u as api.IssuanceUnpackedVerbose);
      case "dispenser":
        return DispenserUnpackedVerboseMapper.toDomain(
            u as api.DispenserUnpackedVerbose);
      case "dispense":
        return DispenseUnpackedVerboseMapper.toDomain(
            u as api.DispenseUnpackedVerbose);
      case "fairmint":
        return FairmintUnpackedVerboseMapper.toDomain(
            u as api.FairmintUnpackedVerbose);
      default:
        return TransactionUnpacked(
          messageType: u.messageType,
          // btcAmountNormalized: u.btcAmountNormalized,
        );
    }
  }
}

class EnhancedSendUnpackedVerboseMapper {
  static EnhancedSendUnpackedVerbose toDomain(
      api.EnhancedSendUnpackedVerbose u) {
    return EnhancedSendUnpackedVerbose(
      asset: u.asset,
      quantity: u.quantity,
      address: u.address,
      memo: u.memo,
      quantityNormalized: u.quantityNormalized,
    );
  }
}

class IssuanceUnpackedVerboseMapper {
  static IssuanceUnpackedVerbose toDomain(api.IssuanceUnpackedVerbose u) {
    return IssuanceUnpackedVerbose(
      assetId: u.assetId,
      asset: u.asset,
      subassetLongname: u.subassetLongname,
      quantity: u.quantity,
      divisible: u.divisible,
      lock: u.lock,
      reset: u.reset,
      callable: u.callable,
      callDate: u.callDate,
      callPrice: u.callPrice,
      description: u.description,
      status: u.status,
      quantityNormalized: u.quantityNormalized,
    );
  }
}

class DispenserUnpackedVerboseMapper {
  static DispenserUnpackedVerbose toDomain(api.DispenserUnpackedVerbose u) {
    return DispenserUnpackedVerbose(
      asset: u.asset,
      giveQuantity: u.giveQuantity,
      escrowQuantity: u.escrowQuantity,
      mainchainrate: u.mainchainrate,
      giveQuantityNormalized: u.giveQuantityNormalized,
      escrowQuantityNormalized: u.escrowQuantityNormalized,
      // mainchainrateNormalized: u.mainchainrateNormalized,
      status: "", // TODO: reconcile
    );
  }
}

class DispenseUnpackedVerboseMapper {
  static DispenseUnpackedVerbose toDomain(api.DispenseUnpackedVerbose u) {
    return const DispenseUnpackedVerbose();
  }
}

class FairmintUnpackedVerboseMapper {
  static FairmintUnpackedVerbose toDomain(api.FairmintUnpackedVerbose u) {
    return FairmintUnpackedVerbose(
      asset: u.asset,
      price: u.price,
    );
  }
}

class FairminterUnpackedVerboseMapper {
  static FairminterUnpackedVerbose toDomain(api.FairminterUnpackedVerbose u) {
    return FairminterUnpackedVerbose(
      asset: u.asset,
    );
  }
}
