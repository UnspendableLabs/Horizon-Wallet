import 'dart:developer';
import 'dart:js_interop';

import 'package:convert/convert.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/js/bech32.dart' as bech32;
import 'package:horizon/js/bip32.dart' as bip32;
import 'package:horizon/js/ecpair.dart' as ecpair; // TODO move to data;
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;

// TODO: implement some sort of cache

/**
 * const bip32 = require('bip32');
const bitcoin = require('bitcoinjs-lib');

// Replace with your xpub
const xpub = 'your xpub here';

// Convert xpub to a BIP32 node
const node = bip32.fromBase58(xpub);

// Derive the child key for the first address (index 0) in the external chain (0)
const child = node.derive(0).derive(0);

// Generate the P2WPKH (SegWit) address
const { address } = bitcoin.payments.p2wpkh({ pubkey: child.publicKey, network: bitcoin.networks.bitcoin });

console.log('Address:', address);

 */
class AddressServiceImpl extends AddressService {
  final bip32.BIP32Factory _bip32 = bip32.BIP32Factory(tinysecp256k1js.ecc);

  @override
  Future<Address> deriveAddressSegwit(String xpub, int index) async {
    final node = _bip32.fromBase58(xpub);
    debugger(when: true);
    int change = 0;

    bip32.BIP32Interface child = node.derive(change).derive(index);

    List<int> identifier = child.identifier.toDart;
    List<int> words =
        bech32.toWords(identifier.map((el) => el.toJS).toList().toJS).toDart.map((el) => el.toDartInt).toList();
    words.insert(0, 0);
    String address = bech32.encode(ecpair.testnet.bech32, words.map((el) => el.toJS).toList().toJS);
    final wif = child.toWIF();
    debugger(when: true);
    return Address(
        address: address,
        publicKey: hex.encode(child.publicKey.toDart),
        privateKeyWif: child.toWIF(),
        accountUuid: uuid.v4(),
        addressIndex: index);
  }

  // @override
  // Future<List<Address>> deriveAddressSegwitRange(String mnemonic, int start, int end) async {
  //   if (start > end) {
  //     throw ArgumentError('Invalid range');
  //   }

  //   List<Address> addresses = [];

  //   for (int i = start; i <= end; i++) {
  //     Address address = await deriveAddressSegwit(mnemonic, i);
  //     addresses.add(address);
  //   }

  //   return addresses;
  // }

  // // Doesn't need to be async since mnemonicToEntropy is sync
  // @override
  // Future<Address> deriveAddressFreewalletBech32(String mnemonic, int index) async {
  //   bip32.BIP32Interface child = _deriveFreeWalletChildBip32Interface(mnemonic, index);

  //   List<int> identifier = child.identifier.toDart;
  //   List<int> words =
  //       bech32.toWords(identifier.map((el) => el.toJS).toList().toJS).toDart.map((el) => el.toDartInt).toList();
  //   words.insert(0, 0);
  //   String address = bech32.encode(ecpair.testnet.bech32, words.map((el) => el.toJS).toList().toJS);

  //   return Address(
  //       address: address,
  //       // derivationPath: 'm/0\'/0/' + index.toString(),
  //       publicKey: hex.encode(child.publicKey.toDart),
  //       privateKeyWif: child.toWIF(),
  //       accountUuid: uuid.v4(),
  //       addressIndex: index);
  // }

  // @override
  // Future<List<Address>> deriveAddressFreewalletBech32Range(String mnemonic, int start, int end) async {
  //   if (start > end) {
  //     throw ArgumentError('Invalid range');
  //   }

  //   List<Address> addresses = [];

  //   for (int i = start; i <= end; i++) {
  //     Address address = await deriveAddressFreewalletBech32(mnemonic, i);
  //     addresses.add(address);
  //   }

  //   return addresses;
  // }

  // @override
  // Future<Address> deriveAddressFreewalletLegacy(String mnemonic, int index) async {
  //   throw UnimplementedError();
  // }

  // @override
  // Future<List<Address>> deriveAddressFreewalletLegacyRange(String mnemonic, int start, int end) async {
  //   if (start > end) {
  //     throw ArgumentError('Invalid range');
  //   }

  //   List<Address> addresses = [];

  //   for (int i = start; i <= end; i++) {
  //     Address address = await deriveAddressFreewalletLegacy(mnemonic, i);
  //     addresses.add(address);
  //   }

  //   return addresses;
  // }

  // bip32.BIP32Interface _deriveFreeWalletChildBip32Interface(String mnemonic, int index) {
  //   String basePath = 'm/0\'/1/';
  //   // Here we are treating entropy as a see ( what freewallet does)
  //   Seed seed = Seed.fromHex(bip39.mnemonicToEntropy(mnemonic));

  //   Buffer buffer = Buffer.from(seed.bytes.toJS);

  //   // network.bip32.private = 0x4b2430c; //zpriv
  //   // network.bip32.public = 0x4b24746; //zpub

  //   bip32.BIP32Interface root = _bip32.fromSeed(buffer, ecpair.testnet);

  //   bip32.BIP32Interface child = root.derivePath(basePath + index.toString());

  //   return child;
  // }

  // String _bech32FromBip32(bip32.BIP32Interface child) {
  //   List<int> identifier = child.identifier.toDart;
  //   List<int> words =
  //       bech32.toWords(identifier.map((el) => el.toJS).toList().toJS).toDart.map((el) => el.toDartInt).toList();
  //   words.insert(0, 0);
  //   return bech32.encode(ecpair.testnet.bech32, words.map((el) => el.toJS).toList().toJS);
  // }
}
