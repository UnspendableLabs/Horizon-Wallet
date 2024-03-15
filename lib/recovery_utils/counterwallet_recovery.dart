import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:counterparty_wallet/secure_utils/bip32.dart';
import 'package:counterparty_wallet/secure_utils/legacy_address.dart';
import 'package:counterparty_wallet/secure_utils/mnemonic_js.dart';
import 'package:counterparty_wallet/secure_utils/models/key_pair.dart';
import 'package:counterparty_wallet/secure_utils/models/wallet_info.dart';

class CounterwalletRecovery {
  final mnemonicJs = MnemonicJs();
  final bip32 = Bip32();
  final legacyAddress = LegacyAddress();

  WalletInfo recoverCounterwallet(String words) {
    String seedHex = mnemonicJs.wordsToSeed(words);
    KeyPair keyPair =
        bip32.createBip32PubKeyPrivateKeyFromSeed(Uint8List.fromList(hex.decode(seedHex)), 0);
    String normalAddress = legacyAddress.createAddress(keyPair.publicKey);
    WalletInfo wallet = WalletInfo(
        address: normalAddress,
        publicKey: hex.encode(keyPair.publicKey),
        privateKey: keyPair.privateKey);
    return wallet;
  }
}
