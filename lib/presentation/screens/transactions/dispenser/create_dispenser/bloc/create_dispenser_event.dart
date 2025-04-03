import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';

class CreateDispenserDependenciesRequested extends DependenciesRequested {
  final String assetName;
  final List<String> addresses;
  CreateDispenserDependenciesRequested({
    required this.assetName,
    required this.addresses,
  });
}

class CreateDispenserAddressSelected extends TransactionEvent {
  final String address;
  CreateDispenserAddressSelected({
    required this.address,
  });
}

class CreateDispenserComposed
    extends TransactionComposed<CreateDispenserParams> {
  CreateDispenserComposed({
    required super.sourceAddress,
    required super.params,
  });
}

class CreateDispenserParams {
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final int status;

  CreateDispenserParams({
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.status,
  });
}

class CreateDispenserTransactionBroadcasted extends TransactionBroadcasted {
  CreateDispenserTransactionBroadcasted({required super.decryptionStrategy});
}
