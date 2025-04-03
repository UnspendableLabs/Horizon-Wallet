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
}

class CreateDispenserOnNewAddressParams {
  final String asset;
  final int giveQuantity;
  final bool divisible;
  final int escrowQuantity;
  final int mainchainrate;
  final bool sendExtraBtcToDispenser;

  CreateDispenserOnNewAddressParams({
    required this.asset,
    required this.giveQuantity,
    required this.divisible,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.sendExtraBtcToDispenser,
  });
}

class CreateDispenserOnNewAddressTransactionBroadcasted
    extends TransactionBroadcasted {
  CreateDispenserOnNewAddressTransactionBroadcasted(
      {required super.decryptionStrategy});
}
