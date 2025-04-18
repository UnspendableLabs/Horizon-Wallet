import 'dart:async';
import 'package:horizon/domain/services/encryption_service.dart';

class EncryptionServiceNative implements EncryptionService {
  EncryptionServiceNative();

  @override
  Future<String> encrypt(String data, String password) async {
    return data;
  }

  @override
  Future<String> decrypt(String data_, String password) async {
    return data_;
  }

  @override
  Future<String> decryptWithKey(String data_, String keyB64) async {
    return data_;
  }

  @override
  Future<String> getDecryptionKey(String data_, String password) async {
    return data_;
  }
}

EncryptionService createEncryptionServiceImpl() => EncryptionServiceNative();
