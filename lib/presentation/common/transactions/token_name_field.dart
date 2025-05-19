import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

class TokenNameField extends StatelessWidget {
  final MultiAddressBalance? balance;
  final MultiAddressBalanceEntry? selectedBalanceEntry;
  final bool loading;
  final Widget? suffixIcon;

  const TokenNameField({
    super.key,
    required this.balance,
    this.selectedBalanceEntry,
    required this.loading,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final appIcons = AppIcons();
    final tokenName = balance == null
        ? ''
        : displayAssetName(balance!.asset, balance!.assetLongname);
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    final session = context.watch<SessionStateCubit>().state.successOrThrow();

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
          Expanded(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              balance == null
                  ? const SizedBox.shrink()
                  : appIcons.assetIcon(
                      httpConfig: session.httpConfig,
                      assetName: balance!.asset,
                      context: context,
                      width: 34,
                      height: 34,
                      description: balance!.assetInfo.description),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tokenName,
                      style: theme.textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (selectedBalanceEntry != null)
                      Text(
                        "Balance: ${quantityRemoveTrailingZeros(selectedBalanceEntry!.quantityNormalized)}",
                        style: theme.textTheme.labelSmall,
                      ),
                  ],
                ),
              )
            ],
          )),
          if (suffixIcon != null) ...[
            const SizedBox(
              width: 8,
            ),
            suffixIcon!,
          ]
        ],
      ),
    );
  }
}
