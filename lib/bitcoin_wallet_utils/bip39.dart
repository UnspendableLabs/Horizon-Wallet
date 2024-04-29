import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:dartsv/dartsv.dart';

abstract class Bip39Service {
  String generateMnemonic();
  String mnemonicToSeedHex(String mnemonic);
  Uint8List mnemonicToSeed(String mnemonic);
  String mnemonicToEntropy(String mnemonic);
}

// TODO: should we use dartsv for seed??

// class Bip39DartSVImpl {
//   // @override
//   Future<String> generateMnemonic() async {
//     return await Mnemonic().generateMnemonic();
//   }

//   String mnemonicToSeedHex(String mnemonic) {
//     return Mnemonic().toSeedHex(mnemonic);
//   }

//   @override
//   Uint8List mnemonicToSeed(String mnemonic) {
//     return bip39.mnemonicToSeed(mnemonic);
//   }

//   @override
//   String mnemonicToEntropy(String mnemonic) {
//     return bip39.mnemonicToEntropy(mnemonic);
//   }
// }

class Bip39Impl implements Bip39Service {
  @override
  String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  @override
  String mnemonicToSeedHex(mnemonic) {
    return bip39.mnemonicToSeedHex(mnemonic);
  }

  @override
  Uint8List mnemonicToSeed(mnemonic) {
    return bip39.mnemonicToSeed(mnemonic);
  }

  @override
  String mnemonicToEntropy(mnemonic) {
    return bip39.mnemonicToEntropy(mnemonic);
  }
}
