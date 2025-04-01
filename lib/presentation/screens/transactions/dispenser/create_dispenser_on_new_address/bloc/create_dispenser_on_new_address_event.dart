import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';

class CreateDispenserOnNewAddressDependenciesRequested
    extends DependenciesRequested {
  final String assetName;
  final List<String> addresses;
  CreateDispenserOnNewAddressDependenciesRequested({
    required this.assetName,
    required this.addresses,
  });
}

class CreateDispenserOnNewAddressComposed
    extends TransactionComposed<CreateDispenserOnNewAddressParams> {
  CreateDispenserOnNewAddressComposed({
    required super.sourceAddress,
    required super.params,
  });

  String get destinationAddress => params.destinationAddress;

  String get asset => params.asset;

  int get quantity => params.quantity;
}

class CreateDispenserOnNewAddressParams {
  final String destinationAddress;
  final String asset;
  final int quantity;

  CreateDispenserOnNewAddressParams({
    required this.destinationAddress,
    required this.asset,
    required this.quantity,
  });
}

class CreateDispenserOnNewAddressTransactionBroadcasted
    extends TransactionEvent {
  final String? password;

  CreateDispenserOnNewAddressTransactionBroadcasted({this.password});
}
