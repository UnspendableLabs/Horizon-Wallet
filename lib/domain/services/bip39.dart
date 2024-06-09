import 'package:horizon/data/models/seed.dart';

abstract class Bip39Service {
  String generateMnemonic();
  Future<Seed> mnemonicToSeed(String mnemonic);
  Seed mnemonicToSeedSync(String mnemonic);
  String mnemonicToEntropy(String mnemonic);
  bool validateMnemonic(String mnemonic, [List<String>? wordlist]);
}
