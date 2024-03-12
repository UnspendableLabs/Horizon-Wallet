import 'dart:typed_data';

import 'package:bech32/bech32.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pointycastle/api.dart' as pointycastle;

class Bech32Address {
  String deriveBech32Address(Uint8List publicKey) {
    // Step 1: Hash the public key using SHA-256
    var sha256 = pointycastle.Digest("SHA-256");
    var publicKeySha256 = sha256.process(publicKey);

    // Step 2: Hash the result of step 1 using RIPEMD-160
    var ripemd160 = pointycastle.Digest('RIPEMD-160');
    var publicKeyRipemd160 = ripemd160.process(publicKeySha256);

// Step 3: Prepend the network identifier byte
    List<int> version = [_getVersion()]; // Assuming Bitcoin network
    List<int> data = [...version, ...publicKeyRipemd160];
    Uint8List uint8ListData = Uint8List.fromList(data);

// Step 4: Hash the result of step 3 twice using SHA-256 and take the first four bytes as the checksum
    var hash1 = sha256.process(uint8ListData);
    var hash2 = sha256.process(hash1);
    var checksum = hash2.sublist(0, 4);

    // Step 5: Append the checksum to the result of step 3
    List<int> payload = data + checksum;

// Step 6: Encode the result using Bech32 encoding
    String hrp = _getHrp();
    Bech32 bech32 = Bech32(hrp, payload);
    var encoder = const Bech32Codec();
    String bech32Address = encoder.encode(bech32);

    return bech32Address;
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
