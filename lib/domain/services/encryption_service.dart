
import "package:fpdart/fpdart.dart";

abstract class EncryptionService {
  Future<String> encrypt(String data, String password);
  Future<String> decrypt(String data, String password);
  Future<String> getDecryptionKey(String data, String password);
  Future<String> decryptWithKey(String data, String key);
  TaskEither<String, String> decryptWithKeyT(String data, String key);
}
