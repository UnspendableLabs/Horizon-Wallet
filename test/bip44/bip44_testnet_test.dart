import 'package:dartsv/dartsv.dart';
import 'package:test/test.dart';
import 'package:uniparty/bitcoin_wallet_utils/bip39.dart';
import 'package:uniparty/bitcoin_wallet_utils/key_derivation.dart';
import 'package:uniparty/common/constants.dart';

void main() async {
  group('Test Bip44 testnet', () {
    var bip39 = Bip39Impl();

    test('generates an expected bip44 public key and private key for index 0', () {
      String mnemonic = 'trend pond enable empower govern example melody bless alone grow stone genre';
      String seedHex = bip39.mnemonicToSeedHex(mnemonic);

      expect(seedHex,
          '82fe40a0c31ac27e19bc302c5ed322158cfdbeb78ed3577e89ecf73abb838670fe4a1d17d3914ea4df8de75c6e98fa87603f6578dffbb039b5680504f84b2a4b');

      String basePath = 'm/44\'/1\'/0\'/0/0';

      HDPrivateKey seededKey = deriveSeededKey(seedHex, NetworkEnum.testnet);

      HDPrivateKey derivedKey = deriveChildKey(seededKey, basePath);

      derivedKey.networkType = NetworkType.TEST;
      SVPrivateKey xpriv = derivedKey.privateKey;
      HDPublicKey xPub = derivedKey.hdPublicKey;
      SVPublicKey svpubKey = xPub.publicKey;
      String publicKey = svpubKey.toHex();
      String privateKey = xpriv.toWIF();

      expect(publicKey, '03b22da4ea31c025dbff534f32a1a5fb6498fbd4d2f0517808101b83a164bbed6a');
      expect(privateKey, 'cS9NzwfpCRK22faDntv4WK4yNJ7ZPtwVY9HqJVD4UaKzWoLuhRG1');
    });

    test('generates an expected bip44 public key and private key for index 1', () {
      String mnemonic = 'stumble prison flip merge negative ostrich myself winter naive try arctic olympic';
      String seedHex = bip39.mnemonicToSeedHex(mnemonic);

      expect(seedHex,
          '941807f8e36f39910ff6eb2c160de428b78a46609374d7aa4673e5a010219b39c310591b0e0e8876bb6cef5c982868b34c6f0cee4d188d31afe5e7ee9f315fbb');

      String basePath = 'm/44\'/1\'/0\'/0/1';

      HDPrivateKey seededKey = deriveSeededKey(seedHex, NetworkEnum.testnet);

      HDPrivateKey derivedKey = deriveChildKey(seededKey, basePath);

      derivedKey.networkType = NetworkType.TEST;
      SVPrivateKey xpriv = derivedKey.privateKey;
      HDPublicKey xPub = derivedKey.hdPublicKey;
      SVPublicKey svpubKey = xPub.publicKey;
      String publicKey = svpubKey.toHex();
      String privateKey = xpriv.toWIF();

      expect(publicKey, '02edc3249db2cc22da66c90ac7772f66ddf673d0909a1e6845515263901d46728c');
      expect(privateKey, 'cTrS2JX2UiU2go8dun9abjPN41YM5wRrHeS8gPeVk2GUhVj8rRWr');
    });

    test('generates an expected bip44 public key and private key for index 38', () {
      String mnemonic = 'thunder member interest display shock unable clarify fiber insect lumber battle off';
      String seedHex = bip39.mnemonicToSeedHex(mnemonic);

      expect(seedHex,
          '23926ae31d75602cbdac79c4d0e39f4b37d763a6ccb3596b6b7de6d2328536695682ab224d2074d0a23dd4f258ba32ab96b1a2a2dfe00a1e8bd4f1704bceb460');

      String basePath = 'm/44\'/1\'/0\'/0/38';

      HDPrivateKey seededKey = deriveSeededKey(seedHex, NetworkEnum.testnet);

      HDPrivateKey derivedKey = deriveChildKey(seededKey, basePath);

      derivedKey.networkType = NetworkType.TEST;
      SVPrivateKey xpriv = derivedKey.privateKey;
      HDPublicKey xPub = derivedKey.hdPublicKey;
      SVPublicKey svpubKey = xPub.publicKey;
      String publicKey = svpubKey.toHex();
      String privateKey = xpriv.toWIF();

      expect(publicKey, '02e2a9207c4cb53272c4399c4275463c029b9baa7b44ba2475598b86af7063d9b1');
      expect(privateKey, 'cTdkp2fYUtbZJvPRr4eUW8rwSHH2mVG4rg7SpvN3vb3VAZifJZGD');
    });

    test('generates an expected bip44 public key and private key for index 45', () {
      String mnemonic = 'crime speak truly valid movie describe blame essay crack skirt december obey';
      String seedHex = bip39.mnemonicToSeedHex(mnemonic);

      expect(seedHex,
          'adb15ee789225d60da76a716c9dc9e02c12e7a248e07a26628a94e600b613a74c8a538c0ff4114e570650a96db386e20c158eda2e5405042906f9cad858e80c8');

      String basePath = 'm/44\'/1\'/0\'/0/45';

      HDPrivateKey seededKey = deriveSeededKey(seedHex, NetworkEnum.testnet);

      HDPrivateKey derivedKey = deriveChildKey(seededKey, basePath);

      derivedKey.networkType = NetworkType.TEST;
      SVPrivateKey xpriv = derivedKey.privateKey;
      HDPublicKey xPub = derivedKey.hdPublicKey;
      SVPublicKey svpubKey = xPub.publicKey;
      String publicKey = svpubKey.toHex();
      String privateKey = xpriv.toWIF();

      expect(publicKey, '030dd386e918e0282a364ba53f18c6f5911ff917d1a55a5e2a6badec97c5f94d34');
      expect(privateKey, 'cSHNUPvLPs8QhcQajAJGXSCw4rJsoDFjUESYm8h8LWphYNmrPRXQ');
    });

    test('generates an expected bip44 public key and private key for index 5', () {
      String mnemonic = 'sorry hub gadget wasp repeat wave disagree knock prosper rose gas dinner';
      String seedHex = bip39.mnemonicToSeedHex(mnemonic);

      expect(seedHex,
          'b8e207c740d1fd56cdd1c03ed5a0facf46e6a06e3720a8f6e9a9eb874c7e177f47fa6174553849d71fec2037da44bd046316cd5a3528e57a165bd02913290f11');

      String basePath = 'm/44\'/1\'/0\'/0/5';

      HDPrivateKey seededKey = deriveSeededKey(seedHex, NetworkEnum.testnet);

      HDPrivateKey derivedKey = deriveChildKey(seededKey, basePath);

      derivedKey.networkType = NetworkType.TEST;
      SVPrivateKey xpriv = derivedKey.privateKey;
      HDPublicKey xPub = derivedKey.hdPublicKey;
      SVPublicKey svpubKey = xPub.publicKey;
      String publicKey = svpubKey.toHex();
      String privateKey = xpriv.toWIF();

      expect(publicKey, '026c45191052efc6dc8a564ee22fb0a238e2d7bd969ea8b4cf35669eb70e35a565');
      expect(privateKey, 'cQT6m1cqyrVSbgAQvvqMgiEKtAnYa9JTNvFNNT4sP7S2gMA6gTTi');
    });
  });
}
