import 'dart:js_interop';

import 'package:horizon/data/models/seed.dart';
import 'package:horizon/domain/services/bip39.dart';
import 'package:horizon/js/bip39.dart' as bip39js;

class Bip39ServiceWeb implements Bip39Service {
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
    return bip39js.validateMnemonic(
        mnemonic, wordlist?.map((word) => word.toJS).toList().toJS);
  }
}

Bip39Service createBip39ServiceImpl() => Bip39ServiceWeb();
