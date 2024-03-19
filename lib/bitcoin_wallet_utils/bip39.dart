import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;

class Bip39 {
  String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  String mnemonicToSeedHex(mnemonic) {
    return bip39.mnemonicToSeedHex(mnemonic);
  }

  Uint8List mnemonicToSeed(mnemonic) {
    return bip39.mnemonicToSeed(mnemonic);
  }

  String mnemonicToEntropy(mnemonic) {
    return bip39.mnemonicToEntropy(mnemonic);
  }
}
