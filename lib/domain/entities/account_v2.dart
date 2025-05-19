import 'dart:convert';
import 'package:crypto/crypto.dart';
import "package:horizon/domain/entities/network.dart";

sealed class AccountV2 {
  String get name;
  String get hash;
}

class Bip32 extends AccountV2 {
  final String walletConfigID;
  final int index;
  Bip32({required this.walletConfigID, required this.index});

  @override
  String get name => "account ${index + 1}";

  @override
  String get hash {
    final input = jsonEncode({
      'walletConfigID': walletConfigID,
      'index': index,
    });
    return sha256.convert(utf8.encode(input)).toString();
  }
}

class ImportedWIF extends AccountV2 {
  final Network network;
  final String address;
  final String encryptedWIF;
  ImportedWIF({
    required this.network,
    required this.address,
    required this.encryptedWIF,
  });

  @override
  String get name => address;

  @override
  String get hash {
    final input = jsonEncode({
      'address': address,
      'network': network.name,
    });
    return sha256.convert(utf8.encode(input)).toString();
  }
}
