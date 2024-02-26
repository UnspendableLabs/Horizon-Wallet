import 'dart:typed_data';

import 'package:counterparty_wallet/secure_utils/bip39.dart';
import 'package:counterparty_wallet/secure_utils/hd_wallet_util.dart';
import 'package:counterparty_wallet/secure_utils/models/address.dart';
import 'package:counterparty_wallet/secure_utils/models/base_path.dart';
import 'package:hd_wallet_kit/utils.dart';
import 'package:test/test.dart';

void main() {
  group('Test HDWalletUtil', () {
    var hdWalletUtil = HDWalletUtil();

    // test pubkeys and addresses generated here https://iancoleman.io/bip39/
    test('createBip44AddressFromSeed btc cointype', () {
      String mnemonic =
          'trend pond enable empower govern example melody bless alone grow stone genre';
      Uint8List seed = Bip39().mnemonicToSeed(mnemonic);

      expect(uint8ListToHexString(seed),
          '82fe40a0c31ac27e19bc302c5ed322158cfdbeb78ed3577e89ecf73abb838670fe4a1d17d3914ea4df8de75c6e98fa87603f6578dffbb039b5680504f84b2a4b');

      // path for btc
      BasePath path = BasePath(coinType: 0, account: 0, change: 0, index: 0);

      Address address = hdWalletUtil.createBip44AddressFromSeed(seed, path);

      expect(address.path, 'm/44\'/0\'/0\'/0/0');
      expect(address.address, '1B6yQRDXADzdyDxyK74cFY8vzV341o2fcg');
      expect(address.publicKey,
          '02ff5e001258801f2a32ceb4702a4e0b2c8f68d2a4afc85a01d17a568b720ef12a');
    });

    test('createBip44AddressFromSeed btc cointype index 1', () {
      String mnemonic =
          'stumble prison flip merge negative ostrich myself winter naive try arctic olympic';
      Uint8List seed = Bip39().mnemonicToSeed(mnemonic);

      expect(uint8ListToHexString(seed),
          '941807f8e36f39910ff6eb2c160de428b78a46609374d7aa4673e5a010219b39c310591b0e0e8876bb6cef5c982868b34c6f0cee4d188d31afe5e7ee9f315fbb');

      // path for btc
      BasePath path = BasePath(coinType: 0, account: 0, change: 0, index: 1);

      Address address = hdWalletUtil.createBip44AddressFromSeed(seed, path);

      expect(address.path, 'm/44\'/0\'/0\'/0/1');
      expect(address.address, '1M3VPoE7wS3HAF3CofoHdznKE3MGqKXafp');
      expect(address.publicKey,
          '03d9c25b411595bfca66ec766e79e31c8e47364d93843e72f112882b0d400c5fbc');
    });

    test('createBip44AddressFromSeed btc cointype index 38', () {
      String mnemonic =
          'thunder member interest display shock unable clarify fiber insect lumber battle off';
      Uint8List seed = Bip39().mnemonicToSeed(mnemonic);

      expect(uint8ListToHexString(seed),
          '23926ae31d75602cbdac79c4d0e39f4b37d763a6ccb3596b6b7de6d2328536695682ab224d2074d0a23dd4f258ba32ab96b1a2a2dfe00a1e8bd4f1704bceb460');

      // path for btc
      BasePath path = BasePath(coinType: 0, account: 0, change: 0, index: 38);

      Address address = hdWalletUtil.createBip44AddressFromSeed(seed, path);

      expect(address.path, 'm/44\'/0\'/0\'/0/38');
      expect(address.address, '1M4maEYB3kpw8sCAQz1Xo7e3DcPNa41zGT');
      expect(address.publicKey,
          '028b58030c35af75abc486ebbe34ddcb45f032b02d676dc2818b243ebeca4097bf');
    });

    // test('createBip44AddressFromSeed bch cointype', () {
    //   String mnemonic =
    //       'crime speak truly valid movie describe blame essay crack skirt december obey';
    //   Uint8List seed = Bip39().mnemonicToSeed(mnemonic);

    //   expect(uint8ListToHexString(seed),
    //       'adb15ee789225d60da76a716c9dc9e02c12e7a248e07a26628a94e600b613a74c8a538c0ff4114e570650a96db386e20c158eda2e5405042906f9cad858e80c8');

    //   // path for bch
    //   BasePath path = BasePath(coinType: 145, account: 0, change: 0, index: 0);

    //   Address address = hdWalletUtil.createBip44AddressFromSeed(seed, path);

    //   expect(address.path, 'm/44\'/145\'/0\'/0/0');
    //   expect(address.address, '1ANnmzAsvyBZrfg5jxHis2U1hmeaXxLcGc');
    //   expect(address.publicKey,
    //       '03359ae6b6f0ef328a8e47488f2762afd3632b3bc8652a669024eabeb5d0c8891c');
    // });

    test('createBip44AddressFromSeed ltc cointype index 5', () {
      String mnemonic =
          'sorry hub gadget wasp repeat wave disagree knock prosper rose gas dinner';
      Uint8List seed = Bip39().mnemonicToSeed(mnemonic);

      expect(uint8ListToHexString(seed),
          'b8e207c740d1fd56cdd1c03ed5a0facf46e6a06e3720a8f6e9a9eb874c7e177f47fa6174553849d71fec2037da44bd046316cd5a3528e57a165bd02913290f11');

      // path for ltc
      BasePath path = BasePath(coinType: 2, account: 0, change: 0, index: 5);

      Address address = hdWalletUtil.createBip44AddressFromSeed(seed, path);

      expect(address.path, 'm/44\'/2\'/0\'/0/5');
      // expect(address.address, 'LNvfmTRsJPXV5BTegezm2Dy8Q5tPwsWXPd');
      expect(address.publicKey,
          '02aa679495071bf66661d3f2c848a6f48896a384ee82ccb1b77ef84a14825ca87e');
    });
  });
}
