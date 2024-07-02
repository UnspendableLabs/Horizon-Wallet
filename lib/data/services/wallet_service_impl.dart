import 'dart:js_interop';

import 'package:convert/convert.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/seed.dart';
import 'package:horizon/domain/entities/wallet.dart' as entity;
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/js/bip32.dart' as bip32;
import 'package:horizon/js/bip39.dart' as bip39;
import 'package:horizon/js/buffer.dart';
import 'package:horizon/js/ecpair.dart' as ecpair; // TODO move to data;
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;

class WalletServiceImpl implements WalletService {
  EncryptionService encryptionService;

  WalletServiceImpl(this.encryptionService);

  final bip32.BIP32Factory _bip32 = bip32.BIP32Factory(tinysecp256k1js.ecc);

  Future<entity.Wallet> deriveRoot(String mnemonic, String password) async {
    final network = _getNetwork();

    JSUint8Array seed = await bip39.mnemonicToSeed(mnemonic).toDart;

    bip32.BIP32Interface root = _bip32.fromSeed(seed as Buffer, network);

    String privKey = hex.encode(root.privateKey!.toDart);

    String storedKey = await encryptionService.encrypt(privKey, password);

    return entity.Wallet(
        uuid: uuid.v4(), name: 'Wallet 1', encryptedPrivKey: storedKey, chainCodeHex: hex.encode(root.chainCode.toDart));
  }

  Future<entity.Wallet> deriveRootFreewallet(String mnemonic, String password) async {
    Seed seed = Seed.fromHex(bip39.mnemonicToEntropy(mnemonic));

    Buffer buffer = Buffer.from(seed.bytes.toJS);

    final network = _getNetwork();

    bip32.BIP32Interface root = _bip32.fromSeed(buffer, network);

    String privKey = hex.encode(root.privateKey!.toDart);

    String storedKey = await encryptionService.encrypt(privKey, password);

    return entity.Wallet(
        uuid: uuid.v4(), name: 'Wallet 1', encryptedPrivKey: storedKey, chainCodeHex: hex.encode(root.chainCode.toDart));
  }

  _getNetwork() {
    bool isTestnet = dotenv.get('TEST') == 'true';
    return isTestnet ? ecpair.testnet : ecpair.bitcoin;
  }
}
