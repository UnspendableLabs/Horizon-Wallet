import 'package:horizon/domain/services/bip39.dart';
import 'package:horizon/data/models/seed.dart';

class Bip39ServiceStub implements Bip39Service {
  Never _unsupported(String fn) =>
      throw UnimplementedError('$fn is not supported on this platform.');

  @override
  String generateMnemonic() => _unsupported('generateMnemonic');

  @override
  Future<Seed> mnemonicToSeed(String mnemonic) =>
      Future.error(_unsupported('mnemonicToSeed'));

  @override
  Seed mnemonicToSeedSync(String mnemonic) =>
      _unsupported('mnemonicToSeedSync');

  @override
  String mnemonicToEntropy(String mnemonic) =>
      _unsupported('mnemonicToEntropy');

  @override
  bool validateMnemonic(String mnemonic, [List<String>? wordlist]) =>
      _unsupported('validateMnemonic');
}

Bip39Service createBip39ServiceImpl() => Bip39ServiceStub();
