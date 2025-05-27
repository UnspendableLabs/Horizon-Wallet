import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transactions/transaction_fee_selection.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';

class AttachAssetToSwap extends StatefulWidget {
  const AttachAssetToSwap({super.key});

  @override
  State<AttachAssetToSwap> createState() => _AttachAssetToSwapState();
}

class _AttachAssetToSwapState extends State<AttachAssetToSwap> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appIcons = AppIcons();
    final isDarkMode = theme.brightness == Brightness.dark;
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Text(
              "Attach Assets to Swap",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            commonHeightSizedBox,
            HorizonCard(
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
                              httpConfig: session.httpConfig,
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
                          style: theme.textTheme.labelSmall
                              ?.copyWith(height: 1.2)),
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
                            color: isDarkMode
                                ? transparentYellow8
                                : transparentPurple33,
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
            ),
            const SizedBox(height: 20),
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
                  child: TextButtonContent(value: "Sign and Submit")),
            )
          ],
        ),
      ),
    );
  }
}

