import 'dart:js_interop';

import 'package:convert/convert.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/wallet.dart' as entity;
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/js/bip32.dart' as bip32;
import 'package:horizon/js/ecpair.dart' as ecpair; // TODO move to data;
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;
import "encryption_service_impl.dart";

class RegTestUtils {
  EncryptionService encryptionService = EncryptionServiceImpl();

  final bip32.BIP32Factory _bip32 = bip32.BIP32Factory(tinysecp256k1js.ecc);

  Future<entity.Wallet> fromBase58(String privateKey, String password) async {
    bip32.BIP32Interface root = _bip32.fromBase58(privateKey, _getNetwork());

    String privKey = hex.encode(root.privateKey!.toDart);

    String encryptedPrivKey =
        await encryptionService.encrypt(privKey, password);

    return entity.Wallet(
        uuid: uuid.v4(),
        name: 'Regtest #0',
        encryptedPrivKey: encryptedPrivKey,
        publicKey: root.neutered().toBase58(),
        chainCodeHex: hex.encode(root.chainCode.toDart));
  }

  _getNetwork() {
    // bool isTestnet = dotenv.get('TEST') == 'true';
    bool isTestnet =
        const String.fromEnvironment('TEST', defaultValue: 'true') == 'true';
    return isTestnet ? ecpair.testnet : ecpair.bitcoin;
  }
}
