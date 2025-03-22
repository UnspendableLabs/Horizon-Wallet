import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';

/// Event triggered when the send page is loaded
class SendDependenciesRequested extends DependenciesRequested {
  SendDependenciesRequested({
    required super.assetName,
    required super.addresses,
  });
}

/// Event triggered when moving from input step to confirmation step in the send flow
class SendTransactionComposed extends TransactionComposed {
  final String? destinationAddress;
  final String? amount;

  SendTransactionComposed({
    this.destinationAddress,
    this.amount,
  });
}

/// Event triggered when moving from confirmation step to submission step in the send flow
class SendTransactionSubmitted extends TransactionSubmitted {
  SendTransactionSubmitted();
}
