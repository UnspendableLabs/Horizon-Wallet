import 'package:uniparty/domain/services/address_service.dart';
import 'package:uniparty/domain/entities/address.dart';
import 'package:uniparty/domain/entities/seed.dart';
import 'package:uniparty/js/ecpair.dart' as ecpair; // TODO move to data;
import 'package:uniparty/js/bip32.dart' as bip32;
import 'package:uniparty/js/bip39.dart' as bip39;
import 'package:uniparty/js/bech32.dart' as bech32;
import 'package:uniparty/js/tiny_secp256k1.dart' as tinysecp256k1js;
import 'package:uniparty/js/buffer.dart';
import 'dart:js_interop';

class AddressServiceImpl extends AddressService {

  final bip32.BIP32Factory _bip32 = bip32.BIP32Factory(tinysecp256k1js.ecc);

  @override
  Future<Address> deriveAddressSegwit(String mnemonic, String path) async {
    JSUint8Array seed = await bip39.mnemonicToSeed(mnemonic).toDart;

    final network = ecpair.testnet;

    network.bip32.private = 0x4b2430c; //zpriv
    network.bip32.public = 0x4b24746; //zpub

    // TODO: refine type
    bip32.BIP32Interface root = _bip32.fromSeed(seed as Buffer, network);

    bip32.BIP32Interface child = root.derivePath(path);

    String address = _bech32FromBip32(child);

    return Address(address: address, derivationPath: path);
  }

  // Doesn't need to be async since mnemonicToEntropy is sync
  @override
  Future<Address> deriveAddressFreewalletBech32(String mnemonic, int index) async {

    bip32.BIP32Interface child = _deriveFreeWalletChildBip32Interface(mnemonic, index);

    String address = _bech32FromBip32(child);

    return Address(address: address, derivationPath: 'm/0\'/0/' + index.toString());
  }

  @override
  Future<Address> deriveAddressFreewalletLegacy(String mnemonic, int index) async {

    throw UnimplementedError();

    // bip32.BIP32Interface child = _deriveFreeWalletChildBip32Interface(mnemonic, index);
    //
    //
    //
    // List<int> identifier = child.identifier.toDart;
    //
    // List<int> words = bech32
    //     .toWords(identifier.map((el) => el.toJS).toList().toJS)
    //     .toDart
    //     .map((el) => el.toDartInt)
    //     .toList();
    //
    // words.insert(0, 0);
    //
    // final String address =
    //     bech32.encode(ecpair.testnet.bech32, words.map((el) => el.toJS).toList().toJS);
    //
    // return Address(address: address, derivationPath: 'm/0\'/0/' + index.toString());

  }


  bip32.BIP32Interface _deriveFreeWalletChildBip32Interface(String mnemonic, int index) {

    // String basePath = 'm/0\'/0/';  THIS IS ACTUAL PATH, BUT WE ARE USING 44'/0' FOR TESTING
    // as 'm/0' is not valid and causes error.  Need to investigate

    String basePath = 'm/44\'/1/';
    // Here we are treating entropy as a see ( what freewallet does)
    Seed seed = Seed.fromHex(bip39.mnemonicToEntropy(mnemonic));

    Buffer buffer = Buffer.from(seed.bytes.toJS);

    // network.bip32.private = 0x4b2430c; //zpriv
    // network.bip32.public = 0x4b24746; //zpub

    bip32.BIP32Interface root = _bip32.fromSeed(buffer, ecpair.testnet);

    bip32.BIP32Interface child = root.derivePath(basePath + index.toString());


    return child;

  }


  String _bech32FromBip32(bip32.BIP32Interface child) {
    List<int> identifier = child.identifier.toDart;
    List<int> words = bech32
        .toWords(identifier.map((el) => el.toJS).toList().toJS)
        .toDart
        .map((el) => el.toDartInt)
        .toList();
    words.insert(0, 0);
    return bech32.encode(ecpair.testnet.bech32, words.map((el) => el.toJS).toList().toJS);
  }



}
