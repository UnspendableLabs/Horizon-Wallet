import 'package:counterparty_wallet/secure_utils/bip39.dart';
import 'package:counterparty_wallet/secure_utils/bip44.dart';
import 'package:counterparty_wallet/secure_utils/models/base_path.dart';
import 'package:counterparty_wallet/secure_utils/models/wallet_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/test.dart';

void main() async {
  await dotenv.load();

  // https://iancoleman.io/bip39/
  group('Test Bip44 mainnet', () {
    var bip44Util = Bip44();

    test('createBip44AddressFromSeed btc cointype', () {
      String mnemonic =
          'trend pond enable empower govern example melody bless alone grow stone genre';
      String seedHex = Bip39().mnemonicToSeedHex(mnemonic);

      expect(seedHex,
          '82fe40a0c31ac27e19bc302c5ed322158cfdbeb78ed3577e89ecf73abb838670fe4a1d17d3914ea4df8de75c6e98fa87603f6578dffbb039b5680504f84b2a4b');

      // path for btc
      BasePath path = BasePath(coinType: 0, account: 0, change: 0, index: 0);

      WalletNode address = Bip44().createBip44AddressFromSeed(seedHex, path);
      expect(address.address, '1B6yQRDXADzdyDxyK74cFY8vzV341o2fcg');
      expect(
          address.publicKey, '02ff5e001258801f2a32ceb4702a4e0b2c8f68d2a4afc85a01d17a568b720ef12a');
      expect(address.privateKey, 'KxFniLGmDo8VMPFHXgB1tokQArFgXQtJKkUATWWqTMYL2TAg9EDt');
    });

    test('createBip44AddressFromSeed btc cointype index 1', () {
      String mnemonic =
          'stumble prison flip merge negative ostrich myself winter naive try arctic olympic';
      String seedHex = Bip39().mnemonicToSeedHex(mnemonic);

      expect(seedHex,
          '941807f8e36f39910ff6eb2c160de428b78a46609374d7aa4673e5a010219b39c310591b0e0e8876bb6cef5c982868b34c6f0cee4d188d31afe5e7ee9f315fbb');

      // path for btc
      BasePath path = BasePath(coinType: 0, account: 0, change: 0, index: 1);

      WalletNode address = bip44Util.createBip44AddressFromSeed(seedHex, path);

      expect(address.address, '1M3VPoE7wS3HAF3CofoHdznKE3MGqKXafp');
      expect(
          address.publicKey, '03d9c25b411595bfca66ec766e79e31c8e47364d93843e72f112882b0d400c5fbc');
      expect(address.privateKey, 'L3sw5uxfRfG7Gg5SYf3FJMnzYoibDi8gQDAPJp7zFSsCvx6CuowK');
    });

    test('createBip44AddressFromSeed btc cointype index 38', () {
      String mnemonic =
          'thunder member interest display shock unable clarify fiber insect lumber battle off';
      String seedHex = Bip39().mnemonicToSeedHex(mnemonic);

      expect(seedHex,
          '23926ae31d75602cbdac79c4d0e39f4b37d763a6ccb3596b6b7de6d2328536695682ab224d2074d0a23dd4f258ba32ab96b1a2a2dfe00a1e8bd4f1704bceb460');

      // path for btc
      BasePath path = BasePath(coinType: 0, account: 0, change: 0, index: 38);

      WalletNode address = bip44Util.createBip44AddressFromSeed(seedHex, path);

      expect(address.address, '1M4maEYB3kpw8sCAQz1Xo7e3DcPNa41zGT');
      expect(
          address.publicKey, '028b58030c35af75abc486ebbe34ddcb45f032b02d676dc2818b243ebeca4097bf');
      expect(address.privateKey, 'L5VkaGBSSTWau7CSzZCnggNLMKt8pG8hKApNo6m6VEDqMmCsBR8a');
    });

    test('createBip44AddressFromSeed btc cointype index 45', () {
      String mnemonic =
          'crime speak truly valid movie describe blame essay crack skirt december obey';
      String seedHex = Bip39().mnemonicToSeedHex(mnemonic);

      expect(seedHex,
          'adb15ee789225d60da76a716c9dc9e02c12e7a248e07a26628a94e600b613a74c8a538c0ff4114e570650a96db386e20c158eda2e5405042906f9cad858e80c8');

      // path for btc
      BasePath path = BasePath(coinType: 0, account: 0, change: 0, index: 45);

      WalletNode address = bip44Util.createBip44AddressFromSeed(seedHex, path);

      expect(address.address, '1ET7nur1J3qpxeMJb1TVgSjRmtKbQAwdxj');
      expect(
          address.publicKey, '03d36e92f7ebe73c61bb0f38a08348431814969d08ee6e2891420cff06a770f57b');
      expect(address.privateKey, 'Kz115Kxd3jKioF1DhuBpj5hC8kBKqPXq148Bn7Rx7SVaFWMgtjUS');
    });

    test('createBip44AddressFromSeed btc cointype index 5', () {
      String mnemonic = 'sorry hub gadget wasp repeat wave disagree knock prosper rose gas dinner';
      String seedHex = Bip39().mnemonicToSeedHex(mnemonic);

      expect(seedHex,
          'b8e207c740d1fd56cdd1c03ed5a0facf46e6a06e3720a8f6e9a9eb874c7e177f47fa6174553849d71fec2037da44bd046316cd5a3528e57a165bd02913290f11');

      // path for btc
      BasePath path = BasePath(coinType: 0, account: 0, change: 0, index: 5);
      WalletNode address = bip44Util.createBip44AddressFromSeed(seedHex, path);

      expect(address.address, '14f8hGPiSDFZuaM7yJK1SgHpxCqHhsQ7W4');
      expect(
          address.publicKey, '026bfb97d478923ef5d289b6bfb0e36ddfcf085b6852037d153752cf56c8712259');
      expect(address.privateKey, 'L3nKbF9rE4rb9G6ZM1iABZxxHZPXh37yREWwTS9E9QC2ADTnQDjV');
    });
  });
}
