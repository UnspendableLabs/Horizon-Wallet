import 'package:horizon/domain/entities/asset_info.dart';

class Balance {
  final String address;
  final int quantity;
  final String quantityNormalized;
  final String asset;
  final AssetInfo assetInfo;

  Balance(
      {required this.address,
      required this.quantity,
      required this.asset,
      required this.assetInfo,
      required this.quantityNormalized});
}
