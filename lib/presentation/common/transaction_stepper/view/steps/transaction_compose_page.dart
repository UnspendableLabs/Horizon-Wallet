import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transactions/error.dart';
import 'package:horizon/presentation/common/transactions/fee_confirmation.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class TransactionComposePage<R> extends StatelessWidget {
  final Widget Function(ComposeStateSuccess<R> composeState)
      buildComposeContent;
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
      loading: () => const CircularProgressIndicator(),
      error: (errorMessage) => TransactionError(
        errorMessage: errorMessage,
        onErrorButtonAction: onErrorButtonAction,
        buttonText: errorButtonText,
      ),
      success: (composeSuccess) {
        final composeResponse = composeSuccess as ComposeResponse;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildComposeContent(ComposeStateSuccess<R>(composeSuccess)),
            commonHeightSizedBox,
            FeeConfirmation(
              fee: "${composeResponse.btcFee.toString()} sats",
              virtualSize: composeResponse.signedTxEstimatedSize.virtualSize,
              adjustedVirtualSize:
                  composeResponse.signedTxEstimatedSize.adjustedVirtualSize,
            ),
          ],
        );
      },
    );
  }
}
