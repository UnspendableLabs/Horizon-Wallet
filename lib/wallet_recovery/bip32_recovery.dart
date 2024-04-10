import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:uniparty/bitcoin_wallet_utils/bech32.dart';
import 'package:uniparty/bitcoin_wallet_utils/bip32.dart';
import 'package:uniparty/bitcoin_wallet_utils/legacy_address.dart';
import 'package:uniparty/models/key_pair.dart';
import 'package:uniparty/models/wallet_node.dart';

List<WalletNode> recoverBip32Wallet(String seedHex, String network) {
  final bip32 = Bip32();
  final legacyAddress = LegacyAddress();
  final bech32 = Bech32Address();

  List<WalletNode> walletNodes = [];

  for (var i = 0; i < 10; i++) {
    KeyPair keyPair = bip32.createBip32PubKeyPrivateKeyFromSeed(
        Uint8List.fromList(hex.decode(seedHex)), network, i);

    String normalAddress = legacyAddress.createAddress(keyPair.publicKeyIntList, network);
    WalletNode walletNodeNormal = WalletNode(
        address: normalAddress,
        publicKey: hex.encode(keyPair.publicKeyIntList),
        privateKey: keyPair.privateKey,
        index: i);

    String bech32Address = bech32.deriveBech32Address(keyPair.publicKeyIntList, network);
    WalletNode walletNodeBech32 = WalletNode(
        address: bech32Address,
        publicKey: hex.encode(keyPair.publicKeyIntList),
        privateKey: keyPair.privateKey,
        index: i);

    walletNodes.add(walletNodeNormal);
    walletNodes.add(walletNodeBech32);
  }

  return walletNodes;
}
