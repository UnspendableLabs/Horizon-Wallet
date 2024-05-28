import 'package:horizon/common/constants.dart';

class CreateWalletPayload {
  String mnemonic;
  WalletType recoveryWallet;

  CreateWalletPayload({
    required this.mnemonic,
    required this.recoveryWallet,
  });
}
