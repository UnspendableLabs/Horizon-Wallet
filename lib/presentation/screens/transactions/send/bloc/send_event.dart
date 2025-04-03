import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';

class SendDependenciesRequested extends DependenciesRequested {
  final String assetName;
  final List<String> addresses;
  SendDependenciesRequested({
    required this.assetName,
    required this.addresses,
  });
}

class SendTransactionComposed
    extends TransactionComposed<SendTransactionParams> {
  SendTransactionComposed({
    required super.sourceAddress,
    required super.params,
  });

  String get destinationAddress => params.destinationAddress;

  String get asset => params.asset;

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

class SendTransactionBroadcasted extends TransactionEvent {
  final dynamic decryptionStrategy;

  SendTransactionBroadcasted({required this.decryptionStrategy});
}
