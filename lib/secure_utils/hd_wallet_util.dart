import 'dart:typed_data';

import 'package:counterparty_wallet/secure_utils/models/address.dart';
import 'package:counterparty_wallet/secure_utils/models/base_path.dart';
import 'package:hd_wallet_kit/hd_wallet_kit.dart';
import 'package:hd_wallet_kit/utils.dart';

class HDWalletUtil {
  Address createBip44AddressFromSeed(Uint8List seed, BasePath path) {
    // create hd wallet from seed
    final hdWallet = HDWallet.fromSeed(seed: seed);

    // Derive a child key from the HD key using the defined path
    final key = hdWallet.deriveKey(
        purpose: Purpose.BIP44,
        coinType: path.coinType,
        account: path.account,
        change: path.change,
        index: path.index);

    // This also produces the same this key.pubKey == publicKeyObject.publicKey
    /*
    final publicKeyObject = hdWallet.getPublicKey(
        purpose: Purpose.BIP44,
        coinType: 0,
        account: 0,
        change: 0,
        index: 0);
    */

    final address = key.encodeAddress();

    return Address(
        address: address,
        publicKey: uint8ListToHexString(key.pubKey),
        path: key.toString());
  }
}
