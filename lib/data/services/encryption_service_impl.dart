import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:dargon2_flutter/dargon2_flutter.dart';
import 'package:horizon/domain/services/encryption_service.dart';

const String _argon2Prefix = 'A2::';

class EncryptionServiceImpl implements EncryptionService {
  EncryptionServiceImpl() {
    DArgon2Flutter.init();
  }

  final _secureRandom = Random.secure();

  String _generateRandomIV() {
    final randomBytes =
        List<int>.generate(16, (_) => _secureRandom.nextInt(256));
    return base64Encode(randomBytes);
  }

  @override
  Future<String> encrypt(String data, String password) async {
    final iv = IV(base64Decode(_generateRandomIV()));
    final salt = Salt.newSalt();

    final argon2Result = await _hashPasswordWithArgon2(password, salt);
    final key =
        Key(Uint8List.fromList(base64Decode(argon2Result.base64String)));
    final encrypter = Encrypter(AES(key));
    final cipher = encrypter.encrypt(data, iv: iv).base64;
    return '$_argon2Prefix${base64Encode(salt.bytes)}::${argon2Result.encodedString}::${iv.base64}$cipher';
  }

  Future<String> encryptLegacy(String data, String password) async {
    final iv = IV(base64Decode(_generateRandomIV()));
    final key = _generate32ByteKeyFromPassword(password);
    final encrypter = Encrypter(AES(key));
    final cypher = encrypter.encrypt(data, iv: iv).base64;
    return iv.base64 + cypher;
  }

  @override
  Future<String> decrypt(String data, String password) async {
    if (data.startsWith(_argon2Prefix)) {
      return _decryptArgon2(data.substring(_argon2Prefix.length), password);
    } else {
      return _decryptLegacy(data, password);
    }
  }

  Future<String> _decryptLegacy(String data, String password) async {
    final iv = IV(base64Decode(data.substring(0, 24)));
    final key = _generate32ByteKeyFromPassword(password);
    final encrypter = Encrypter(AES(key));
    final cypher = data.substring(24);
    return encrypter.decrypt64(cypher, iv: iv);
  }

  Future<String> _decryptArgon2(String data, String password) async {
    final parts = data.split('::');
    if (parts.length != 3) {
      throw const FormatException('Invalid encrypted data format');
    }
    final saltBase64 = parts[0];
    final encodedHash = parts[1];
    final ivAndCipher = parts[2];
    final salt = Salt(base64Decode(saltBase64));
    final iv = IV(base64Decode(ivAndCipher.substring(0, 24)));
    final cipher = ivAndCipher.substring(24);

    final isValid = await argon2.verifyHashString(password, encodedHash);
    if (!isValid) {
      throw Exception('Invalid password');
    }

    // log a timestamp
    final argon2Result = await _hashPasswordWithArgon2(password, salt);
    final key =
        Key(Uint8List.fromList(base64Decode(argon2Result.base64String)));
    final encrypter = Encrypter(AES(key));
    return encrypter.decrypt64(cipher, iv: iv);
  }

  Key _generate32ByteKeyFromPassword(String password) {
    // Use SHA-256 to generate a 32-byte hash from the password
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return Key(Uint8List.fromList(digest.bytes));
  }

  Future<DArgon2Result> _hashPasswordWithArgon2(
      String password, Salt salt) async {
    // TODO: use different params on mobile
    return await argon2.hashPasswordString(
      password,
      salt: salt,
      iterations: 6,
      memory: 65536, // 64 MB
      parallelism: 4,
      length: 32,
      type: Argon2Type.id,
      version: Argon2Version.V13,
    );
  }
}
