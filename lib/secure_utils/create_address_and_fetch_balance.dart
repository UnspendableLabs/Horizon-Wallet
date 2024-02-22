import 'dart:typed_data';

import 'package:counterparty_wallet/counterparty_api/counterparty_api.dart';
import 'package:counterparty_wallet/secure_utils/bip39.dart';
import 'package:counterparty_wallet/secure_utils/hd_wallet_util.dart';
import 'package:counterparty_wallet/secure_utils/secure_storage.dart';

// TODO: return proper classes
Future<Object> createAddressAndFetchBalance(mnemonic) async {
  var bip39 = Bip39();
  var counterpartyApi = CounterpartyApi();
  var secureStorage = SecureStorage();
  var hdWalletUtil = HDWalletUtil();

  // generate seed hex from mnemonic
  String seedHex = bip39.mnemonicToSeedHex(mnemonic);

  // TODO OPEN QUESTION: SEED HEX vs Uint8List SEED?
  // write hex to storage
  await secureStorage.writeSecureData(
    'seed_hex',
    seedHex,
  );

  // mnemonic to seed
  Uint8List seed = bip39.mnemonicToSeed(mnemonic);

  final address = hdWalletUtil.createBip44AddressFromSeed(seed);

  Object balances = await counterpartyApi.fetchBalance(address);
  return balances;
}
