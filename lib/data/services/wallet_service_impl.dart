import 'dart:js_interop';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/seed.dart';
import 'package:horizon/domain/entities/wallet.dart' as entity;
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/js/bip32.dart' as bip32;
import 'package:horizon/js/mnemonicjs.dart';
import 'package:horizon/js/bip39.dart' as bip39;
import 'package:horizon/js/buffer.dart';
import 'package:horizon/js/ecpair.dart' as ecpair; // TODO move to data;
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;
import 'package:horizon/domain/repositories/config_repository.dart';

class WalletServiceImpl implements WalletService {
  final Config config;
  @override
  EncryptionService encryptionService;

  WalletServiceImpl(this.encryptionService, this.config);

  final bip32.BIP32Factory _bip32 = bip32.BIP32Factory(tinysecp256k1js.ecc);

  @override
  Future<entity.Wallet> deriveRoot(String mnemonic, String password) async {
    final network = _getNetwork();

    JSUint8Array seed = await bip39.mnemonicToSeed(mnemonic).toDart;

    bip32.BIP32Interface root = _bip32.fromSeed(seed as Buffer, network);

    String privKey = hex.encode(root.privateKey!.toDart);

    String encryptedPrivKey =
        await encryptionService.encrypt(privKey, password);

    String encryptedMnemonic =
        await encryptionService.encrypt(mnemonic, password);

    return entity.Wallet(
        uuid: uuid.v4(),
        name: 'Wallet 1',
        encryptedPrivKey: encryptedPrivKey,
        encryptedMnemonic: encryptedMnemonic,
        publicKey: root.neutered().toBase58(),
        chainCodeHex: hex.encode(root.chainCode.toDart));
  }

  @override
  Future<entity.Wallet> deriveRootFreewallet(
      String mnemonic, String password) async {
    String seed = bip39.mnemonicToEntropy(mnemonic);

    Uint8List seedBytes = hex.decode(seed) as Uint8List;
    Buffer buffer = Buffer.from(seedBytes.toJS);

    final network = _getNetwork();

    bip32.BIP32Interface root = _bip32.fromSeed(buffer, network);

    String privKey = hex.encode(root.privateKey!.toDart);

    String encryptedPrivKey =
        await encryptionService.encrypt(privKey, password);

    String encryptedMnemonic =
        await encryptionService.encrypt(mnemonic, password);

    return entity.Wallet(
        uuid: uuid.v4(),
        name: 'Wallet 1',
        encryptedPrivKey: encryptedPrivKey,
        encryptedMnemonic: encryptedMnemonic,
        publicKey: root.neutered().toBase58(),
        chainCodeHex: hex.encode(root.chainCode.toDart));
  }

  @override
  Future<entity.Wallet> deriveRootCounterwallet(
      String mnemonic, String password) async {
    List<String> words = mnemonic.split(" ");

    Mnemonic mnemonic_ = Mnemonic(words.map((el) => el.toJS).toList().toJS);

    Seed seed = Seed.fromHex(mnemonic_.toHex());

    Buffer buffer = Buffer.from(seed.bytes.toJS);

    final network = _getNetwork();

    bip32.BIP32Interface root = _bip32.fromSeed(buffer, network);

    String privKey = hex.encode(root.privateKey!.toDart);

    String encryptedPrivKey =
        await encryptionService.encrypt(privKey, password);

    String encryptedMnemonic =
        await encryptionService.encrypt(mnemonic, password);

    return entity.Wallet(
        uuid: uuid.v4(),
        name: 'Wallet 1',
        encryptedPrivKey: encryptedPrivKey,
        encryptedMnemonic: encryptedMnemonic,
        publicKey: root.neutered().toBase58(),
        chainCodeHex: hex.encode(root.chainCode.toDart));
  }

  // TODO: this is only used for now to validate password
  // so we can use dummy fields for uuid, name,
  // encryptedPK.  we just want to make sure that
  // the generated public key matched current wallet.
  @override
  Future<entity.Wallet> fromPrivateKey(
      String privateKey, String chainCodeHex) async {
    Uint8List privateKeyBytes = hex.decode(privateKey) as Uint8List;
    Buffer privateKeyBuffer = Buffer.from(privateKeyBytes.toJS);

    Uint8List chainCodeHexBytes = hex.decode(chainCodeHex) as Uint8List;
    Buffer chainCodeHexBuffer = Buffer.from(chainCodeHexBytes.toJS);

    bip32.BIP32Interface root = _bip32.fromPrivateKey(
        privateKeyBuffer, chainCodeHexBuffer, _getNetwork());

    // String privKey = hex.encode(root.privateKey!.toDart);

    return entity.Wallet(
        uuid: '',
        name: '',
        encryptedPrivKey: "",
        publicKey: root.neutered().toBase58(),
        chainCodeHex: hex.encode(root.chainCode.toDart));
  }

  @override
  Future<entity.Wallet> fromBase58(String privateKey, String password) async {
    bip32.BIP32Interface root = _bip32.fromBase58(privateKey, _getNetwork());

    String privKey = hex.encode(root.privateKey!.toDart);

    String encryptedPrivKey =
        await encryptionService.encrypt(privKey, password);

    return entity.Wallet(
        uuid: uuid.v4(),
        name: 'Wallet 1',
        encryptedPrivKey: encryptedPrivKey,
        publicKey: root.neutered().toBase58(),
        chainCodeHex: hex.encode(root.chainCode.toDart));
  }

  _getNetwork() => switch (config.network) {
        Network.mainnet => ecpair.bitcoin,
        Network.testnet => ecpair.testnet,
        Network.regtest => ecpair.regtest,
      };
}
