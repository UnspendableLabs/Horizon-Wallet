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

class SwapListingSlider extends StatefulWidget {
  const SwapListingSlider({
    super.key,
  });

  @override
  State<SwapListingSlider> createState() => _SwapListingSliderState();
}

class _SwapListingSliderState extends State<SwapListingSlider> {
  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    final theme = Theme.of(context);
    final appIcons = AppIcons();

    const cardHeight = 366.0;

    return const Column(
      children: [
        SizedBox(
          height: cardHeight,
          width: double.infinity,
          child: HorizonCard(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Line 1"),
                  SizedBox(height: 12),
                  Text("Line 2"),
                  SizedBox(height: 12),
                  Text("Line 3"),
                  SizedBox(height: 12),
                  Text("More content..."),
                  SizedBox(height: 400), // simulate long content
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        Text("button"),
      ],
    );
  }
}

class SwapListingSlider_ extends StatefulWidget {
  final Function() onNextStep;
  const SwapListingSlider_({super.key, required this.onNextStep});

  @override
  State<SwapListingSlider_> createState() => _SwapListingSlider_State();
}

class _SwapListingSlider_State extends State<SwapListingSlider_> {
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

  double swapValue = 0;

  Widget _buildRow(String quantity, String price, String priceUsd, String total,
      String totalUsd, bool isSelected) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                if (isSelected)
                  AppIcons.checkCircleIcon(
                      context: context, color: green1, width: 24, height: 24)
                else
                  AppIcons.plusCircleIcon(
                      context: context,
                      color: transparentPurple33,
                      width: 24,
                      height: 24),
                const SizedBox(width: 8),
                Text(quantity, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: theme.textTheme.bodySmall),
                Text(priceUsd,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme
                          .extension<CustomThemeExtension>()!
                          .mutedDescriptionTextColor,
                    )),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(total, style: theme.textTheme.bodySmall),
                Text(totalUsd,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme
                          .extension<CustomThemeExtension>()!
                          .mutedDescriptionTextColor,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMultipleRows() {
    return List.generate(
      10,
      (index) => _buildRow(
        '156.78901234',
        '0.00234567',
        '12.34567890',
        '156.78901234',
        '12.34567890',
        index == 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    final theme = Theme.of(context);
    final appIcons = AppIcons();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text("Swap",
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: HorizonCard(
              padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        QuantityText(
                          quantity: swapValue.toString(),
                          style: const TextStyle(fontSize: 35),
                        ),
                        Row(
                          children: [
                            appIcons.assetIcon(
                              httpConfig: session.httpConfig,
                              assetName: toAsset.asset,
                              context: context,
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              toAsset.asset,
                              style: theme.textTheme.titleMedium!
                                  .copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: HorizonSlider(
                      value: swapValue,
                      min: 0,
                      max: double.parse(fromAsset.totalNormalized),
                      onChanged: (value) {
                        setState(() {
                          swapValue = double.parse(value.toStringAsFixed(2));
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                SizedBox(
                  height: 34,
                  child: Row(
                    children: [
                      Expanded(
                        child:
                            Text('Quantity', style: theme.textTheme.bodySmall),
                      ),
                      Expanded(
                        child: Text('Price (sats/${toAsset.asset})',
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodySmall),
                      ),
                      Expanded(
                        child: Text('Total',
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodySmall),
                      ),
                    ],
                  ),
                ),
                ..._buildMultipleRows(),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                HorizonCard(
                  padding: const EdgeInsets.all(0),
                  backgroundColor: Colors.transparent,
                  child: Column(
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text("You Pay", style: TextStyle(fontSize: 14)),
                                SizedBox(width: 12),
                                QuantityText(
                                    quantity: "0.000BTC",
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                            Text("\$0.00", textAlign: TextAlign.end),
                          ],
                        ),
                      ),
                      HorizonButton(
                        child: TextButtonContent(value: "Swap"),
                        onPressed: widget.onNextStep,
                        variant: ButtonVariant.green,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Horizon Fee",
                        style: theme.textTheme.titleSmall!.copyWith(
                          color: theme
                              .extension<CustomThemeExtension>()!
                              .mutedDescriptionTextColor,
                        )),
                    Text("0.00000000 XCP",
                        style: theme.textTheme.titleSmall!.copyWith(
                          color: theme
                              .extension<CustomThemeExtension>()!
                              .mutedDescriptionTextColor,
                        )),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
