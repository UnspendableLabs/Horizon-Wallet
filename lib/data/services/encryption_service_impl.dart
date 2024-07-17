import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:horizon/domain/services/encryption_service.dart';

class EncryptionServiceImpl implements EncryptionService {
  EncryptionServiceImpl();

  final _secureRandom = Random.secure();

  String _generateRandomIV() {
    final randomBytes =
        List<int>.generate(16, (_) => _secureRandom.nextInt(256));
    return base64Encode(randomBytes);
  }

  @override
  Future<String> encrypt(String data, String password) async {
    final iv = IV(base64Decode(_generateRandomIV()));
    final key = _generate32ByteKeyFromPassword(password);
    final encrypter = Encrypter(AES(key));
    final cypher = encrypter.encrypt(data, iv: iv).base64;
    return iv.base64 + cypher;
  }

  @override
  Future<String> decrypt(String data, String password) async {
    final iv = IV(base64Decode(data.substring(0, 24)));
    final key = _generate32ByteKeyFromPassword(password);
    final encrypter = Encrypter(AES(key));
    final cypher = data.substring(24);
    return encrypter.decrypt64(cypher, iv: iv);
  }

  Key _generate32ByteKeyFromPassword(String password) {
    // Use SHA-256 to generate a 32-byte hash from the password
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return Key(Uint8List.fromList(digest.bytes));
  }
}
