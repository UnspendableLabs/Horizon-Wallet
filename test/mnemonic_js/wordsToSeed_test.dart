import 'package:counterparty_wallet/secure_utils/mnemonic_js.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/test.dart';

void main() async {
  await dotenv.load();

  group('Test Bip44 mainnet', () {
    var mnemonicJs = MnemonicJs();

    test('wordsToSeed', () {
      String words = "grey climb demon snap shove fruit grasp hum self";
      String seedHex = mnemonicJs.wordsToSeed(words);
      print('SEED HEX $seedHex');
    });
  });
}
