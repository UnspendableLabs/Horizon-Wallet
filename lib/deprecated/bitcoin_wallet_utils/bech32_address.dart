import 'dart:typed_data';

import 'package:horizon/common/constants.dart';

Uint8List publicKeyToWords(Uint8List data) {
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

  return Uint8List.fromList(bits5Array);
}

bech32PrefixForNetwork(NetworkEnum network) {
  // source:  https://bitcoin.stackexchange.com/questions/70507/how-to-create-a-bech32-address-from-a-public-key
  switch (network) {
    case NetworkEnum.testnet:
      return 'tb';
    case NetworkEnum.mainnet:
      return 'bc';
  }
}
