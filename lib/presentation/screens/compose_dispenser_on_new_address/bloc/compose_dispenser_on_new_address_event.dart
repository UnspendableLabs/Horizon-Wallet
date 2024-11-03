abstract class ComposeDispenserOnNewAddressEvent {}

class FetchFormData extends ComposeDispenserOnNewAddressEvent {}

class CollectPassword extends ComposeDispenserOnNewAddressEvent {}

class ComposeTransactions extends ComposeDispenserOnNewAddressEvent {
  final String password;
  final String originalAddress;
  final bool divisible;
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final int status;

  ComposeTransactions({
    required this.password,
    required this.originalAddress,
    required this.divisible,
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.status,
  });
}
