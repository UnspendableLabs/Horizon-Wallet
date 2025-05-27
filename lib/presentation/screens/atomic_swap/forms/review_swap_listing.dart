import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/common/collapsable_view.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';

class SwapListingReview extends StatefulWidget {
  const SwapListingReview({super.key});

  @override
  State<SwapListingReview> createState() => _SwapListingReviewState();
}

class _SwapListingReviewState extends State<SwapListingReview> {
  _renderProperty(label, value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              textAlign: TextAlign.left,
              style: Theme.of(context).inputDecorationTheme.hintStyle),
          Text(value,
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>();
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    final appIcons = AppIcons();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Review Swap",
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        commonHeightSizedBox,
        Expanded(
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _renderProperty("Transaction Type", "Create listing"),
                        _renderProperty("Rate", "1 XCP = 0.001 BTC"),
                        _renderProperty("Swap Completion", "When order fills"),
                        const SizedBox(
                          height: 14,
                        ),
                        Stack(
                          children: [
                            Column(
                              children: [
                                HorizonCard(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    backgroundColor:
                                        customTheme?.bgBlackOrWhite,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("You'll Transfer",
                                            style: theme.inputDecorationTheme
                                                .hintStyle),
                                        const QuantityText(
                                          quantity: "120.00",
                                          style: TextStyle(fontSize: 35),
                                        ),
                                        Text(
                                          "~503.12 USD",
                                          style: theme.textTheme.titleSmall,
                                        ),
                                        commonHeightSizedBox,
                                        Text("Token name",
                                            style: theme.inputDecorationTheme
                                                .hintStyle),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              appIcons.assetIcon(
                                                  httpConfig:
                                                      session.httpConfig,
                                                  context: context,
                                                  assetName: "XCP",
                                                  width: 24,
                                                  height: 24),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Text("XCP",
                                                  style: theme
                                                      .textTheme.titleMedium
                                                      ?.copyWith(
                                                    fontSize: 12,
                                                  ))
                                            ])
                                      ],
                                    )),
                                commonHeightSizedBox,
                                HorizonCard(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    backgroundColor:
                                        customTheme?.bgBlackOrWhite,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("You'll receive",
                                            style: theme.inputDecorationTheme
                                                .hintStyle),
                                        const QuantityText(
                                          quantity: "0.00052356",
                                          style: TextStyle(fontSize: 35),
                                        ),
                                        Text(
                                          "~503.12 USD",
                                          style: theme.textTheme.titleSmall,
                                        ),
                                        commonHeightSizedBox,
                                        Text("Token name",
                                            style: theme.inputDecorationTheme
                                                .hintStyle),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              appIcons.assetIcon(
                                                  httpConfig:
                                                      session.httpConfig,
                                                  context: context,
                                                  assetName: "BTC",
                                                  width: 24,
                                                  height: 24),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Text("BTC",
                                                  style: theme
                                                      .textTheme.titleMedium
                                                      ?.copyWith(
                                                    fontSize: 12,
                                                  ))
                                            ])
                                      ],
                                    ))
                              ],
                            ),
                            Positioned(
                                top: 0,
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Material(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      hoverColor: transparentPurple8,
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {},
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: transparentWhite8,
                                              width: 1),
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        child: AppIcons.arrowDownIcon(
                                            context: context,
                                            width: 24,
                                            height: 24),
                                      ),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                        commonHeightSizedBox,
                        const Divider(
                          height: 20,
                          color: transparentWhite8,
                          thickness: 1,
                        ),
                        CollapsableWidget(
                          title: "Fee Details",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _renderProperty("Fee", "0.0001 BTC"),
                              _renderProperty("Virtual Size", "0.0001 BTC"),
                              _renderProperty(
                                  "Adjusted Virtual Size", "0.0001 BTC"),
                            ],
                          ),
                        ),
                        commonHeightSizedBox,
                        HorizonButton(
                            onPressed: () {},
                            child: TextButtonContent(value: "Sign and Submit")),
                        commonHeightSizedBox,
                      ],
                    ))))
      ],
    );
  }
}
