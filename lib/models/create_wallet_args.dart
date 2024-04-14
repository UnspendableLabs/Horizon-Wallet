import 'package:uniparty/models/constants.dart';

class CreateWalletPayload {
  String mnemonic;
  RecoveryWalletEnum recoveryWallet;

  CreateWalletPayload({
    required this.mnemonic,
    required this.recoveryWallet,
  });
}
