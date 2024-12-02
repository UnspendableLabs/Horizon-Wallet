abstract class ComposeDispenserOnNewAddressEvent {}

class FormOpened extends ComposeDispenserOnNewAddressEvent {
  final String originalAddress;

  FormOpened({required this.originalAddress});
}

class PasswordEntered extends ComposeDispenserOnNewAddressEvent {
  final String password;
  final String originalAddress;
  final bool divisible;
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final int status;
  final int feeRate;
  final bool sendExtraBtcToDispenser;
  PasswordEntered({
    required this.password,
    required this.originalAddress,
    required this.divisible,
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.status,
    required this.feeRate,
    required this.sendExtraBtcToDispenser,
  });
}

class SubmitPressed extends ComposeDispenserOnNewAddressEvent {}
