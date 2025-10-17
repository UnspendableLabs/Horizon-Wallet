import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';

sealed class PsbtType {}

class OpaquePsbt extends PsbtType {}

sealed class TrustedPsbt extends PsbtType {}

class BtcSendPsbt extends TrustedPsbt {
  BigInt sats;
  String toAddress;
  BtcSendPsbt({required this.toAddress, required this.sats});
}

sealed class XCPSendQuantity {}

class DivisibilityKnown extends XCPSendQuantity {
  AssetQuantity quantity;
  DivisibilityKnown({required this.quantity});
}

class DivisibilityUnknown extends XCPSendQuantity {
  BigInt raw;
  DivisibilityUnknown({required this.raw});
}

class XCPSendPsbt extends TrustedPsbt {
  String asset;
  XCPSendQuantity quantity;
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
