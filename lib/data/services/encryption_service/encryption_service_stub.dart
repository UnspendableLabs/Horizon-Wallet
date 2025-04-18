// data/services/encryption_service_stub.dart

import 'package:horizon/domain/services/encryption_service.dart';

class EncryptionServiceStub implements EncryptionService {
  Never _unsupported(String fn) =>
      throw UnimplementedError('$fn is not supported on this platform.');

  @override
  Future<String> encrypt(String data, String password) =>
      Future.error(_unsupported('encrypt'));

  @override
  Future<String> decrypt(String data, String password) =>
      Future.error(_unsupported('decrypt'));

  @override
  Future<String> getDecryptionKey(String data, String password) =>
      Future.error(_unsupported('getDecryptionKey'));

  @override
  Future<String> decryptWithKey(String data, String key) =>
      Future.error(_unsupported('decryptWithKey'));
}

EncryptionService createEncryptionServiceImpl() => EncryptionServiceStub();

