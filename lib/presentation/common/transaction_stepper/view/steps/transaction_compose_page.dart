import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transactions/error.dart';

class TransactionComposePage<R> extends StatelessWidget {
  final Widget Function(ComposeStateSuccess<R> composeState)
      buildComposeContent;
  final ComposeState<R> composeState;
  final VoidCallback onButtonAction;
  final String errorButtonText;
  final VoidCallback backHandler;

  const TransactionComposePage({
    super.key,
    required this.buildComposeContent,
    required this.composeState,
    required this.errorButtonText,
    required this.onButtonAction,
    required this.backHandler,
  });

  @override
  Widget build(BuildContext context) {
    return composeState.when(
      initial: () => const SizedBox.shrink(),
      loading: () => const CircularProgressIndicator(),
      error: (errorMessage) => TransactionError(
        errorMessage: errorMessage,
        onButtonAction: backHandler,
        buttonText: errorButtonText,
      ),
      success: (composeSuccess) =>
          buildComposeContent(ComposeStateSuccess<R>(composeSuccess)),
    );
  }
}
