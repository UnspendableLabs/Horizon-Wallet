import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/utils/app_icons.dart';

class AssetBalanceListItem extends StatelessWidget {
  final MultiAddressBalance balance;
  const AssetBalanceListItem({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final appIcons = AppIcons();
    return Row(
      children: [
        appIcons.assetIcon(
          context: context,
          assetName: balance.asset,
          description: balance.assetInfo.description,
          width: 34,
          height: 34,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              balance.asset,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                  ),
            ),
            Text(
              "Balance: ${balance.totalNormalized}",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        )
      ],
    );
  }
}
