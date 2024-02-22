import 'dart:typed_data';

import 'package:counterparty_wallet/counterparty_api/counterparty_api.dart';
import 'package:counterparty_wallet/secure_utils/bip39.dart';
import 'package:counterparty_wallet/secure_utils/secure_storage.dart';
import 'package:hd_wallet_kit/hd_wallet_kit.dart';

// TODO: return proper classes
Future<Object> createAddressAndFetchBalance(mnemonic) async {
  // TODO: split out + cleanup method
  var bip39 = Bip39();
  var counterpartyApi = CounterpartyApi();
  // generate seed hex from mnemonic
  String seedHex = bip39.mnemonicToSeedHex(mnemonic);

  print('storing seed hex....');
  // TODO OPEN QUESTION: SEED HEX vs Uint8List SEED?
  // write hex to storage
  await SecureStorage().writeSecureData(
    'seed_hex',
    seedHex,
  );

  print('generating seed...');
  // mnemonic to seed
  Uint8List seed = bip39.mnemonicToSeed(mnemonic);

  print('making wallet....');
  // create hd wallet from seed
  final hdWallet = HDWallet.fromSeed(seed: seed);

  print('deriving key...');
// Derive a child key from the HD key using the defined path
  final key = hdWallet.deriveKey(
      purpose: Purpose.BIP44, coinType: 9, account: 0, change: 0, index: 0);
//hdWallet.deriveKeyByPath(path: 'm/0\'/0/')
  print('key generated...');
  // TODO: which are relevant?
  final accountExtendedPubKey = key.serializePublic(HDExtendedKeyVersion.xpub);
  final accountExtendedPrivKey =
      key.serializePrivate(HDExtendedKeyVersion.xprv);
  final address = key.encodeAddress();

  Object balances = await counterpartyApi.fetchBalance(address);
  return balances;
}
