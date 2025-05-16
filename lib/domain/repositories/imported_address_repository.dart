import 'package:fpdart/fpdart.dart';
import "package:horizon/domain/entities/imported_address.dart";

abstract class ImportedAddressRepository {
  Future<ImportedAddress?> getImportedAddress(String address);
  Future<void> insert(ImportedAddress address);
  Future<void> insertMany(List<ImportedAddress> addresses);
  Future<void> deleteAllImportedAddresses();
  Future<List<ImportedAddress>> getAll();
}

extension ImportedAddressRepositoryX on ImportedAddressRepository {
  TaskEither<E, ImportedAddress?> getImportedAddressT<E>({
    required String address,
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => getImportedAddress(address),
      onError,
    );
  }

  TaskEither<E, Unit> insertT<E>({
    required ImportedAddress address,
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(() async {
      await insert(address);
      return unit;
    }, onError);
  }

  TaskEither<E, Unit> insertManyT<E>({
    required List<ImportedAddress> addresses,
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(() async {
      await insertMany(addresses);
      return unit;
    }, onError);
  }

  TaskEither<E, Unit> deleteAllImportedAddressesT<E>({
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(() async {
      await deleteAllImportedAddresses();
      return unit;
    }, onError);
  }

  TaskEither<E, List<ImportedAddress>> getAllT<E>({
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => getAll(),
      onError,
    );
  }
}
