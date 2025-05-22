import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/collapsable_view.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class SwapFormReviewStep extends StatefulWidget {
  const SwapFormReviewStep({super.key});

  @override
  State<SwapFormReviewStep> createState() => _SwapFormReviewStepState();
}

class _SwapFormReviewStepState extends State<SwapFormReviewStep> {
  _gradQtyProperty(label, value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              textAlign: TextAlign.left,
              style: Theme.of(context).inputDecorationTheme.hintStyle),
          QuantityText(
            quantity: value,
            style: const TextStyle(fontSize: 35),
          )
        ],
      ),
    );
  }

  _regularProperty(label, value) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Review Swap",
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        commonHeightSizedBox,
        commonHeightSizedBox,
        Expanded(
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _gradQtyProperty("Number of Transactions", "2"),
                    _gradQtyProperty("Total you’ll send (BTC)", "0.006"),
                    _gradQtyProperty("Total you’ll receive (XCP)", "120.00"),
                    const Divider(
                      height: 20,
                      thickness: 1,
                      color: transparentWhite8,
                    ),
                    commonHeightSizedBox,
                    // https://www.figma.com/design/88EA0Ok35kyGqO8h6IszKR/Horizon-Wallet?node-id=1421-42115&t=qbscR16mEPwzXLt7-4
                    _regularProperty("Transaction Type", "Listing Fulfilment"),
                    _regularProperty("Rate", "1 BTC = 100 XCP"),
                    _regularProperty("Swap Completion", "Execute Immediately"),
                    const Divider(
                      height: 20,
                      thickness: 1,
                      color: transparentWhite8,
                    ),
                    commonHeightSizedBox,
                    CollapsableWidget(
                      title: "View Transactions",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _regularProperty(
                              "Transaction Type", "Listing Fulfilment"),
                          _regularProperty("Rate", "1 BTC = 100 XCP"),
                          _regularProperty(
                              "Swap Completion", "Execute Immediately"),
                        ],
                      ),
                    ),
                    commonHeightSizedBox,
                    CollapsableWidget(
                      title: "Fee Details",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _regularProperty("Fee", "0.0001 BTC"),
                          _regularProperty("Virtual Size", "0.0001 BTC"),
                          _regularProperty(
                              "Adjusted Virtual Size", "0.0001 BTC"),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ),
        const SizedBox(height: 28),
        HorizonButton(
            onPressed: () {}, child: TextButtonContent(value: "Continue")),
        const SizedBox(height: 28),
      ],
    );
  }
}
