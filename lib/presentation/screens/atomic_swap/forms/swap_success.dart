import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/transactions/success_animation.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class SwapSuccessStep extends StatefulWidget {
  const SwapSuccessStep({super.key});

  @override
  State<SwapSuccessStep> createState() => _SwapSuccessStepState();
}

class _SwapSuccessStepState extends State<SwapSuccessStep> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 218,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TxnSuccessAnimation(),
              ],
            ),
          ),
          Text(
            "Swap Successful",
            style: theme.textTheme.titleMedium,
          ),
          commonHeightSizedBox,
          Text("2 listings successfully fulfilled", style: theme.inputDecorationTheme.hintStyle,),
        ],
      ),
    ),
    );
  }
}