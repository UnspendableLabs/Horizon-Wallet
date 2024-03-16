import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:counterparty_wallet/secure_utils/bech32.dart';
import 'package:counterparty_wallet/secure_utils/bip32.dart';
import 'package:counterparty_wallet/secure_utils/bip39.dart';
import 'package:counterparty_wallet/secure_utils/legacy_address.dart';
import 'package:counterparty_wallet/secure_utils/models/key_pair.dart';
import 'package:counterparty_wallet/secure_utils/models/wallet_info.dart';

class FreewalletRecovery {
  final bip32 = Bip32();
  final bip39 = Bip39();
  final legacyAddress = LegacyAddress();
  final bech32 = Bech32Address();

  List<WalletInfo> recoverFreewallet(String mnemonic) {
    List<WalletInfo> wallets = [];
    String seed = bip39.mnemonicToEntropy(mnemonic);

    for (var i = 0; i < 10; i++) {
      KeyPair keyPair =
          bip32.createBip32PubKeyPrivateKeyFromSeed(Uint8List.fromList(hex.decode(seed)), i);

      String normalAddress = legacyAddress.createAddress(keyPair.publicKey);
      WalletInfo walletInfoNormal = WalletInfo(
          address: normalAddress,
          publicKey: hex.encode(keyPair.publicKey),
          privateKey: keyPair.privateKey);

      String bech32Address = bech32.deriveBech32Address(keyPair.publicKey);
      WalletInfo walletInfoBech32 = WalletInfo(
          address: bech32Address,
          publicKey: hex.encode(keyPair.publicKey),
          privateKey: keyPair.privateKey);

      wallets.add(walletInfoNormal);
      wallets.add(walletInfoBech32);
    }

    return wallets;
  }
}
