import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:uniparty/bitcoin_wallet_utils/legacy_address/base58.dart' as base58;
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/create_address_payload.dart';

// Bitcoin-based address vendored from https://github.com/CrystalNetwork/hd_wallet

String deriveLegacyAddress(CreateAddressPayload args) {
  return btcAddress(args.publicKeyIntList, _getVersion(args.network));
}

_getVersion(NetworkEnum network) {
  switch (network) {
    case NetworkEnum.testnet:
      return 0x6F;
    case NetworkEnum.mainnet:
      return 0x00;
  }
}

final one = Uint8List.fromList([1]);
final zero = Uint8List.fromList([0]);

// RIPEMD-160
Uint8List _ripemd160(Uint8List buffer) {
  return RIPEMD160Digest().process(buffer);
}

// sha256
Uint8List _sha256(Uint8List buffer) {
  return SHA256Digest().process(buffer);
}

// Bitcoin-based address
String btcAddress(Uint8List pubk, int version) {
  final sha256Hash = _sha256(pubk);
  final ripemd160Hash = _ripemd160(sha256Hash);
  final versionByte = Uint8List.fromList([version]);
  final versionedHash = Uint8List.fromList([...versionByte, ...ripemd160Hash]);
  final sha256Hash2 = _sha256(versionedHash);
  final checksum = _sha256(sha256Hash2).sublist(0, 4);
  final checksumed = Uint8List.fromList([...versionedHash, ...checksum]);
  final address = base58.encode(checksumed);
  return address;
}
