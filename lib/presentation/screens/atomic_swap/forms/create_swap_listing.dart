import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transactions/transaction_fee_selection.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';

class CreateSwapListing extends StatefulWidget {
  const CreateSwapListing({super.key});

  @override
  State<CreateSwapListing> createState() => _CreateSwapListingState();
}

class _CreateSwapListingState extends State<CreateSwapListing> {
  final appIcons = AppIcons();
  _buildFromCard(BuildContext context, HttpConfig httpConfig) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return HorizonCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                  child: QuantityText(
                quantity: "120.00",
                style: TextStyle(fontSize: 35),
              )),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  appIcons.assetIcon(
                      httpConfig: httpConfig,
                      assetName: "XCP",
                      context: context,
                      width: 24,
                      height: 24),
                  const SizedBox(width: 8),
                  Text("XCP",
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontSize: 12,
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("120.00 XCP",
                  style: theme.textTheme.labelSmall?.copyWith(height: 1.2)),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () {
                  // TODO: on tap Max
                },
                child: Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? transparentYellow8 : transparentPurple33,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Max',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: isDarkMode ? yellow1 : duskGradient2,
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  _buildToCard(BuildContext context, HttpConfig httpConfig) {
    final theme = Theme.of(context);
    return HorizonCard(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                  child: QuantityText(
                quantity: "0.00",
                style: TextStyle(fontSize: 35),
              )),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  appIcons.assetIcon(
                      httpConfig: httpConfig,
                      assetName: "BTC",
                      context: context,
                      width: 24,
                      height: 24),
                  const SizedBox(width: 8),
                  Text("BTC",
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontSize: 12,
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Text("0.00 USD",
              style: theme.textTheme.labelSmall?.copyWith(height: 1.2)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Text(
              "Swap Listing",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            commonHeightSizedBox,
            Stack(
              children: [
                Column(
                  children: [
                    _buildFromCard(context, session.httpConfig),
                    commonHeightSizedBox,
                    _buildToCard(context, session.httpConfig),
                  ],
                ),
                Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Material(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          hoverColor: transparentPurple8,
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            //  TODO: rotate tokens
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: transparentWhite8, width: 1),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: AppIcons.arrowDownIcon(
                                context: context, width: 24, height: 24),
                          ),
                        ),
                      ),
                    ))
              ],
            ),
            commonHeightSizedBox,
            TransactionFeeSelection(
              selectedFeeOption: Medium(),
              onFeeOptionSelected: (value) {},
              feeEstimates: const FeeEstimates(fast: 4, medium: 3, slow: 2),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: HorizonButton(
                  disabled: false,
                  onPressed: () {},
                  child: TextButtonContent(value: "Create listing")),
            )
          ],
        ),
      ),
    );
  }
}
