@JS("ecpair")
library;

import 'dart:js_interop';

import 'package:horizon/js/buffer.dart';
import "package:horizon/js/common.dart" as c;

extension type ECPair._(JSObject _) implements JSObject {
  external bool comppessed;
  external bool lowR;
  external c.Network network;
  external JSUint8Array privateKey;
  external JSUint8Array publicKey;
}

extension type ECPairFactory._(JSObject _) implements JSObject {
  external factory ECPairFactory(JSObject eccLib);

  external ECPair fromPrivateKey(Buffer privateKey, [JSObject options]);

  external ECPair fromWIF(String wif, c.Network network);
}

@JS("networks.bitcoin")
external c.Network get bitcoin;

@JS("networks.testnet")
external c.Network get testnet;


final regtest = ({
  "messagePrefix": '\x18Bitcoin Signed Message:\n',
  "bech32": 'bcrt',
  "bip32": {
    "public": 0x043587cf,
    "private": 0x04358394,
  },
  "pubKeyHash": 0x6f,
  "scriptHash": 0xc4,
  "wif": 0xef,
}).jsify() as c.Network;
