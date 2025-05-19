@JS("__horizon_js_bundle__.ecpair")
library;

import 'dart:js_interop';

import 'package:horizon/js/buffer.dart';
import "package:horizon/js/common.dart" as c;
import "package:horizon/domain/entities/network.dart" as n;
import "./signer.dart";

extension NetworkX on n.Network {
  c.Network get toJS => switch (this) {
        n.Network.mainnet => bitcoin,
        n.Network.testnet4 => testnet,
      };

  String get toBech32Prefix => switch (this) {
        n.Network.mainnet => bitcoin.bech32,
        n.Network.testnet4 => testnet.bech32,
      };
}

// CHAT I WANT TO ADD A STATIC fromString and toString method

extension type ECPairInterface._(JSObject _) implements Signer {
  external bool compressed;
  external c.Network network;
  external bool lowR;
  external Buffer? privateKey;
}

extension type ECPairFactory._(JSObject _) implements JSObject {
  external factory ECPairFactory(JSObject eccLib);

  external ECPairInterface fromPrivateKey(Buffer privateKey,
      [JSObject options]);

  external ECPairInterface fromWIF(String wif, c.Network network);
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
