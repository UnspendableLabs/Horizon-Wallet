import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/models/wallet_types.dart';
import 'package:uniparty/utils/secure_storage.dart';
import 'package:uniparty/wallet_recovery/bip32_recovery.dart';
import 'package:uniparty/wallet_recovery/bip44_recovery.dart';

Future<List<WalletNode>> recoverWallet(BuildContext context) async {
  final secureStorage = SecureStorage();
  print('BEFORE READ');

  String? seedHex = await secureStorage.readSecureData('seed_hex');
  String? walletType = await secureStorage.readSecureData('wallet_type');

  print('READ SEED: $seedHex');
  List<WalletNode> walletNodes = [];

  if (seedHex == null || walletType == null) {
    // ignore: use_build_context_synchronously
    GoRouter.of(context).go('/start');
    return walletNodes;
  }

  switch (walletType) {
    case bip44:
      walletNodes = recoverBip44Wallet(seedHex);
      break;
    case bip32:
      walletNodes = recoverBip32Wallet(seedHex);
      break;
    default:
      throw UnsupportedError('wallet type $walletType not supported');
  }

  return walletNodes;
}
