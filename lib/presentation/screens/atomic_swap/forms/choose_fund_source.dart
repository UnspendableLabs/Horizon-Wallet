import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/dialog_helper.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/screens/atomic_swap/forms/swap_balance_selector.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';

class SwapFundSourceSelector extends StatefulWidget {
  const SwapFundSourceSelector({super.key});

  @override
  State<SwapFundSourceSelector> createState() => _SwapFundSourceSelectorState();
}

class _SwapFundSourceSelectorState extends State<SwapFundSourceSelector> {
  void _toggleDropdown() {
    DialogHelper.showAppDialog(child: SwapBalanceSelector());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>();
    return Column(
      children: [
        Text(
          "Choose the source of your XCP",
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        commonHeightSizedBox,
        Text("Choose your funds",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w400,
                )),
        commonHeightSizedBox,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _toggleDropdown,
              child: Container(
                  height: 56,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.fromBorderSide(
                        Theme.of(context).inputDecorationTheme.outlineBorder ??
                            const BorderSide()),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Wallet Asset or Balance",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: customTheme?.mutedDescriptionTextColor,
                        ),
                      ),
                      const Spacer(),
                      AppIcons.caretDownIcon(
                        context: context,
                        width: 18,
                        height: 18,
                      )
                    ],
                  )),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HorizonButton(
              onPressed: () {}, child: TextButtonContent(value: "Continue")),
        )
      ],
    );
  }
}
