import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/collapsable_view.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:formz/formz.dart';

import "./bloc/swap_presign_form_bloc.dart";

class SwapPresignFormActions {
  final VoidCallback onSubmitClicked;

  SwapPresignFormActions({
    required this.onSubmitClicked,
  });
}

class SwapPresignFormProvider extends StatelessWidget {
  final HttpConfig httpConfig;
  final List<AtomicSwap> atomicSwaps;
  final String assetName;

  final Widget Function(
    SwapPresignFormActions actions,
    SwapPresignFormModel state,
  ) child;

  const SwapPresignFormProvider({
    super.key,
    required this.child,
    required this.httpConfig,
    required this.atomicSwaps,
    required this.assetName,
  });
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SwapPresignFormBloc(atomicSwaps: atomicSwaps, assetName: assetName),
      child: BlocBuilder<SwapPresignFormBloc, SwapPresignFormModel>(
          builder: (context, state) {
        return child(
            SwapPresignFormActions(
                onSubmitClicked: () =>
                    context.read<SwapPresignFormBloc>().add(SubmitClicked())),
            state);
      }),
    );
  }
}

class SwapPresignSuccessHandler extends StatelessWidget {
  final Function(List<AtomicSwap> swaps) onSuccess;

  const SwapPresignSuccessHandler({super.key, required this.onSuccess});

  @override
  Widget build(context) {
    return BlocListener<SwapPresignFormBloc, SwapPresignFormModel>(
        listener: (context, state) {
          if (state.submissionStatus.isSuccess) {
            onSuccess(state.atomicSwaps);
          }
        },
        child: const SizedBox.shrink());
  }
}

// CHAT this compnent is oveflowing.
class SwapPresignForm extends StatelessWidget {
  final SwapPresignFormModel state;
  final SwapPresignFormActions actions;

  SwapPresignForm({
    super.key,
    required this.state,
    required this.actions,
  });

  _gradQtyProperty(label, value, theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              textAlign: TextAlign.left,
              style: theme.inputDecorationTheme.hintStyle),
          QuantityText(
            quantity: value,
            style: const TextStyle(fontSize: 35),
          )
        ],
      ),
    );
  }

  _regularProperty(label, value, theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              textAlign: TextAlign.left,
              style: theme.inputDecorationTheme.hintStyle),
          Text(value,
              textAlign: TextAlign.left, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        commonHeightSizedBox,
        SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _gradQtyProperty("Number of Transactions",
                      state.transactionCount.toString(), theme),
                  _gradQtyProperty("Total you’ll send (BTC)",
                      state.totalBtc.normalizedPretty(precision: 8), theme),
                  _gradQtyProperty(
                      "Total you’ll receive (${state.assetName})",
                      state.totalRecieveAsset.normalizedPretty(precision: 8),
                      theme),
                  const Divider(
                    height: 20,
                    thickness: 1,
                    color: transparentWhite8,
                  ),
                  commonHeightSizedBox,
                  // https://www.figma.com/design/88EA0Ok35kyGqO8h6IszKR/Horizon-Wallet?node-id=1421-42115&t=qbscR16mEPwzXLt7-4
                  _regularProperty(
                      "Transaction Type", "Listing Fulfilment", theme),
                  _regularProperty(
                      "Swap Completion", "Execute Immediately", theme),
                  const Divider(
                    height: 20,
                    thickness: 1,
                    color: transparentWhite8,
                  ),
                  commonHeightSizedBox,
                ],
              ),
            )),
        const SizedBox(height: 28),
        HorizonButton(
            onPressed: () {
                actions.onSubmitClicked();
            },
            child: TextButtonContent(value: "Continue")),
        const SizedBox(height: 28),
      ],
    );
  }
}
