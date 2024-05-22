import 'package:uniparty/domain/services/wallet_service.dart';
import 'package:uniparty/domain/entities/wallet.dart' as w;
import 'package:uniparty/domain/entities/seed.dart';
import 'package:uniparty/js/bip32.dart' as bip32;
import 'package:uniparty/js/tiny_secp256k1.dart' as tinysecp256k1js;
import 'package:uniparty/js/bip39.dart' as bip39;
import 'package:uniparty/js/ecpair.dart' as ecpair; // TODO move to data;
import 'package:uniparty/js/buffer.dart';
import 'dart:js_interop';

class WalletServiceImpl implements WalletService {
  final bip32.BIP32Factory _bip32 = bip32.BIP32Factory(tinysecp256k1js.ecc);

  Future<w.Wallet> deriveRoot(String mnemonic) async {
    // TODO: don't hardcode testnet
    final network = ecpair.testnet;

    network.bip32.private = 0x4b2430c; //zpriv
    network.bip32.public = 0x4b24746; //zpub

    JSUint8Array seed = await bip39.mnemonicToSeed(mnemonic).toDart;

    bip32.BIP32Interface root = _bip32.fromSeed(seed as Buffer, network);

    String wif = root.toWIF();

    String publicKeyBase58 = root.neutered().toBase58();
    
    return w.Wallet(wif: wif, publicKey: publicKeyBase58 );

  }

  Future<w.Wallet> deriveRootFreewallet(String mnemonic) async {

    Seed seed = Seed.fromHex(bip39.mnemonicToEntropy(mnemonic));

    Buffer buffer = Buffer.from(seed.bytes.toJS);

    bip32.BIP32Interface root = _bip32.fromSeed(buffer, ecpair.testnet);


    String wif = root.toWIF();

    String publicKeyBase58 = root.neutered().toBase58();

    return w.Wallet(wif: wif, publicKey: publicKeyBase58 );

  }
}
