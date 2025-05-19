import "package:fpdart/fpdart.dart";

abstract class EncryptionService {
  Future<String> encrypt(String data, String password);
  Future<String> decrypt(String data, String password);
  Future<String> getDecryptionKey(String data, String password);
  Future<String> decryptWithKey(String data, String key);
}

extension EncryptionServiceX on EncryptionService {
  TaskEither<String, String> encryptT({
    required String data,
    required String password,
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => encrypt(data, password),
      onError,
    );
  }

  TaskEither<String, String> decryptT({
    required String data,
    required String password,
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => decrypt(data, password),
      onError,
    );
  }

  TaskEither<String, String> getDecryptionKeyT({
    required String data,
    required String password,
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => getDecryptionKey(data, password),
      onError,
    );
  }

  TaskEither<String, String> decryptWithKeyT({
    required String data,
    required String key,
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => decryptWithKey(data, key),
      onError,
    );
  }
}
