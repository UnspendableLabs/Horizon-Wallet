
abstract class EncryptionService {
  Future<String> encrypt(String data, String password);
  Future<String> decrypt(String data, String password);
}
