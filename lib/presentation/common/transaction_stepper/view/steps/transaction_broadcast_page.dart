import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transactions/error.dart';
import 'package:horizon/presentation/common/transactions/transaction_successful.dart';

class TransactionBroadcastPage extends StatelessWidget {
  final BroadcastState broadcastState;

  const TransactionBroadcastPage({
    super.key,
    required this.broadcastState,
  });

  @override
  Widget build(BuildContext context) {
    return broadcastState.when(
      initial: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text('Your transaction is being processed'),
      ),
      loading: () => const TransactionSuccessful(
        loading: true,
      ),
      success: (data) => TransactionSuccessful(
        txHex: data.txHex,
        txHash: data.txHash,
        loading: false,
      ),
      error: (error) => TransactionError(
        errorMessage: error,
        onErrorButtonAction: () => Navigator.of(context).pop(),
        buttonText: 'Close',
      ),
    );
  }
}
