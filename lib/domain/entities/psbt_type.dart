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

class AtomicSwapBuyPsbt extends TrustedPsbt {
  String asset;
  AssetQuantity quantity;
  BigInt sats;

  AtomicSwapBuyPsbt({
    required this.asset,
    required this.quantity,
    required this.sats,
  });
}

class AtomicSwapSellPsbt extends TrustedPsbt {
  // String asset;
  // AssetQuantity quantity;
  // BigInt sats;

  AtomicSwapSellPsbt(
      // required this.asset,
      // required this.quantity,
      // required this.sats,
      );
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
