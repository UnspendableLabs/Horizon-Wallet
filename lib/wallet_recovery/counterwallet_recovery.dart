import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:counterparty_wallet/secure_utils/bech32.dart';
import 'package:counterparty_wallet/secure_utils/bip32.dart';
import 'package:counterparty_wallet/secure_utils/legacy_address.dart';
import 'package:counterparty_wallet/secure_utils/mnemonic_js.dart';
import 'package:counterparty_wallet/secure_utils/models/key_pair.dart';
import 'package:counterparty_wallet/secure_utils/models/wallet_info.dart';

class CounterwalletRecovery {
  final mnemonicJs = MnemonicJs();
  final bip32 = Bip32();
  final legacyAddress = LegacyAddress();
  final bech32 = Bech32Address();

  WalletInfo recoverCounterwallet(String words) {
    String seedHex = mnemonicJs.wordsToSeed(words);
    KeyPair keyPair =
        bip32.createBip32PubKeyPrivateKeyFromSeed(Uint8List.fromList(hex.decode(seedHex)), 0);
    String normalAddress = legacyAddress.createAddress(keyPair.publicKeyIntList);
    WalletInfo wallet = WalletInfo(
        address: normalAddress,
        publicKey: hex.encode(keyPair.publicKeyIntList),
        privateKey: keyPair.privateKey);
    return wallet;
  }

  List<WalletInfo> recoverCounterwalletFromFreewallet(String words) {
    List<WalletInfo> wallets = [];
    String seedHex = mnemonicJs.wordsToSeed(words);
    for (var i = 0; i < 10; i++) {
      KeyPair keyPair =
          bip32.createBip32PubKeyPrivateKeyFromSeed(Uint8List.fromList(hex.decode(seedHex)), i);

      String normalAddress = legacyAddress.createAddress(keyPair.publicKeyIntList);
      WalletInfo walletInfoNormal = WalletInfo(
          address: normalAddress,
          publicKey: hex.encode(keyPair.publicKeyIntList),
          privateKey: keyPair.privateKey);

      String bech32Address = bech32.deriveBech32Address(keyPair.publicKeyIntList);
      WalletInfo walletInfoBech32 = WalletInfo(
          address: bech32Address,
          publicKey: hex.encode(keyPair.publicKeyIntList),
          privateKey: keyPair.privateKey);

      wallets.add(walletInfoNormal);
      wallets.add(walletInfoBech32);
    }

    return wallets;
  }
}
