import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';

class MultiAddressBalance {
  final String asset;
  final String? assetLongname;
  final int total;
  final String totalNormalized;
  final List<MultiAddressBalanceEntry> entries;
  final AssetInfo assetInfo;

  MultiAddressBalance({
    required this.asset,
    required this.assetLongname,
    required this.total,
    required this.totalNormalized,
    required this.entries,
    required this.assetInfo,
  });

  static bool areBalancesEqual(
      List<MultiAddressBalance> a, List<MultiAddressBalance> b) {
    if (a.length != b.length) return false;

    // Simple comparison of total assets and their quantities
    final Map<String, String> aAssets = {
      for (var balance in a) balance.asset: balance.totalNormalized
    };

    for (var balance in b) {
      final aQuantity = aAssets[balance.asset];
      if (aQuantity == null || aQuantity != balance.totalNormalized) {
        return false;
      }
    }

    return true;
  }
}
