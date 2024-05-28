import 'dart:js_interop';

import 'package:horizon/js/bip39.dart' as bip39js;
import 'package:horizon/models/seed.dart';

abstract class Bip39Service {
  String generateMnemonic();
  Future<Seed> mnemonicToSeed(String mnemonic);
  Seed mnemonicToSeedSync(String mnemonic);
  String mnemonicToEntropy(String mnemonic);
  bool validateMnemonic(String mnemonic, [List<String>? wordlist]);
}

class Bip39JSService implements Bip39Service {
  @override
  String generateMnemonic() {
    return bip39js.generateMnemonic();
  }

  @override
  Future<Seed> mnemonicToSeed(String mnemonic) async {
    final seed = await bip39js.mnemonicToSeed(mnemonic).toDart;
    return Seed(seed.toDart);
  }

  @override
  Seed mnemonicToSeedSync(String mnemonic) {
    final seed = bip39js.mnemonicToSeedSync(mnemonic).toDart;
    return Seed(seed);
  }

  @override
  String mnemonicToEntropy(String mnemonic) {
    return bip39js.mnemonicToEntropy(mnemonic);
  }

  @override
  bool validateMnemonic(String mnemonic, [List<String>? wordlist]) {
    return bip39js.validateMnemonic(mnemonic, wordlist?.map((word) => word.toJS).toList().toJS);
  }
}
