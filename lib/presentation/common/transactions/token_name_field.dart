import 'package:flutter/material.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/screens/dashboard/view/asset_icon.dart';

class TokenNameField extends StatelessWidget {
  final MultiAddressBalance? balance;
  final MultiAddressBalanceEntry? selectedBalanceEntry;
  final bool loading;

  const TokenNameField({
    super.key,
    required this.balance,
    this.selectedBalanceEntry,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final tokenName = displayAssetName(balance!.asset, balance!.assetLongname);
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: customTheme.inputBackground,
        border: Border.all(color: customTheme.inputBorderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          AssetIcon(asset: balance!.asset, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tokenName,
                  style: theme.textTheme.labelMedium,
                ),
                if (loading || selectedBalanceEntry != null)
                  Text(
                    "Balance: ${quantityRemoveTrailingZeros(selectedBalanceEntry!.quantityNormalized)}",
                    style: theme.textTheme.labelSmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
