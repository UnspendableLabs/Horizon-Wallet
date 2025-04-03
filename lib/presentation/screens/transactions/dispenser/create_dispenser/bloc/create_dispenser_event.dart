import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';

class CreateDispenserDependenciesRequested extends DependenciesRequested {
  final String assetName;
  final List<String> addresses;
  CreateDispenserDependenciesRequested({
    required this.assetName,
    required this.addresses,
  });
}

class CreateDispenserComposed
    extends TransactionComposed<CreateDispenserParams> {
  CreateDispenserComposed({
    required super.sourceAddress,
    required super.params,
  });

  String get destinationAddress => params.destinationAddress;

  String get asset => params.asset;

  int get quantity => params.quantity;
}

class CreateDispenserParams {
  final String destinationAddress;
  final String asset;
  final int quantity;

  CreateDispenserParams({
    required this.destinationAddress,
    required this.asset,
    required this.quantity,
  });
}

class CreateDispenserTransactionBroadcasted extends TransactionBroadcasted {
  CreateDispenserTransactionBroadcasted({required super.decryptionStrategy});
}
