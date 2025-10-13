import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/balance_v2.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

class TokenNameField extends StatelessWidget {
  final BalanceV2? selectedBalanceEntry;
  final bool loading;
  final Widget? suffixIcon;
  final Decoration? decoration;

  const TokenNameField({
    super.key,
    this.selectedBalanceEntry,
    required this.loading,
    this.suffixIcon,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final appIcons = AppIcons();
    final tokenName = selectedBalanceEntry == null
        ? ''
        : displayAssetName(
            selectedBalanceEntry!.asset, selectedBalanceEntry!.assetLongname);
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    return Container(
      height: 56,
      decoration: decoration ??
          BoxDecoration(
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
              selectedBalanceEntry == null
                  ? const SizedBox.shrink()
                  : appIcons.assetIcon(
                      httpConfig: session.httpConfig,
                      assetName: selectedBalanceEntry!.asset,
                      context: context,
                      width: 34,
                      height: 34,
                      description: selectedBalanceEntry!.description),
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
                        "Balance: ${selectedBalanceEntry!.quantity.normalizedPretty()}",
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
