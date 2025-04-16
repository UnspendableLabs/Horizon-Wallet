import 'package:horizon/data/models/seed.dart';
import 'package:horizon/domain/services/bip39.dart';

class Bip39ServiceNative implements Bip39Service {
  @override
  String generateMnemonic() {
    throw UnimplementedError();
  }

  @override
  Future<Seed> mnemonicToSeed(String mnemonic) async {
    throw UnimplementedError();
  }

  @override
  Seed mnemonicToSeedSync(String mnemonic) {
    throw UnimplementedError();
  }

  @override
  String mnemonicToEntropy(String mnemonic) {
    throw UnimplementedError();
  }

  @override
  bool validateMnemonic(String mnemonic, [List<String>? wordlist]) {
    throw UnimplementedError();
  }
}
