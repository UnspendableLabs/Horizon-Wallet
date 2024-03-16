import 'dart:typed_data';

import 'package:bech32/bech32.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pointycastle/api.dart' as pointycastle;

class Bech32Address {
  String deriveBech32Address(Uint8List publicKey) {
    // Step 1: Hash the public key using SHA-256
    var sha256 = pointycastle.Digest("SHA-256");
    var publicKeySha256 = sha256.process(publicKey);

    var ripemd160 = pointycastle.Digest('RIPEMD-160');
    var publicKeyRipemd160 = ripemd160.process(publicKeySha256);
    List<int> ripemd5bit = to5bitArray(Uint8List.fromList(publicKeyRipemd160));

    List<int> version = [_getVersion()]; // Assuming Bitcoin network
    List<int> data = [...version, ...ripemd5bit];

    String hrp = _getHrp();
    Bech32 bech32 = Bech32(hrp, data);
    print('BECH32: ${bech32.data}');
    var encoder = const Bech32Codec();
    String bech32Address = encoder.encode(bech32);

    return bech32Address;
  }

  List<int> to5bitArray(Uint8List data) {
    List<int> bits5Array = [];
    int buffer = 0;
    int bitsFilled = 0;

    for (int byte in data) {
      buffer = (buffer << 8) | byte;
      bitsFilled += 8;

      while (bitsFilled >= 5) {
        bitsFilled -= 5;
        bits5Array.add((buffer >> bitsFilled) & 31); // Extract the top 5 bits
      }
    }

    if (bitsFilled > 0) {
      // Add the remaining bits as a 5-bit value (padded with zeros if necessary)
      bits5Array.add((buffer << (5 - bitsFilled)) & 31);
    }

    return bits5Array;
  }

  _getHrp() {
    if (dotenv.env['ENV'] == 'testnet') {
      // source:  https://bitcoin.stackexchange.com/questions/70507/how-to-create-a-bech32-address-from-a-public-key
      return 'tb'; // testnet
    }
    return 'bc'; // mainnet
  }

  _getVersion() {
    if (dotenv.env['ENV'] == 'testnet') {
      // source:  https://bitcoin.stackexchange.com/questions/70507/how-to-create-a-bech32-address-from-a-public-key
      return 111; // testnet
    }
    return 0; // mainnet
  }
}
