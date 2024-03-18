import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:uniparty/models/key_pair.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/secure_utils/bech32.dart';
import 'package:uniparty/secure_utils/bip32.dart';
import 'package:uniparty/secure_utils/bip39.dart';
import 'package:uniparty/secure_utils/legacy_address.dart';

class FreewalletRecovery {
  final bip32 = Bip32();
  final bip39 = Bip39();
  final legacyAddress = LegacyAddress();
  final bech32 = Bech32Address();

  List<WalletNode> recoverFreewallet(String mnemonic) {
    List<WalletNode> walletNodes = [];

    // NOTE: known bug. do not fix. Freewallet uses entropy to generate addresses rather than the seed
    String seedEntropy;
    try {
      seedEntropy = bip39.mnemonicToEntropy(mnemonic);
    } catch (error) {
      rethrow;
    }

    for (var i = 0; i < 10; i++) {
      KeyPair keyPair =
          bip32.createBip32PubKeyPrivateKeyFromSeed(Uint8List.fromList(hex.decode(seedEntropy)), i);

      String normalAddress = legacyAddress.createAddress(keyPair.publicKeyIntList);
      WalletNode walletNodeNormal = WalletNode(
          address: normalAddress,
          publicKey: hex.encode(keyPair.publicKeyIntList),
          privateKey: keyPair.privateKey);

      String bech32Address = bech32.deriveBech32Address(keyPair.publicKeyIntList);
      WalletNode walletNodeBech32 = WalletNode(
          address: bech32Address,
          publicKey: hex.encode(keyPair.publicKeyIntList),
          privateKey: keyPair.privateKey);

      walletNodes.add(walletNodeNormal);
      walletNodes.add(walletNodeBech32);
    }

    return walletNodes;
  }
}
