import 'dart:typed_data';

import 'package:counterparty_wallet/secure_utils/bip39.dart';
import 'package:counterparty_wallet/secure_utils/hd_wallet_util.dart';
import 'package:counterparty_wallet/secure_utils/models/address.dart';
import 'package:test/test.dart';

void main() {
  group('Test HDWalletUtil', () {
    var hdWalletUtil = HDWalletUtil();
    test('createBip44AddressFromSeed xcp cointype', () {
      String mnemonic =
          'trend pond enable empower govern example melody bless alone grow stone genre';
      Uint8List seed = Bip39().mnemonicToSeed(mnemonic);

      Address address = hdWalletUtil.createBip44AddressFromSeed(seed, 0);
      // addresses are passing here, priv and pub keys are not
      // addresses generated here https://iancoleman.io/bip39/
      expect(address.address, '1B6yQRDXADzdyDxyK74cFY8vzV341o2fcg');
      expect(address.accountExtendedPrivKey,
          'xprv9z38PSwQUVsRNkXMXTcnBkzp5txa9wdt7r6VtU21RMrBkVjYPugXp3MzSbDuQhqHxd6XtzpbNPcoiPWtcrXsFXXSDZtbsygPJgekr4rQuQP');
      expect(address.accountExtendedPubKey,
          'xpub6D2UnxUJJsRibEbpdV9nYtwYdvo4ZQMjV526grRcyhPAdJ4gwSznMqgUHu7dCHtc3UH39U9EZkJTv6SwAoC4TL2rRqd8G5cVKTvwGPAAvpr');
    });

    test('createBip44AddressFromSeed btc cointype', () {
      String mnemonic =
          'stumble prison flip merge negative ostrich myself winter naive try arctic olympic';
      Uint8List seed = Bip39().mnemonicToSeed(mnemonic);
      Address address = hdWalletUtil.createBip44AddressFromSeed(seed, 0);

      // this passes
      expect(address.address, '1HCZMZcyUN4i36d4WjhP7d5FLbiyXHu31d');
    });

    test('createBip44AddressFromSeed btc cointype', () {
      String mnemonic =
          'thunder member interest display shock unable clarify fiber insect lumber battle off';
      Uint8List seed = Bip39().mnemonicToSeed(mnemonic);
      Address address = hdWalletUtil.createBip44AddressFromSeed(seed, 0);

      // this passes
      expect(address.address, '1EwdCtTQBqPFAYUjD5Bkq6qHgrzsvw6ETh');
    });

    test('createBip44AddressFromSeed btc cointype', () {
      String mnemonic =
          'access rare leader fire olive gorilla security elite such mosquito awkward spy';
      Uint8List seed = Bip39().mnemonicToSeed(mnemonic);
      Address address = hdWalletUtil.createBip44AddressFromSeed(seed, 0);

      // this passes
      expect(address.address, '1LHCZ6jVz7appvxa7Fa1cYxh8X8XEZYeSX');
    });

    test('createBip44AddressFromSeed btc cointype', () {
      String mnemonic =
          'sorry hub gadget wasp repeat wave disagree knock prosper rose gas dinner';
      Uint8List seed = Bip39().mnemonicToSeed(mnemonic);
      Address address = hdWalletUtil.createBip44AddressFromSeed(seed, 0);

      // this passes
      expect(address.address, '1Q9onSWP4TVvHYwrRmiKrW1JDwPRLrD3hE');
    });
  });
}
