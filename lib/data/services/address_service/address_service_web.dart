import 'dart:js_interop';
import 'dart:typed_data';
import 'package:hex/hex.dart';

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

// TODO: add a notion of AddressPurpose??
bool _btcEccInited = false;

class _ParsedPath {
  final int purpose; // hardened (e.g., 84 -> 84')
  final int coin; // hardened (0 mainnet, 1 test/signet)
  final int account; // hardened
  final int change; // 0/1
  final int index; // 0..n
  _ParsedPath(this.purpose, this.coin, this.account, this.change, this.index);
}

_ParsedPath _parseStdPath(String path) {
  // m/<purpose>'/<coin>'/<account>'/<change>/<index>
  final parts = path.split('/');
  if (parts.length != 6 || parts[0] != 'm') {
    throw ArgumentError('Unsupported BIP path format: $path');
  }
  int ph(String s) => int.parse(s.replaceAll("'", ""));
  int pn(String s) => int.parse(s);
  return _ParsedPath(
    ph(parts[1]),
    ph(parts[2]),
    ph(parts[3]),
    pn(parts[4]),
    pn(parts[5]),
  );
}

String _formatPath({
  required int purpose,
  required int coin,
  required int account,
  required int change,
  required int index,
}) =>
    "m/$purpose'/$coin'/$account'/$change/$index";

int _coinTypeFor(Network net) => net.isMainnet ? 0 : 1;

// If the incoming path isn't BIP86, re-map ONLY the purpose/coin for P2TR.
// Account/change/index are preserved.
String _taprootPathFromBase(String base, Network network) {
  final p = _parseStdPath(base);
  return _formatPath(
    purpose: 86, // BIP86
    coin: _coinTypeFor(network), // 0' mainnet, 1' test/signet
    account: p.account,
    change: p.change,
    index: p.index,
  );
}

void _ensureEcc() {
  if (_btcEccInited) return;
  // tinysecp256k1js.ecc is your JS ECC object (already used by BIP32Factory).
  bitcoin.initEccLib(tinysecp256k1js.ecc);
  _btcEccInited = true;
}

class AddressServiceWeb implements AddressService {
  final bip32.BIP32Factory _bip32 = bip32.BIP32Factory(tinysecp256k1js.ecc);
  ecpair.ECPairFactory ecpairFactory =
      ecpair.ECPairFactory(tinysecp256k1js.ecc);

  AddressServiceWeb() {
    _ensureEcc();
  }

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

    bip32.BIP32Interface defaultChild = _deriveChildKey(
      path: path,
      privKey: hex.encode(root.privateKey!.toDart),
      chainCodeHex: hex.encode(root.chainCode.toDart),
      network: network,
    );

    final Map<AddressV2Type, AddressV2> result = {};
    for (final kind in addressKinds) {
      print("trying to derive address of kind: $kind");

      final bip32.BIP32Interface child = switch (kind) {
        AddressV2Type.p2tr => _deriveChildKey(
            path: _taprootPathFromBase(path, network),
            privKey: hex.encode(root.privateKey!.toDart),
            chainCodeHex: hex.encode(root.chainCode.toDart),
            network: network,
          ),
        _ => defaultChild,
      };

      final address = switch (kind) {
        AddressV2Type.p2wpkh => _bech32FromBip32(child, network.toBech32Prefix),
        AddressV2Type.p2pkh => _legacyFromBip32(child, network),
        AddressV2Type.p2tr => _taprootFromBip32(child, network),
      };

      final compressedPub = child.publicKey.toDart; // Uint8List of length 33
      final String publicKeyHex = switch (kind) {
        AddressV2Type.p2tr =>
          hex.encode(compressedPub.sublist(1, 33)), // x-only
        _ => hex.encode(compressedPub), // compressed
      };
      print("derived address of kind $kind: $address");

      result[kind] = AddressV2(
          type: kind,
          address: address,
          derivation: Bip32Path(value: _taprootPathFromBase(path, network)),
          publicKey: publicKeyHex);
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

  String _taprootFromBip32(bip32.BIP32Interface child, Network network) {
    // 33-byte compressed pubkey → drop prefix to get x-only (32 bytes)
    try {
      final Uint8List compressed = child.publicKey.toDart;
      if (compressed.length != 33) {
        throw StateError(
            'Expected 33-byte compressed pubkey, got ${compressed.length}');
      }
      final Uint8List xOnlyBytes = compressed.sublist(1); // [1..33)

      // Back to JS Buffer
      final Buffer xOnly = Buffer.from(xOnlyBytes.toJS);

      // Use Taproot options binding (BIP86 key-path when only internalPubkey is provided)
      final opts = bitcoin.PaymentOptionsTaproot(
        internalPubkey: xOnly,
        network: network.toJS,
      );

      final pay = bitcoin.p2tr(opts);

      return pay.address; // bech32m
    } catch (e, callstack) {
      print(e);
      print(callstack);
      rethrow;
    }
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
