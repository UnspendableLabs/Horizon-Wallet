import 'dart:typed_data';

import 'package:uniparty/bitcoin_wallet_utils/legacy_address/hex.dart';

// FILE VENDORED FROM https://github.com/CrystalNetwork/hd_wallet

const alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
final base = BigInt.from(alphabet.length);

String encode(Uint8List input) {
  if (input.isEmpty) {
    return '';
  }

  // Convert Uint8List to BigInt
  var x = BigInt.parse(HEX.encode(input), radix: 16);

  // Create buffer
  var output = StringBuffer();

  // While x > 0
  while (x > BigInt.zero) {
    // (x, remainder) = divide(x, 58)
    var divRem = x ~/ base;
    var remainder = (x - (divRem * base)).toInt();
    x = divRem;

    // output.append(alphabet[remainder])
    output.write(alphabet[remainder]);
  }

  // While number of leading zeros in input is greater than 0
  for (var i = 0; i < input.length; i++) {
    if (input[i] != 0) {
      break;
    }
    // output.append(alphabet[0])
    output.write(alphabet[0]);
  }

  // Return output
  return output.toString().split('').reversed.join();
}
