import 'dart:typed_data';

import 'package:counterparty_wallet/secure_utils/bip39.dart';
import 'package:counterparty_wallet/secure_utils/hd_wallet_util.dart';
import 'package:test/test.dart';

void main() {
  group('Test HDWalletUtil', () {
    var hdWalletUtil = HDWalletUtil();
    test('createBip44AddressFromSeed xcp cointype', () {
      String mnemonic =
          'trend pond enable empower govern example melody bless alone grow stone genre';
      Uint8List seed = Bip39().mnemonicToSeed(mnemonic);

      expect(hdWalletUtil.createBip44AddressFromSeed(seed, 9),
          '1Ew8dgq2Aqubu1bhiwJWc6gb8Z5qqmS6pS');
    });

    test('createBip44AddressFromSeed btc cointype', () {
      String mnemonic =
          'trend pond enable empower govern example melody bless alone grow stone genre';
      Uint8List seed = Bip39().mnemonicToSeed(mnemonic);

      expect(hdWalletUtil.createBip44AddressFromSeed(seed, 9),
          '1Ew8dgq2Aqubu1bhiwJWc6gb8Z5qqmS6pS');
    });
  });
}
