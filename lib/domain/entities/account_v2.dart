import 'dart:convert';
import 'package:crypto/crypto.dart';

class AccountV2 {
  // final String uuid;
  final String walletConfigID;
  final int index;
  AccountV2({
    required this.walletConfigID,
    required this.index,
  });

  String get name => "account ${index + 1}";

  // TODO: this is a little awkward here
  String get hash {
    final input = jsonEncode({
      'walletConfigID': walletConfigID,
      'index': index,
    });
    return sha256.convert(utf8.encode(input)).toString();
  }
}
