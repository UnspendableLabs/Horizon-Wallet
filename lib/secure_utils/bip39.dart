import 'package:bip39/bip39.dart' as bip39;

class Bip39 {
  String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  String mnemonicToSeedHex(mnemonic) {
    return bip39.mnemonicToSeedHex(mnemonic);
  }
}
