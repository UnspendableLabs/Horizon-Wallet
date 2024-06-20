import 'dart:js_interop';

import 'package:convert/convert.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/data/models/seed.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/hd_wallet_entity.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/hd_wallet_service.dart';
import 'package:horizon/js/bech32.dart' as bech32;
import 'package:horizon/js/bip32.dart' as bip32;
import 'package:horizon/js/bip39.dart' as bip39;
import 'package:horizon/js/buffer.dart';
import 'package:horizon/js/ecpair.dart' as ecpair; // TODO move to data;
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;

class HDWalletServiceImpl extends HDWalletService {
  EncryptionService encryptionService;

  HDWalletServiceImpl(this.encryptionService);

  final bip32.BIP32Factory _bip32 = bip32.BIP32Factory(tinysecp256k1js.ecc);

  @override
  Future<HDWalletEntity> deriveHDWallet({
    required String mnemonic,
    required String password,
    required String purpose,
    required int coinType,
    required int accountIndex,
  }) async {
    // STEP 1: derive root
    JSUint8Array seed = await bip39.mnemonicToSeed(mnemonic).toDart;
    final network = ecpair.bitcoin; // TODO
    bip32.BIP32Interface root = _bip32.fromSeed(seed as Buffer, network);
    String encryptedWif = await encryptionService.encrypt(root.toWIF(), password);
    Wallet walletEntity = Wallet(uuid: uuid.v4(), name: 'Wallet 1', wif: encryptedWif);

    // STEP 2: derive account node
    final String basePath = 'm/${purpose}\'/${coinType}\'/${accountIndex}';
    bip32.BIP32Interface accountNode = root.derivePath(basePath);
    final xpub = accountNode.neutered().toBase58(); // TODO! change prefix
    Account accountEntity = Account(
      uuid: uuid.v4(),
      name: 'm/$purpose\'/$coinType\'/$accountIndex\'',
      walletUuid: walletEntity.uuid,
      purpose: purpose,
      coinType: coinType,
      accountIndex: accountIndex,
      xPub: xpub,
    );

    // STEP 3: derive address
    int change = 0;
    int addressIndex = 0;
    bip32.BIP32Interface child = accountNode.derive(change).derive(addressIndex);
    List<int> identifier = child.identifier.toDart;
    List<int> words =
        bech32.toWords(identifier.map((el) => el.toJS).toList().toJS).toDart.map((el) => el.toDartInt).toList();
    words.insert(0, 0);
    String address = bech32.encode(ecpair.bitcoin.bech32, words.map((el) => el.toJS).toList().toJS);
    Address addressEntity = Address(
        address: address,
        publicKey: hex.encode(child.publicKey.toDart),
        privateKeyWif: child.toWIF(),
        accountUuid: accountEntity.uuid,
        addressIndex: addressIndex);

    return HDWalletEntity(wallet: walletEntity, account: accountEntity, address: addressEntity);
  }

  // Doesn't need to be async since mnemonicToEntropy is sync
  @override
  Future<HDWalletEntity> deriveFreewalletBech32HDWallet({
    required String mnemonic,
    required String password,
    required String purpose,
    required int coinType,
    required int accountIndex,
  }) async {
    // STEP 1: derive root

    // Here we are treating entropy as a seed (what freewallet does)
    Seed seed = Seed.fromHex(bip39.mnemonicToEntropy(mnemonic));
    Buffer buffer = Buffer.from(seed.bytes.toJS);
    final network = ecpair.bitcoin; // TODO
    bip32.BIP32Interface root = _bip32.fromSeed(buffer, network);
    String encryptedWif = await encryptionService.encrypt(root.toWIF(), password);
    Wallet walletEntity = Wallet(uuid: uuid.v4(), name: 'Wallet 1', wif: encryptedWif);

    /**
     * freewallet bip32 basePath takes the form of m/account'/change/address_index
     * ex: m/0'/0/0
     */

    // STEP 2: Derive the account key
    // BIP32 path: m/0'
    bip32.BIP32Interface accountNode = root.deriveHardened(accountIndex);
    String xpub = accountNode.neutered().toBase58(); // TODO: change prefix
    Account accountEntity = Account(
      uuid: uuid.v4(),
      name: 'm/$accountIndex\'/',
      walletUuid: walletEntity.uuid,
      purpose: purpose,
      coinType: coinType,
      accountIndex: accountIndex,
      xPub: xpub,
    );

    // BIP32 path: m/0'/0
    const change = 0; // 0 for external chain, 1 for internal/change chain

    // STEP 3: Derive the change key
    bip32.BIP32Interface changeNode = accountNode.derive(change);

    // STEP 4: Derive the address
    const addressIndex = 0;
    // Derive the address key
    bip32.BIP32Interface addressNode = changeNode.derive(addressIndex);
    List<int> identifier = addressNode.identifier.toDart;
    List<int> words =
        bech32.toWords(identifier.map((el) => el.toJS).toList().toJS).toDart.map((el) => el.toDartInt).toList();
    words.insert(0, 0);
    String address = bech32.encode(ecpair.bitcoin.bech32, words.map((el) => el.toJS).toList().toJS);
    Address addressEntity = Address(
        address: address,
        publicKey: hex.encode(addressNode.publicKey.toDart),
        privateKeyWif: addressNode.toWIF(),
        accountUuid: accountEntity.uuid,
        addressIndex: addressIndex);

    return HDWalletEntity(wallet: walletEntity, account: accountEntity, address: addressEntity);
  }


 // TODO: initial idea not final
  @override
  Future<AccountAddressEntity> addNewAccountAndAddress({
    required String encryptedRootWif,
    required String walletUuid,
    required String password,
    required String purpose,
    required int coinType,
    required int accountIndex,
  }) async {
    // STEP 1: decrypt the root WIF
    final decryptedRootWif = await encryptionService.decrypt(encryptedRootWif, password);
    final network = ecpair.bitcoin;
    final root = _bip32.fromWIF(decryptedRootWif, network);

    // STEP 2: derive account node
    final String basePath = 'm/${purpose}\'/${coinType}\'/${accountIndex}';
    bip32.BIP32Interface accountNode = root.derivePath(basePath);
    final xpub = accountNode.neutered().toBase58(); // TODO! change prefix
    Account accountEntity = Account(
      uuid: uuid.v4(),
      name: 'm/$purpose\'/$coinType\'/$accountIndex\'',
      walletUuid: walletUuid,
      purpose: purpose,
      coinType: coinType,
      accountIndex: accountIndex,
      xPub: xpub,
    );

    // STEP 3: derive address
    int change = 0;
    int addressIndex = 0;
    bip32.BIP32Interface child = accountNode.derive(change).derive(addressIndex);
    List<int> identifier = child.identifier.toDart;
    List<int> words =
        bech32.toWords(identifier.map((el) => el.toJS).toList().toJS).toDart.map((el) => el.toDartInt).toList();
    words.insert(0, 0);
    String address = bech32.encode(ecpair.bitcoin.bech32, words.map((el) => el.toJS).toList().toJS);
    Address addressEntity = Address(
        address: address,
        publicKey: hex.encode(child.publicKey.toDart),
        privateKeyWif: child.toWIF(),
        accountUuid: accountEntity.uuid,
        addressIndex: addressIndex);
    return AccountAddressEntity(account: accountEntity, address: addressEntity);
  }
}
