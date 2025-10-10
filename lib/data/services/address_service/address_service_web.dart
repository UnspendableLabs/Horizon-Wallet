import 'dart:js_interop';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/seed.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/js/bech32.dart' as bech32;
import 'package:horizon/js/bitcoin.dart' as bitcoin;
import 'package:horizon/js/bip32.dart' as bip32;
import 'package:horizon/js/buffer.dart';
import 'package:horizon/js/ecpair.dart' as ecpair;
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;

class AddressServiceWeb implements AddressService {
  final bip32.BIP32Factory _bip32 = bip32.BIP32Factory(tinysecp256k1js.ecc);

  AddressServiceWeb();

  @override
  Future<Map<AddressV2Type, AddressV2>> deriveAddress({
    // TODO: pass bip 32 path in here instead of str
    required String path,
    required Seed seed,
    required Network network,
    required Set<AddressV2Type> addressKinds,
  }) async {
    bip32.BIP32Interface root =
        _bip32.fromSeed(Buffer.from(seed.bytes.toJS), network.toJS);

    bip32.BIP32Interface child = _deriveChildKey(
      path: path,
      privKey: hex.encode(root.privateKey!.toDart),
      chainCodeHex: hex.encode(root.chainCode.toDart),
      network: network,
    );

    final Map<AddressV2Type, AddressV2> result = {};
    for (final kind in addressKinds) {
      final address = switch (kind) {
        AddressV2Type.p2wpkh => _bech32FromBip32(child, network.toBech32Prefix),
        AddressV2Type.p2pkh => _legacyFromBip32(child, network),
      };

      result[kind] = AddressV2(
        type: kind,
        address: address,
        derivation: Bip32Path(value: path),
        publicKey: hex.encode(child.publicKey.toDart),
      );
    }

    return result;
  }

  @override
  Future<String> deriveAddressPrivateKeyWIP({
    required Bip32Path path,
    required Seed seed,
    required Network network,
  }) async {
    bip32.BIP32Interface root =
        _bip32.fromSeed(Buffer.from(seed.bytes.toJS), network.toJS);

    bip32.BIP32Interface child = _deriveChildKey(
      path: path.value,
      privKey: hex.encode(root.privateKey!.toDart),
      chainCodeHex: hex.encode(root.chainCode.toDart),
      network: network,
    );

    return hex.encode(child.privateKey!.toDart);
  }

  String _legacyFromBip32(bip32.BIP32Interface child, Network network) {
    final paymentOpts = bitcoin.PaymentOptions(
        pubkey: Buffer.from(child.publicKey), network: network.toJS);

    final payment = bitcoin.p2pkh(paymentOpts);

    return payment.address;
  }

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

AddressService createAddressServiceImpl() => AddressServiceWeb();
