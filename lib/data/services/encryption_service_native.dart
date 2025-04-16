import 'dart:async';
import 'package:horizon/domain/services/encryption_service.dart';

class EncryptionServiceNative implements EncryptionService {
  EncryptionServiceNative();

  @override
  Future<String> encrypt(String data, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<String> decrypt(String data_, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<String> decryptWithKey(String data_, String keyB64) async {
    throw UnimplementedError();
  }

  @override
  Future<String> getDecryptionKey(String data_, String password) async {
    throw UnimplementedError();
  }
}
