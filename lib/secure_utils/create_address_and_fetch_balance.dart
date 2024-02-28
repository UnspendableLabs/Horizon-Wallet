import 'package:counterparty_wallet/counterparty_api/counterparty_api.dart';
import 'package:counterparty_wallet/secure_utils/bip39.dart';
import 'package:counterparty_wallet/secure_utils/hd_wallet_util.dart';
import 'package:counterparty_wallet/secure_utils/models/base_path.dart';
import 'package:counterparty_wallet/secure_utils/secure_storage.dart';

// TODO: return proper classes
Future<Object> createAddressAndFetchBalance(mnemonic) async {
  var bip39 = Bip39();
  var counterpartyApi = CounterpartyApi();
  var secureStorage = SecureStorage();
  var hdWalletUtil = HDWalletUtil();

  // generate seed hex from mnemonic
  String seedHex = bip39.mnemonicToSeedHex(mnemonic);

  // write hex to storage
  await secureStorage.writeSecureData(
    'seed_hex',
    seedHex,
  );

  BasePath path = BasePath(coinType: 0, account: 0, change: 0, index: 0);

  final address = hdWalletUtil.createBip44AddressFromSeed(seedHex, path);

  Object balances = await counterpartyApi.fetchBalance(address);
  return balances;
}
