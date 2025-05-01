import "package:fpdart/fpdart.dart";

abstract class MnemonicRepository {
  Future<Option<String>> get();
  Future<void> set({required String encryptedMnemonic});
  Future<void> delete();
}
