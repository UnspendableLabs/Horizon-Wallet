import 'dart:typed_data';

import 'package:hd_wallet_kit/hd_wallet_kit.dart';

class HDWalletUtil {
  String createBip44AddressFromSeed(Uint8List seed) {
    // create hd wallet from seed
    final hdWallet = HDWallet.fromSeed(seed: seed);

    // Derive a child key from the HD key using the defined path
    final key = hdWallet.deriveKey(
        purpose: Purpose.BIP44, coinType: 9, account: 0, change: 0, index: 0);

    // TODO: which are relevant?
    // final accountExtendedPubKey =
    //     key.serializePublic(HDExtendedKeyVersion.xpub);
    // final accountExtendedPrivKey =
    //     key.serializePrivate(HDExtendedKeyVersion.xprv);

    final address = key.encodeAddress();
    return address;
  }
}
