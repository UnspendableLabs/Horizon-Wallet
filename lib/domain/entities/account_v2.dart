import 'dart:convert';
import 'package:crypto/crypto.dart';
import "package:horizon/domain/entities/network.dart";

sealed class AccountV2 {
  String get name;
  String get hash;

  bool get isImportedWif => this is ImportedWIF;
  bool get isBip32 => this is Bip32;
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

  @override
  String toString() {
    return 'Bip32(walletConfigID: $walletConfigID, index: $index)';
  }

  Bip32 copyWith({
    String? walletConfigID,
    int? index,
  }) {
    return Bip32(
      walletConfigID: walletConfigID ?? this.walletConfigID,
      index: index ?? this.index,
    );
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

  @override
  toString() {
    return 'ImportedWIF(network: $network, address: $address, encryptedWIF: $encryptedWIF)';
  }
}
