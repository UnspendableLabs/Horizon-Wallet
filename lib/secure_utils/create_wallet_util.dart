import 'dart:typed_data';

import 'package:counterparty_wallet/secure_utils/bip39.dart';
import 'package:counterparty_wallet/secure_utils/secure_storage.dart';
import 'package:hd_wallet_kit/hd_wallet_kit.dart';

Future<void> createAddress(mnemonic) async {
  var bip39 = Bip39();
  // generate seed hex from mnemonic
  String seedHex = bip39.mnemonicToSeedHex(mnemonic);

  // TODO OPEN QUESTION: SEED HEX vs Uint8List SEED?
  // write hex to storage
  await SecureStorage().writeSecureData(
    'seed_hex',
    seedHex,
  );

  // mnemonic to seed
  Uint8List seed = bip39.mnemonicToSeed(mnemonic);

  // create hd wallet from seed
  final hdWallet = HDWallet.fromSeed(seed: seed);

// Derive a child key from the HD key using the defined path
  final key = hdWallet.deriveKeyByPath(path: 'm/0\'/0/'); // TODO: use bip44

  // TODO: which are relevant?
  final accountExtendedPubKey = key.serializePublic(HDExtendedKeyVersion.xpub);
  final accountExtendedPrivKey =
      key.serializePrivate(HDExtendedKeyVersion.xprv);
  final address = key.encodeAddress();
}
