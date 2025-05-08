import "package:fpdart/fpdart.dart";

abstract class MnemonicRepository {
  Task<Option<String>> get();
  Future<void> set({required String encryptedMnemonic});
  Future<void> delete();
}
