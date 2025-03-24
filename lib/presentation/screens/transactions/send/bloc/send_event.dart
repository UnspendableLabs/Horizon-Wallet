import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';

/// Event triggered when the send page is loaded
class SendDependenciesRequested extends DependenciesRequested {
  SendDependenciesRequested({
    required super.assetName,
    required super.addresses,
  });
}

/// Event triggered when moving from input step to confirmation step in the send flow
class SendTransactionComposed
    extends TransactionComposed<SendTransactionParams> {
  SendTransactionComposed({
    required super.sourceAddress,
    required super.params,
  });

  /// Get destination address from params
  String get destinationAddress => params.destinationAddress;

  /// Get asset from params
  String get asset => params.asset;

  /// Get quantity from params
  int get quantity => params.quantity;
}

class SendTransactionParams {
  final String destinationAddress;
  final String asset;
  final int quantity;

  SendTransactionParams({
    required this.destinationAddress,
    required this.asset,
    required this.quantity,
  });
}

/// Event triggered when moving from confirmation step to submission step in the send flow
class SendTransactionSubmitted extends TransactionSubmitted {
  SendTransactionSubmitted();
}
