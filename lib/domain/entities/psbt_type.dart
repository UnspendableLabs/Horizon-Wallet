import 'package:horizon/domain/entities/asset_quantity.dart';

sealed class PsbtType {}

class OpaquePsbt extends PsbtType {}

sealed class TrustedPsbt extends PsbtType {}

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
    required this.asset,
    required this.quantity,
    required this.toAddress,
  });
}

class DetachPsbt extends TrustedPsbt {
  DetachPsbt();
}

class AttachPsbt extends TrustedPsbt {
  final String asset;
  final AssetQuantity quantity;

  AttachPsbt({
    required this.asset,
    required this.quantity,
  });
}

class AtomicSwapBuyPsbt extends TrustedPsbt {
  AssetQuantity? royalty;

  AtomicSwapBuyPsbt({
    required this.royalty,
  });
}

class AtomicSwapSellPsbt extends TrustedPsbt {
  AtomicSwapSellPsbt();
}

class AtomicSwapListingFee extends TrustedPsbt {}

class OrderPsbt extends TrustedPsbt {
  final String giveAsset;
  final String getAsset;

  final AssetQuantity giveQuantity;
  final AssetQuantity getQuantity;

  OrderPsbt({
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
    required this.asset,
    required this.quantity,
    required this.xcpPrice,
  });
}

class Sweep extends TrustedPsbt {
  final String destination;

  Sweep({
    required this.destination,
  });
}

class UtxoMove extends TrustedPsbt {
  final String destination;

  UtxoMove({
    required this.destination,
  });
}

class Destroy extends TrustedPsbt {
  final String asset;
  final AssetQuantity quantity;
  final String tag;

  Destroy({
    required this.asset,
    required this.quantity,
    required this.tag,
  });
}

// export type LockQuantityTransactionInfo = {
//   asset: string;
//   quantity: number;
//   lock: boolean;
//   divisible: boolean;
//   asset_divisibility: boolean;
// };

class LockQuantity extends TrustedPsbt {
  final String asset;
  final AssetQuantity quantity;
  final bool lock;

  LockQuantity({
    required this.asset,
    required this.quantity,
    required this.lock,
  });
}

//
// export type LockDescriptionTransactionInfo = {
//   asset: string;
//   quantity: number;
//   description: string;
//   divisible: boolean;
//   asset_divisibility: boolean;
// };
class LockDescription extends TrustedPsbt {
  final String asset;
  final String description;

  LockDescription({
    required this.asset,
    required this.description,
  });
}
// export type ChangeDescriptionTransactionInfo = {
//   asset: string;
//   description: string;
//   quantity: number;
//   divisible: boolean;
//   asset_divisibility: boolean;
// };

class ChangeDescription extends TrustedPsbt {
  final String asset;
  final String description;

  ChangeDescription({
    required this.asset,
    required this.description,
  });
}

// export type ChangeOwnershipTransactionInfo = {
//   asset: string;
//   transfer_destination: string;
//   quantity: number;
//   divisible: boolean;
//   asset_divisibility: boolean;
// };

class ChangeOwnership extends TrustedPsbt {
  final String asset;
  final String transferDestination;

  ChangeOwnership({
    required this.asset,
    required this.transferDestination,
  });
}

// export type ResetTransactionInfo = {
//   asset: string;
//   quantity: number;
//   divisible: boolean;
//   reset: boolean;
//   asset_divisibility: boolean;
// };

class Reset extends TrustedPsbt {
  final String asset;
  final AssetQuantity quantity;
  final bool reset;

  Reset({
    required this.asset,
    required this.quantity,
    required this.reset,
  });
}
// export type IssueMoreTransactionInfo = {
//   asset: string;
//   quantity: number;
//   divisible: boolean;
//   asset_divisibility: boolean;
// };

class IssueMore extends TrustedPsbt {
  final String asset;
  final AssetQuantity quantity;

  IssueMore({
    required this.asset,
    required this.quantity,
  });
}
// export type IssuanceTransactionInfo = {

//   asset?: string;
//   quantity?: number;
//   divisible?: boolean;
// };

class Issuance extends TrustedPsbt {
  final String? asset;
  final AssetQuantity? quantity;

  Issuance({
    this.asset,
    this.quantity,
  });
}

// export type FairminterTransactionInfo = {
//   issuance_type?: string;
//   asset?: string;
//   quantity?: number;
//   divisible?: boolean;
//   max_mint_per_tx?: number;
//   quantity_by_price?: number;
//   premint_quantity?: number;
//   minted_asset_commission?: number;
//   encoding?: string | null;
//   inscription?: string | null | boolean;
//   description?: string;
//   mime_type?: string | null;
//   audio?: string | null;
//   media?: string | null;
//   start_block?: number;
//   end_block?: number;
//   soft_cap?: number;
//   soft_cap_deadline_block?: number;
// };

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
    required this.sends,
  });
}
