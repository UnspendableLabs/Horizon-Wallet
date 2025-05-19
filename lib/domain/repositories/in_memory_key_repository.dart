import "package:fpdart/fpdart.dart";

abstract class InMemoryKeyRepository {
  Future<String?> get();
  Future<void> set({required String key});
  Future<void> setMnemonicKey({required String key});
  Future<Option<String>> getMnemonicKey();
  Future<Map<String, String>> getMap();
  Future<void> setMap({required Map<String, String> map});
  Future<void> delete();
}

extension InMemoryKeyRepositoryX on InMemoryKeyRepository {
  TaskEither<String, String?> getT({
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(() => get(), onError);
  }

  TaskEither<String, Unit> setT({
    required String key,
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(() async {
      await set(key: key);
      return unit;
    }, onError);
  }

  TaskEither<String, Unit> setMnemonicKeyT({
    required String key,
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(() async {
      await setMnemonicKey(key: key);
      return unit;
    }, onError);
  }

  TaskEither<String, Option<String>> getMnemonicKeyT({
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(() => getMnemonicKey(), onError);
  }

  TaskEither<String, Map<String, String>> getMapT({
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(() => getMap(), onError);
  }

  TaskEither<String, Unit> setMapT({
    required Map<String, String> map,
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(() async {
      await setMap(map: map);
      return unit;
    }, onError);
  }

  TaskEither<String, Unit> deleteT({
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(() async {
      await delete();
      return unit;
    }, onError);
  }
}
