import 'package:flutter/material.dart';
import 'package:uniparty/models/constants.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/wallet_recovery/bip32_recovery.dart';
import 'package:uniparty/wallet_recovery/bip44_recovery.dart';

List<WalletNode> recoverWallet(BuildContext context, String network, String? seedHex, String? walletType) {
  List<WalletNode> walletNodes = [];

  if (seedHex == null || walletType == null) {
    // ignore: use_build_context_synchronously

    return walletNodes;
  }

  switch (walletType) {
    case bip44:
      walletNodes = recoverBip44Wallet(seedHex, network);
      break;
    case bip32:
      walletNodes = recoverBip32Wallet(seedHex, network);
      break;
    default:
      throw UnsupportedError('wallet type $walletType not supported');
  }

  return walletNodes;
}
