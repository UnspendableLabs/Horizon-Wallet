import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/common/transactions/multi_address_balance_dropdown.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class SwapFormChooseAddress extends StatefulWidget {
  final Function(String) onNextStep;
  const SwapFormChooseAddress({super.key, required this.onNextStep});

  @override
  State<SwapFormChooseAddress> createState() => _SwapFormChooseAddressState();
}

class _SwapFormChooseAddressState extends State<SwapFormChooseAddress> {
  MultiAddressBalanceEntry? selectedBalanceEntry;

  // TODO: Remove this fake data
  final MultiAddressBalance fakeBalances = MultiAddressBalance(
      asset: "BTC",
      assetLongname: "Bitcoin",
      total: 100000000,
      totalNormalized: "1.0",
      entries: [
        MultiAddressBalanceEntry(
            address: "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa",
            quantity: 100000000,
            quantityNormalized: "1.0"),
      ],
      assetInfo: const AssetInfo(
        divisible: true,
        description: "Bitcoin",
        locked: false,
      ));
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(children: [
      Text(
        "Choose your Address",
        style: Theme.of(context).textTheme.titleMedium,
      ),
      commonHeightSizedBox,
      Text("Choose the source of your funds",
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w400,
              )),
      commonHeightSizedBox,
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: MultiAddressBalanceDropdown(
              balances: fakeBalances,
              selectedItemBuilder: (entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        entry.address!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme
                              .extension<CustomThemeExtension>()
                              ?.offColorText,
                        ),
                      ),
                      Text(
                        "${entry.quantityNormalized} ${fakeBalances.asset}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme
                              .extension<CustomThemeExtension>()
                              ?.mutedDescriptionTextColor,
                        ),
                      ),
                    ],
                  ),
              onChanged: (value) {
                setState(() {
                  selectedBalanceEntry = value;
                });
              },
              selectedValue: selectedBalanceEntry,
              loading: false)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: HorizonButton(
            variant: ButtonVariant.green,
            disabled: selectedBalanceEntry == null,
            onPressed: () {
              widget.onNextStep(selectedBalanceEntry!.address!);
            },
            child: TextButtonContent(
              value: "Continue",
            )),
      )
    ]);
  }
}
