import 'dart:js_interop';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/js/bech32.dart' as bech32;
import 'package:horizon/js/bip32.dart' as bip32;
import 'package:horizon/js/buffer.dart';
import 'package:horizon/js/ecpair.dart' as ecpair;
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;

// TODO: implement some sort of cache

class AddressServiceImpl extends AddressService {
  final bip32.BIP32Factory _bip32 = bip32.BIP32Factory(tinysecp256k1js.ecc);
  @override
  Future<Address> deriveAddressSegwit(
      {required String privKey,
      required String chainCodeHex,
      required String accountUuid,
      required String purpose,
      required String coin,
      required String account,
      required String change,
      required int index}) async {
    // final String basePath = 'm/84\'/1\'/0\'/0/';
    String path = 'm/$purpose/$coin/$account/$change/$index';
    final network = _getNetwork();

    // print('BIP32: $_bip32');

    Buffer privKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(privKey)).toJS);
    Buffer chainCodeJs =
        Buffer.from(Uint8List.fromList(hex.decode(chainCodeHex)).toJS);

    final root = _bip32.fromPrivateKey(privKeyJS, chainCodeJs, network);

    bip32.BIP32Interface child = root.derivePath(path);

    String address = _bech32FromBip32(child);

    return Address(
      address: address,
      accountUuid: accountUuid,
      index: index,
    );
  }

  @override
  Future<List<Address>> deriveAddressSegwitRange(
      {required String privKey,
      required String chainCodeHex,
      required String accountUuid,
      required String purpose,
      required String coin,
      required String account,
      required String change,
      required int start,
      required int end}) async {
    if (start > end) {
      throw ArgumentError('Invalid range');
    }

    // Create a list of futures, each representing an address derivation
    List<Future<Address>> futures = List.generate(
      end - start + 1,
      (i) => deriveAddressSegwit(
        privKey: privKey,
        chainCodeHex: chainCodeHex,
        accountUuid: accountUuid,
        purpose: purpose,
        coin: coin,
        account: account,
        change: change,
        index: start + i,
      ),
    );

    // Wait for all futures to complete and return the results
    return await Future.wait(futures);
  }

  // Doesn't need to be async since mnemonicToEntropy is sync
  @override
  Future<Address> deriveAddressFreewalletBech32(
      {required dynamic root,
      required String accountUuid,
      required String purpose,
      required String coin,
      required String account,
      required String change,
      required int index}) async {
    /**
     * freewallet bip32 basePath takes the form of m/account'/change/address_index
     * ex: m/0'/0/0
     * 'm/0\'/0/' + index;
     */

    String path = 'm/$account/$change/$index';
    bip32.BIP32Interface child =
        (root as bip32.BIP32Interface).derivePath(path);

    String address = _bech32FromBip32(child);

    return Address(
      address: address,
      accountUuid: accountUuid,
      index: index,
    );
  }

  @override
  Future<List<Address>> deriveAddressFreewalletBech32Range(
      {required String privKey,
      required String chainCodeHex,
      required String accountUuid,
      required String purpose,
      required String coin,
      required String account,
      required String change,
      required int start,
      required int end}) async {
    if (start > end) {
      throw ArgumentError('Invalid range');
    }
    final network = _getNetwork();
    Buffer privKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(privKey)).toJS);
    Buffer chainCodeJs =
        Buffer.from(Uint8List.fromList(hex.decode(chainCodeHex)).toJS);

    final root = _bip32.fromPrivateKey(privKeyJS, chainCodeJs, network);

    List<Address> addresses = [];

    for (int i = start; i <= end; i++) {
      Address address = await deriveAddressFreewalletBech32(
          root: root,
          accountUuid: accountUuid,
          purpose: purpose,
          coin: coin,
          account: account,
          change: change,
          index: i);
      addresses.add(address);
    }

    return addresses;
  }

  Future<String> deriveAddressPrivateKey(
      {required String rootPrivKey,
      required String chainCodeHex,
      required String purpose,
      required String coin,
      required String account,
      required String change,
      required int index}) async {
    String path = 'm/$purpose/$coin/$account/$change/$index';
    final network = _getNetwork();

    Buffer privKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(rootPrivKey)).toJS);
    Buffer chainCodeJs =
        Buffer.from(Uint8List.fromList(hex.decode(chainCodeHex)).toJS);

    final root = _bip32.fromPrivateKey(privKeyJS, chainCodeJs, network);

    bip32.BIP32Interface child = root.derivePath(path);

    return hex.encode(child.privateKey!.toDart);
  }

  String _bech32FromBip32(bip32.BIP32Interface child) {
    List<int> identifier = child.identifier.toDart;
    List<int> words = bech32
        .toWords(identifier.map((el) => el.toJS).toList().toJS)
        .toDart
        .map((el) => el.toDartInt)
        .toList();
    words.insert(0, 0);
    return bech32.encode(
        ecpair.testnet.bech32, words.map((el) => el.toJS).toList().toJS);
  }

  _getNetwork() {
    bool isTestnet = const String.fromEnvironment('TEST', defaultValue: 'true') == 'true';
    return isTestnet ? ecpair.testnet : ecpair.bitcoin;
  }
}
