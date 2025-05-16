import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transactions/transaction_error.dart';
import 'package:horizon/presentation/common/transactions/fee_confirmation.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class TransactionComposePage<R> extends StatelessWidget {
  final Widget Function(
      {ComposeStateSuccess<R>? composeState,
      required bool loading}) buildComposeContent;
  final ComposeState<R> composeState;
  final VoidCallback onErrorButtonAction;
  final String errorButtonText;

  const TransactionComposePage({
    super.key,
    required this.buildComposeContent,
    required this.composeState,
    required this.errorButtonText,
    required this.onErrorButtonAction,
  });

  @override
  Widget build(BuildContext context) {
    return composeState.when(
      initial: () => const SizedBox.shrink(),
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildComposeContent(loading: true),
          commonHeightSizedBox,
          const FeeConfirmation(
            loading: true,
          ),
        ],
      ),
      error: (errorMessage) => TransactionError(
        errorMessage: errorMessage,
        onErrorButtonAction: onErrorButtonAction,
        buttonText: errorButtonText,
      ),
      success: (composeSuccess) {
        final composeResponse = composeSuccess;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildComposeContent(
                composeState: ComposeStateSuccess<R>(composeSuccess),
                loading: false),
            commonHeightSizedBox,
            if (composeResponse is ComposeResponse)
              ...[
                const Divider(
                  thickness: 1,
                  height: 20,
                  color:  transparentWhite8,
                ),
                FeeConfirmation(
                fee: "${composeResponse.btcFee.toString()} sats",
                virtualSize: composeResponse.signedTxEstimatedSize.virtualSize,
                adjustedVirtualSize:
                    composeResponse.signedTxEstimatedSize.adjustedVirtualSize,
              ),
              ]
          ],
        );
      },
    );
  }
}
