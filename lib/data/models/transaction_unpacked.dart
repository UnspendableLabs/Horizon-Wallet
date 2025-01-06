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
      case "fairminter":
        return FairminterUnpackedVerboseMapper.toDomain(
            u as api.FairminterUnpackedVerbose);
      case "order":
        return OrderUnpackedVerboseMapper.toDomain(
            u as api.OrderUnpackedVerbose);
      case "cancel":
        return CancelUnpackedVerboseMapper.toDomain(
            u as api.CancelUnpackedVerbose);
      case "attach":
        return AttachUnpackedVerboseMapper.toDomain(
            u as api.AttachUnpackedVerbose);
      case "detach":
        return DetachUnpackedVerboseMapper.toDomain(
            u as api.DetachUnpackedVerbose);
      case "mpma_send":
        return MpmaSendUnpackedVerboseMapper.toDomain(
            u as api.MpmaSendUnpackedVerbose);
      case "destroy":
        return AssetDestructionUnpackedVerboseMapper.toDomain(
            u as api.AssetDestructionUnpackedVerbose);
      case "dividend":
        return AssetDividendUnpackedVerboseMapper.toDomain(
            u as api.AssetDividendUnpackedVerbose);
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

class OrderUnpackedVerboseMapper {
  static OrderUnpacked toDomain(api.OrderUnpackedVerbose u) {
    return OrderUnpacked(
      giveAsset: u.giveAsset,
      giveQuantity: u.giveQuantity,
      getAsset: u.getAsset,
      getQuantity: u.getQuantity,
      expiration: u.expiration,
      feeRequired: u.feeRequired,
      status: u.status,
      giveQuantityNormalized: u.giveQuantityNormalized,
      getQuantityNormalized: u.getQuantityNormalized,
      feeRequiredNormalized: u.feeRequiredNormalized,
      // giveAssetInfo: AssetInfoMapper.toDomain(u.giveAssetInfo),
      // getAssetInfo: AssetInfoMapper.toDomain(u.getAssetInfo),
    );
  }
}

class CancelUnpackedVerboseMapper {
  static CancelUnpacked toDomain(api.CancelUnpackedVerbose u) {
    return CancelUnpacked(
      orderHash: u.offerHash,
      status: u.status,
    );
  }
}

class AttachUnpackedVerboseMapper {
  static AttachUnpackedVerbose toDomain(api.AttachUnpackedVerbose u) {
    return AttachUnpackedVerbose(
      destinationVout: u.destinationVout,
      quantityNormalized: u.quantityNormalized,
      asset: u.asset,
      // assetInfo: AssetInfoMapper.toDomain(u.assetInfo),
    );
  }
}

class DetachUnpackedVerboseMapper {
  static DetachUnpackedVerbose toDomain(api.DetachUnpackedVerbose u) {
    return DetachUnpackedVerbose(destination: u.destination);
  }
}

class MoveToUtxoUnpackedVerboseMapper {
  static MoveToUtxoUnpackedVerbose toDomain(api.MoveToUtxoUnpackedVerbose u) {
    return const MoveToUtxoUnpackedVerbose();
  }
}

class MpmaSendUnpackedVerboseMapper {
  static MpmaSendUnpackedVerbose toDomain(
      api.MpmaSendUnpackedVerbose unpacked) {
    return MpmaSendUnpackedVerbose(
      messageData: unpacked.messageData
          .map((d) => MpmaSendDestination(
                asset: d.asset,
                destination: d.destination,
                quantity: d.quantity,
                memo: d.memo,
                memoIsHex: d.memoIsHex,
                // assetInfo: AssetInfoMapper.toDomain(d.assetInfo),
                quantityNormalized: d.quantityNormalized,
              ))
          .toList(),
    );
  }
}

class AssetDestructionUnpackedVerboseMapper {
  static AssetDestructionUnpackedVerbose toDomain(
      api.AssetDestructionUnpackedVerbose u) {
    return AssetDestructionUnpackedVerbose(
      asset: u.asset,
      quantityNormalized: u.quantityNormalized,
      tag: u.tag,
      quantity: u.quantity,
      // assetInfo: AssetInfoMapper.toDomain(u.assetInfo),
    );
  }
}

class AssetDividendUnpackedVerboseMapper {
  static AssetDividendUnpackedVerbose toDomain(
      api.AssetDividendUnpackedVerbose u) {
    return AssetDividendUnpackedVerbose(
      asset: u.asset,
      quantityPerUnit: u.quantityPerUnit,
      dividendAsset: u.dividendAsset,
      status: u.status,
    );
  }
}
