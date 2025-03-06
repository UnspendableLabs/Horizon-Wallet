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
}
