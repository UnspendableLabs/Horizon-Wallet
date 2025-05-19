import "package:fpdart/fpdart.dart";

abstract class MnemonicRepository {
  Future<Option<String>> get();
  Future<void> set({required String encryptedMnemonic});
  Future<void> delete();
}

extension MnemonicRepositoryX on MnemonicRepository {
  TaskEither<E, Option<String>> getT<E>({
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => get(),
      onError,
    );
  }

  TaskEither<String, Unit> setT({
    required String encryptedMnemonic,
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () async {
        await set(encryptedMnemonic: encryptedMnemonic);
        return unit;
      },
      onError,
    );
  }

  TaskEither<String, Unit> deleteT({
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () async {
        await delete();
        return unit;
      },
      onError,
    );
  }
}
