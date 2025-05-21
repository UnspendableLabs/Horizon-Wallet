import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';

class SwapFormCompose extends StatefulWidget {
  
  const SwapFormCompose({super.key});

  @override
  State<SwapFormCompose> createState() => _SwapFormComposeState();
}

class _SwapFormComposeState extends State<SwapFormCompose> {
  // TODO: fake data
  final toAsset = MultiAddressBalance(
    asset: 'XCP',
    assetLongname: null,
    total: 1000000000,
    totalNormalized: '10.00000000',
    entries: [
      MultiAddressBalanceEntry(
        address: 'XcpAddress123',
        quantity: 1000000000,
        quantityNormalized: '10.00000000',
      ),
    ],
    assetInfo: const AssetInfo(
      description: "XCP",
      divisible: true,
      locked: false,
    ),
  );

  final fromAsset = MultiAddressBalance(
    asset: 'BTC',
    assetLongname: null,
    total: 1000000000,
    totalNormalized: '10.00000000',
    entries: [
      MultiAddressBalanceEntry(
        address: 'BtcAddress123',
        quantity: 1000000000,
        quantityNormalized: '10.00000000',
      ),
    ],
    assetInfo: const AssetInfo(
      description: "BTC",
      divisible: true,
      locked: false,
    ),
  );

  // TODO: slider value
  double swapValue = 0;

  Widget _buildRow(String quantity, String price, String priceUsd, String total, String totalUsd, bool isSelected) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected)
                  AppIcons.checkCircleIcon(context: context, color: green1, width: 24, height: 24)
                else
                  AppIcons.plusCircleIcon(
                      context: context, color: transparentPurple33, width: 24, height: 24),
                const SizedBox(width: 8),
                Text(quantity, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: theme.textTheme.bodySmall),
                Text(priceUsd, 
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.extension<CustomThemeExtension>()!.mutedDescriptionTextColor
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(total, style: theme.textTheme.bodySmall),
                Text(totalUsd, 
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.extension<CustomThemeExtension>()!.mutedDescriptionTextColor
                  ),
                ),
                const SizedBox(width: 8,)

              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    final theme = Theme.of(context);
    final appIcons = AppIcons();
    return SizedBox(
      height: double.infinity,
      child: Column(
        children: [
          Text(
            "Swap",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 14),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              children: [
                Expanded(
                    child: HorizonCard(
                        child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        QuantityText(
                          quantity: swapValue.toString(),
                          style: const TextStyle(
                            fontSize: 35,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            appIcons.assetIcon(
                                httpConfig: session.httpConfig,
                                assetName: toAsset.asset,
                                context: context,
                                width: 24,
                                height: 24),
                            const SizedBox(width: 8),
                            Text(toAsset.asset,
                                style: theme.textTheme.titleMedium!.copyWith(
                                  fontSize: 12,
                                )),
                          ],
                        ),
                      ],
                    ),
                    commonHeightSizedBox,
                    HorizonSlider(
                      value: swapValue,
                      min: 0,
                      max: double.parse(fromAsset.totalNormalized),
                      onChanged: (value) {
                        setState(() {
                          swapValue = double.parse(value.toStringAsFixed(2));
                        });
                      },
                    ),
                    commonHeightSizedBox,
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            // Header Row
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text('Quantity', 
                                    style: theme.textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text('Price', 
                                    style: theme.textTheme.bodySmall,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text('Total', 
                                    style: theme.textTheme.bodySmall,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Data Rows
                            _buildRow('23.45678912', '0.00123456', '15.78901234', '23.45678912', '15.78901234', true),
                            _buildRow('67.89012345', '0.00789012', '8.90123456', '67.89012345', '8.90123456', false),
                            _buildRow('156.78901234', '0.00234567', '12.34567890', '156.78901234', '12.34567890', false),
                            _buildRow('156.78901234', '0.00234567', '12.34567890', '156.78901234', '12.34567890', false),
                            _buildRow('156.78901234', '0.00234567', '12.34567890', '156.78901234', '12.34567890', false),
                            _buildRow('156.78901234', '0.00234567', '12.34567890', '156.78901234', '12.34567890', false),
                            _buildRow('156.78901234', '0.00234567', '12.34567890', '156.78901234', '12.34567890', false),
                            _buildRow('156.78901234', '0.00234567', '12.34567890', '156.78901234', '12.34567890', false),
                            _buildRow('156.78901234', '0.00234567', '12.34567890', '156.78901234', '12.34567890', false),
                            _buildRow('156.78901234', '0.00234567', '12.34567890', '156.78901234', '12.34567890', false),
                          ],
                        ),
                      ),
                    )
                  ],
                ))),
                const SizedBox(height: 20),
                HorizonCard(
                    padding: const EdgeInsets.all(0),
                    backgroundColor: Colors.transparent,
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("You Pay",
                                    style: theme.textTheme.titleSmall),
                                const SizedBox(width: 12),
                                const QuantityText(
                                  quantity: "0.000BTC",
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Text("\$0.00",
                                style: theme.textTheme.titleSmall,
                                textAlign: TextAlign.end),
                          ],
                        ),
                      ),
                      HorizonButton(
                        child: TextButtonContent(value: "Swap"),
                        onPressed: () {},
                        variant: ButtonVariant.green,
                      ),
                    ])),
                const SizedBox(height: 14),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Horizon Fee",
                          style: theme.textTheme.titleSmall!.copyWith(
                            color: theme
                                .extension<CustomThemeExtension>()!
                                .mutedDescriptionTextColor,
                          )),
                      Text("0.00000000 XCP",
                          textAlign: TextAlign.end,
                          style: theme.textTheme.titleSmall!.copyWith(
                            color: theme
                                .extension<CustomThemeExtension>()!
                                .mutedDescriptionTextColor,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
