abstract class ComposeDispenserOnNewAddressEvent {}

class ComposeTransactions extends ComposeDispenserOnNewAddressEvent {
  final String password;
  final String originalAddress;
  final bool divisible;
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final int status;
  final int feeRate;

  ComposeTransactions({
    required this.password,
    required this.originalAddress,
    required this.divisible,
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.status,
    required this.feeRate,
  });
}

class BroadcastTransactions extends ComposeDispenserOnNewAddressEvent {

}
