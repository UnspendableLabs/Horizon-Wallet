import 'package:uniparty/domain/services/address_service.dart';
import 'package:uniparty/domain/entities/seed_entity.dart';
import 'package:uniparty/js/ecpair.dart' as ecpair; // TODO move to data;
import 'package:uniparty/js/bip32.dart' as bip32;
import 'package:uniparty/js/bip39.dart' as bip39;
import 'package:uniparty/js/bech32.dart' as bech32;
import 'package:uniparty/js/tiny_secp256k1.dart' as tinysecp256k1js;
import 'package:uniparty/js/buffer.dart';
import 'dart:js_interop';

class AddressServiceImpl extends AddressService {
  @override
  final bip32.BIP32Factory _bip32 = bip32.BIP32Factory(tinysecp256k1js.ecc);

  @override
  Future<String> deriveAddressSegwit(String mnemonic, String path) async {
    JSUint8Array seed = await bip39.mnemonicToSeed(mnemonic).toDart;

    final network = ecpair.testnet;

    network.bip32.private = 0x4b2430c; //zpriv
    network.bip32.public = 0x4b24746; //zpub

    // TODO: refine type
    bip32.BIP32Interface root = _bip32.fromSeed(seed as Buffer, network);

    bip32.BIP32Interface child = root.derivePath(path);

    // For some reason we have to go from js to dart to js
    List<int> identifier = child.identifier.toDart;
    // TODO: remove type cast
    List<int> words = bech32
        .toWords(identifier.map((el) => el.toJS).toList().toJS)
        .toDart
        .map((el) => el.toDartInt)
        .toList();

    words.insert(0, 0);

    final String address =
        bech32.encode(network.bech32, words.map((el) => el.toJS).toList().toJS);

    print(address);
    return address;
  }
}
