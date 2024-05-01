import 'package:dartsv/dartsv.dart';
import 'package:test/test.dart';
import 'package:uniparty/bitcoin_wallet_utils/bip39.dart';
import 'package:uniparty/bitcoin_wallet_utils/key_derivation.dart';
import 'package:uniparty/common/constants.dart';

void main() async {
  group('createBip32PubKeyPrivateKeyFromSeed testnet', () {
    final bip39 = Bip39Impl();

    test('generates an expected bip32 public key and private key for index 0', () {
      String mnemonic = 'trend pond enable empower govern example melody bless alone grow stone genre';
      String basePath = 'm/0\'/0/0';

      HDPrivateKey seededKey = deriveSeededKey(bip39.mnemonicToSeedHex(mnemonic), NetworkEnum.testnet);

      HDPrivateKey derivedKey = deriveChildKey(seededKey, basePath);

      derivedKey.networkType = NetworkType.TEST;
      SVPrivateKey xpriv = derivedKey.privateKey;
      HDPublicKey xPub = derivedKey.hdPublicKey;
      SVPublicKey svpubKey = xPub.publicKey;
      String publicKey = svpubKey.toHex();
      String privateKey = xpriv.toWIF();

      expect(publicKey, '033602c9263d18189c2bc67e7ef09ab7fbff3d3ed0c2c71516565637bcb8d166b4');
      expect(privateKey, 'cQaABYSBHZF8rmvAcB825rmfx2RXdPrJJeSXdb2CmJkGhMsj5Csh');
    });

    test('generates an expected bip32 public key and private key for index 0', () {
      String mnemonic = 'crowd assume laugh area stick visa cricket mountain industry sustain very mask';
      String basePath = 'm/0\'/0/0';

      HDPrivateKey seededKey = deriveSeededKey(bip39.mnemonicToSeedHex(mnemonic), NetworkEnum.testnet);

      HDPrivateKey derivedKey = deriveChildKey(seededKey, basePath);

      derivedKey.networkType = NetworkType.TEST;
      SVPrivateKey xpriv = derivedKey.privateKey;
      HDPublicKey xPub = derivedKey.hdPublicKey;
      SVPublicKey svpubKey = xPub.publicKey;
      String publicKey = svpubKey.toHex();
      String privateKey = xpriv.toWIF();

      expect(publicKey, '0379883a74a258be10bd69a037dbb85b765a78a73c60338a919848360fe8b8012a');
      expect(privateKey, 'cMjs5LcSeGuyNKD898WXhkuwR5aNXEe195JFZkyxvqAWh6TiErf6');
    });

    test('generates an expected bip32 public key and private key for index 12', () {
      String mnemonic = 'fitness uncle finish promote car deny dish pact pepper bronze swift gallery';
      String basePath = 'm/0\'/0/12';

      HDPrivateKey seededKey = deriveSeededKey(bip39.mnemonicToSeedHex(mnemonic), NetworkEnum.testnet);

      HDPrivateKey derivedKey = deriveChildKey(seededKey, basePath);

      derivedKey.networkType = NetworkType.TEST;
      SVPrivateKey xpriv = derivedKey.privateKey;
      HDPublicKey xPub = derivedKey.hdPublicKey;
      SVPublicKey svpubKey = xPub.publicKey;
      String publicKey = svpubKey.toHex();
      String privateKey = xpriv.toWIF();

      expect(publicKey, '031dace6cae4dce49f05ca0e8d134a984b91475613f2011f461c2913f0bb9d24db');
      expect(privateKey, 'cPjRjRtbE8Bb2jCnXnuNCo6QDSmYEVJuLF5tRrjxHER48hQ6Zhn7');
    });

    test('generates an expected bip32 public key and private key for index 2', () {
      String mnemonic = 'lecture job rare oil worth annual stem august doctor royal boring planet';
      String basePath = 'm/0\'/0/2';

      HDPrivateKey seededKey = deriveSeededKey(bip39.mnemonicToSeedHex(mnemonic), NetworkEnum.testnet);

      HDPrivateKey derivedKey = deriveChildKey(seededKey, basePath);

      derivedKey.networkType = NetworkType.TEST;
      SVPrivateKey xpriv = derivedKey.privateKey;
      HDPublicKey xPub = derivedKey.hdPublicKey;
      SVPublicKey svpubKey = xPub.publicKey;
      String publicKey = svpubKey.toHex();
      String privateKey = xpriv.toWIF();

      expect(publicKey, '024ce3f08b4e7ef004365122349c11dbb0f6c6e1424b4801d173063ccbeaa10e5d');
      expect(privateKey, 'cUpS1sr9MX5jYVaFNKEvqd95yHitn2oA6CXhtRcE8BGaob7rWKbM');
    });
  });
}
