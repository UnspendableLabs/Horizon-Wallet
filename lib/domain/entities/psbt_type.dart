import 'package:horizon/domain/entities/asset_quantity.dart';

sealed class PsbtType {
  final bool rpc;
  PsbtType({this.rpc = false});
}

class OpaquePsbt extends PsbtType {
  OpaquePsbt({super.rpc});
}

sealed class TrustedPsbt extends PsbtType {
  TrustedPsbt({super.rpc});
}

class BtcSendPsbt extends TrustedPsbt {
  BigInt sats;
  String toAddress;
  BtcSendPsbt({required this.toAddress, required this.sats});
}

class XCPSendPsbt extends TrustedPsbt {
  String asset;
  AssetQuantity quantity;
  String toAddress;

  XCPSendPsbt({
    super.rpc,
    required this.asset,
    required this.quantity,
    required this.toAddress,
  });
}

class DetachPsbt extends TrustedPsbt {
  DetachPsbt({super.rpc});
}

class AttachPsbt extends TrustedPsbt {
  final String asset;
  final AssetQuantity quantity;

  AttachPsbt({
    super.rpc,
    required this.asset,
    required this.quantity,
  });
}

class AtomicSwapBuyPsbt extends TrustedPsbt {
  AssetQuantity? royalty;

  AtomicSwapBuyPsbt({
    super.rpc,
    required this.royalty,
  });
}

class AtomicSwapSellPsbt extends TrustedPsbt {
  AtomicSwapSellPsbt({super.rpc});
}

class AtomicSwapListingFee extends TrustedPsbt {
  AtomicSwapListingFee({super.rpc});
}

class OrderPsbt extends TrustedPsbt {
  final String giveAsset;
  final String getAsset;

  final AssetQuantity giveQuantity;
  final AssetQuantity getQuantity;

  OrderPsbt({
    super.rpc,
    required this.giveAsset,
    required this.getAsset,
    required this.giveQuantity,
    required this.getQuantity,
  });
}

class CancelOrder extends TrustedPsbt {
  final String asset;
  final AssetQuantity quantity;
  final Price xcpPrice;

  CancelOrder({
    super.rpc,
    required this.asset,
    required this.quantity,
    required this.xcpPrice,
  });
}

class Sweep extends TrustedPsbt {
  final String destination;

  Sweep({
    super.rpc,
    required this.destination,
  });
}

class UtxoMove extends TrustedPsbt {
  final String destination;

  UtxoMove({
    super.rpc,
    required this.destination,
  });
}

class Destroy extends TrustedPsbt {
  final String asset;
  final AssetQuantity quantity;
  final String tag;

  Destroy({
    super.rpc,
    required this.asset,
    required this.quantity,
    required this.tag,
  });
}

class LockQuantity extends TrustedPsbt {
  final String asset;
  final AssetQuantity quantity;
  final bool lock;

  LockQuantity({
    super.rpc,
    required this.asset,
    required this.quantity,
    required this.lock,
  });
}

class LockDescription extends TrustedPsbt {
  final String asset;
  final String description;

  LockDescription({
    super.rpc,
    required this.asset,
    required this.description,
  });
}

class ChangeDescription extends TrustedPsbt {
  final String asset;
  final String description;

  ChangeDescription({
    super.rpc,
    required this.asset,
    required this.description,
  });
}

class ChangeOwnership extends TrustedPsbt {
  final String asset;
  final String transferDestination;

  ChangeOwnership({
    super.rpc,
    required this.asset,
    required this.transferDestination,
  });
}

class Reset extends TrustedPsbt {
  final String asset;
  final AssetQuantity quantity;
  final bool reset;

  Reset({
    super.rpc,
    required this.asset,
    required this.quantity,
    required this.reset,
  });
}

class IssueMore extends TrustedPsbt {
  final String asset;
  final AssetQuantity quantity;

  IssueMore({
    super.rpc,
    required this.asset,
    required this.quantity,
  });
}

class Issuance extends TrustedPsbt {
  final String? asset;
  final AssetQuantity? quantity;

  Issuance({
    super.rpc,
    this.asset,
    this.quantity,
  });
}

class Fairmint extends TrustedPsbt {
  final String asset;
  final AssetQuantity quantity;

  Fairmint({
    super.rpc,
    required this.asset,
    required this.quantity,
  });
}

class Fairminter extends TrustedPsbt {
  final String? issuanceType;
  final String? asset;
  final AssetQuantity? quantity;
  final AssetQuantity? maxMintPerTx;
  final BigInt? quantityByPrice;
  final AssetQuantity? premintQuantity;
  final num? mintedAssetCommission;
  final String? encoding;
  final String? inscription;
  final String? description;
  final String? mimeType;
  final String? audio;
  final String? media;
  final int? startBlock;
  final int? endBlock;
  final int? softCap;
  final int? softCapDeadlineBlock;

  Fairminter({
    super.rpc,
    this.issuanceType,
    this.asset,
    this.quantity,
    this.maxMintPerTx,
    this.quantityByPrice,
    this.premintQuantity,
    this.mintedAssetCommission,
    this.encoding,
    this.inscription,
    this.description,
    this.mimeType,
    this.audio,
    this.media,
    this.startBlock,
    this.endBlock,
    this.softCap,
    this.softCapDeadlineBlock,
  });
}

class Mpma extends TrustedPsbt {
  final List<XCPSendPsbt> sends;

  Mpma({
    super.rpc,
    required this.sends,
  });
}

class Dividend extends TrustedPsbt {
  final String asset;
  final String dividendAsset;
  final AssetQuantity quantityPerUnit;

  Dividend({
    super.rpc,
    required this.asset,
    required this.dividendAsset,
    required this.quantityPerUnit,
  });
}
