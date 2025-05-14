import 'dart:js_interop';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/seed.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/js/bech32.dart' as bech32;
import 'package:horizon/js/bip32.dart' as bip32;
import 'package:horizon/js/buffer.dart';
import 'package:horizon/js/ecpair.dart' as ecpair;
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;
import 'package:horizon/domain/entities/seed.dart';

class AddressServiceImpl implements AddressService {
  final bip32.BIP32Factory _bip32 = bip32.BIP32Factory(tinysecp256k1js.ecc);

  AddressServiceImpl();

  @override
  Future<String> deriveAddressWIP({
    required String path,
    required Seed seed,
    required Network network,
  }) async {
    bip32.BIP32Interface root =
        _bip32.fromSeed(Buffer.from(seed.bytes.toJS), network.toJS);

    bip32.BIP32Interface child = _deriveChildKey(
      path: path,
      privKey: hex.encode(root.privateKey!.toDart),
      chainCodeHex: hex.encode(root.chainCode.toDart),
      network: network,
    );

    String address = _bech32FromBip32(child, network.toBech32Prefix);

    return address;
  }

  @override
  Future<String> deriveAddressPrivateKeyWIP({
    required AddressV2 address,
    required Seed seed,
    required Network network,
  }) async {
    bip32.BIP32Interface root =
        _bip32.fromSeed(Buffer.from(seed.bytes.toJS), network.toJS);

    bip32.BIP32Interface child = _deriveChildKey(
      path: address.path,
      privKey: hex.encode(root.privateKey!.toDart),
      chainCodeHex: hex.encode(root.chainCode.toDart),
      network: network,
    );

    return hex.encode(child.privateKey!.toDart);
  }

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
    throw UnimplementedError("deprecated");
    // final String basePath = 'm/84\'/1\'/0\'/0/';
    // String path = 'm/$purpose/$coin/$account/$change/$index';
    //
    // bip32.BIP32Interface child = _deriveChildKey(
    //     path: path, privKey: privKey, chainCodeHex: chainCodeHex);
    //
    // String address = _bech32FromBip32(child, _getNetwork().toBech32Prefix);
    //
    // return Address(
    //   address: address,
    //   accountUuid: accountUuid,
    //   index: index,
    // );
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
    throw UnimplementedError("deprecated");
    // if (start > end) {
    //   throw ArgumentError('Invalid range');
    // }
    //
    // // Create a list of futures, each representing an address derivation
    // List<Future<Address>> futures = List.generate(
    //   end - start + 1,
    //   (i) => deriveAddressSegwit(
    //     privKey: privKey,
    //     chainCodeHex: chainCodeHex,
    //     accountUuid: accountUuid,
    //     purpose: purpose,
    //     coin: coin,
    //     account: account,
    //     change: change,
    //     index: start + i,
    //   ),
    // );
    //
    // // Wait for all futures to complete and return the results
    // return await Future.wait(futures);
  }

  // Doesn't need to be async since mnemonicToEntropy is sync
  @override
  Future<Address> deriveAddressFreewallet(
      {required AddressType type,
      required dynamic root,
      required String accountUuid,
      required String account,
      required String change,
      required int index}) async {
    throw UnimplementedError("deprecated");
    // /**
    //  * freewallet bip32 basePath takes the form of m/account'/change/address_index
    //  * ex: m/0'/0/0
    //  * 'm/0\'/0/' + index;
    //  */
    //
    // String path = 'm/$account/$change/$index';
    //
    // bip32.BIP32Interface child =
    //     (root as bip32.BIP32Interface).derivePath(path);
    //
    // String address = switch (type) {
    //   AddressType.bech32 =>
    //     _bech32FromBip32(child, _getNetwork().toBech32Prefix),
    //   AddressType.legacy => _legacyFromBip32(child),
    // };
    //
    // return Address(
    //   address: address,
    //   accountUuid: accountUuid,
    //   index: index,
    // );
  }

  @override
  Future<List<Address>> deriveAddressFreewalletRange(
      {required AddressType type,
      required String privKey,
      required String chainCodeHex,
      required String accountUuid,
      required String account,
      required String change,
      required int start,
      required int end}) async {
    throw UnimplementedError("deprecated");
    // if (start > end) {
    //   throw ArgumentError('Invalid range');
    // }
    //
    // final root = _deriveRoot(privKey: privKey, chainCodeHex: chainCodeHex);
    //
    // List<Address> addresses = [];
    //
    // for (int i = start; i <= end; i++) {
    //   Address address = await deriveAddressFreewallet(
    //       type: type,
    //       root: root,
    //       accountUuid: accountUuid,
    //       account: account,
    //       change: change,
    //       index: i);
    //   addresses.add(address);
    // }
    //
    // return addresses;
  }

  @override
  Future<String> deriveAddressPrivateKey(
      {required String rootPrivKey,
      required String chainCodeHex,
      required String purpose,
      required String coin,
      required String account,
      required String change,
      required int index,
      required ImportFormat importFormat}) async {
    throw UnimplementedError("unimplemented");
    // String path = _getPathForImportFormat(
    //     purpose: purpose,
    //     coin: coin,
    //     account: account,
    //     change: change,
    //     index: index,
    //     importFormat: importFormat);
    //
    // bip32.BIP32Interface child = _deriveChildKey(
    //     path: path, privKey: rootPrivKey, chainCodeHex: chainCodeHex);
    //
    // return hex.encode(child.privateKey!.toDart);
  }

  @override
  Future<String> getAddressWIFFromPrivateKey(
      {required String rootPrivKey,
      required String chainCodeHex,
      required String purpose,
      required String coin,
      required String account,
      required String change,
      required int index,
      required ImportFormat importFormat}) async {
    throw UnimplementedError("unimplemented");
    // String path = _getPathForImportFormat(
    //     purpose: purpose,
    //     coin: coin,
    //     account: account,
    //     change: change,
    //     index: index,
    //     importFormat: importFormat);
    //
    // bip32.BIP32Interface child = _deriveChildKey(
    //     path: path, privKey: rootPrivKey, chainCodeHex: chainCodeHex);
    // return child.toWIF();
  }

  // String _legacyFromBip32(bip32.BIP32Interface child) {
  //
  //   final network = _getNetwork();
  //
  //   final paymentOpts = bitcoin.PaymentOptions(
  //       pubkey: Buffer.from(child.publicKey), network: network);
  //
  //   final payment = bitcoin.p2pkh(paymentOpts);
  //
  //   return payment.address;
  // }

  String _bech32FromBip32(bip32.BIP32Interface child, String bech32_) {
    List<int> identifier = child.identifier.toDart;
    List<int> words = bech32
        .toWords(identifier.map((el) => el.toJS).toList().toJS)
        .toDart
        .map((el) => el.toDartInt)
        .toList();
    words.insert(0, 0);
    return bech32.encode(bech32_, words.map((el) => el.toJS).toList().toJS);
  }

  // _getNetwork() => switch (config.network) {
  //       Network.mainnet => ecpair.bitcoin,
  //       // Network.testnet => ecpair.testnet,
  //       Network.testnet4 => ecpair.testnet,
  //       // Network.regtest => ecpair.regtest,
  //     };

  // _getNetworkBech32() => switch (config.network) {
  //       Network.mainnet => ecpair.bitcoin.bech32,
  //       // Network.testnet => ecpair.testnet.bech32,
  //       Network.testnet4 => ecpair.testnet.bech32,
  //       // Network.regtest => ecpair.regtrst.bech32,
  //     };
  //
  // _getNetworkBech32() => ecpair.testnet.bech32;

  // String _getPathForImportFormat(
  //         {required String purpose,
  //         required String coin,
  //         required String account,
  //         required String change,
  //         required int index,
  //         required ImportFormat importFormat}) =>
  //     switch (importFormat) {
  //       ImportFormat.horizon => 'm/$purpose/$coin/$account/$change/$index',
  //       _ => 'm/$account/$change/$index',
  //     };

  bip32.BIP32Interface _deriveChildKey(
      {required String path,
      required String privKey,
      required String chainCodeHex,
      required Network network}) {
    final root = _deriveRoot(
        privKey: privKey, chainCodeHex: chainCodeHex, network: network);
    bip32.BIP32Interface child = root.derivePath(path);
    return child;
  }

  bip32.BIP32Interface _deriveRoot(
      {required String privKey,
      required String chainCodeHex,
      required Network network}) {
    Buffer privKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(privKey)).toJS);
    Buffer chainCodeJs =
        Buffer.from(Uint8List.fromList(hex.decode(chainCodeHex)).toJS);
    return _bip32.fromPrivateKey(privKeyJS, chainCodeJs, network.toJS);
  }
}
