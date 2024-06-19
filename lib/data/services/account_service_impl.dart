import 'dart:js_interop';

import 'package:convert/convert.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/account_service_return.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/services/account_service.dart';
import 'package:horizon/js/bech32.dart' as bech32;
import 'package:horizon/js/bip32.dart' as bip32;
import 'package:horizon/js/bip39.dart' as bip39;
import 'package:horizon/js/buffer.dart';
import 'package:horizon/js/ecpair.dart' as ecpair; // TODO move to data;
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;

class AccountServiceImpl extends AccountService {
  final bip32.BIP32Factory _bip32 = bip32.BIP32Factory(tinysecp256k1js.ecc);

  @override
  Future<AccountServiceReturn> deriveAccount(String mnemonic, String purpose, int coinType, int accountIndex) async {
    JSUint8Array seed = await bip39.mnemonicToSeed(mnemonic).toDart;

    final network = ecpair.bitcoin;

    bip32.BIP32Interface root = _bip32.fromSeed(seed as Buffer, network);
    final String basePath = 'm/$purpose\'/$coinType\'/$accountIndex\'';
    bip32.BIP32Interface accountNode = root.derivePath(basePath);

    final xpub = accountNode.neutered().toBase58(); // TODO! change prefix

    int change = 0;
    int index = 0;
    bip32.BIP32Interface child = accountNode.derive(change).derive(index);

    List<int> identifier = child.identifier.toDart;
    List<int> words =
        bech32.toWords(identifier.map((el) => el.toJS).toList().toJS).toDart.map((el) => el.toDartInt).toList();
    words.insert(0, 0);
    String address = bech32.encode(ecpair.bitcoin.bech32, words.map((el) => el.toJS).toList().toJS);

    final addressEntity = Address(
        address: address,
        publicKey: hex.encode(child.publicKey.toDart),
        privateKeyWif: child.toWIF(),
        accountUuid: uuid.v4(),
        addressIndex: index);

    return AccountServiceReturn(xPub: xpub, address: addressEntity);
  }
}
