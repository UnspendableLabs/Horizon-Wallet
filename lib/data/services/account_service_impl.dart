import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/entities/account.dart' as a;
import 'package:horizon/domain/entities/seed.dart';
import 'package:horizon/js/bip32.dart' as bip32;
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;
import 'package:horizon/js/bip39.dart' as bip39;
import 'package:horizon/js/ecpair.dart' as ecpair; // TODO move to data;
import 'package:horizon/js/buffer.dart';
import 'dart:js_interop';

class AccountServiceImpl implements AccountService {
  EncryptionService encryptionService;

  AccountServiceImpl(this.encryptionService);

  final bip32.BIP32Factory _bip32 = bip32.BIP32Factory(tinysecp256k1js.ecc);

  Future<a.Account> deriveRoot(String mnemonic, String password) async {
    // TODO: don't hardcode testnet
    final network = ecpair.testnet;

    network.bip32.private = 0x4b2430c; //zpriv
    network.bip32.public = 0x4b24746; //zpub

    JSUint8Array seed = await bip39.mnemonicToSeed(mnemonic).toDart;

    bip32.BIP32Interface root = _bip32.fromSeed(seed as Buffer, network);

    String wif = root.toWIF();

    String encryptedWif = await encryptionService.encrypt(wif, password);

    String publicKeyBase58 = root.neutered().toBase58();

    return a.Account(rootPrivateKey: encryptedWif, rootPublicKey: publicKeyBase58);
  }

  Future<a.Account> deriveRootFreewallet(
      String mnemonic, String password) async {
    Seed seed = Seed.fromHex(bip39.mnemonicToEntropy(mnemonic));

    Buffer buffer = Buffer.from(seed.bytes.toJS);

    bip32.BIP32Interface root = _bip32.fromSeed(buffer, ecpair.testnet);

    String wif = root.toWIF();

    String encryptedWif = await encryptionService.encrypt(wif, password);

    String publicKeyBase58 = root.neutered().toBase58();

    return a.Account(rootPrivateKey: encryptedWif, rootPublicKey: publicKeyBase58);
  }
}
