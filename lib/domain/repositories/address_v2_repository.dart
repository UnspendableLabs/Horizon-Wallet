import 'package:fpdart/fpdart.dart';
import "package:horizon/domain/entities/address_v2.dart";
import "package:horizon/domain/entities/account_v2.dart";
import "package:horizon/domain/entities/address_index_set.dart";

class Bip32AddressIndex {
  final int value;
  const Bip32AddressIndex(this.value);
}

abstract class AddressV2Repository {
  Future<AddressIndexSet> getByAccount(AccountV2 account);
  Future<List<AddressV2>> getAllImported();
  Future<AddressIndexSet> getByAccountAtIndex(
      Bip32 account, Bip32AddressIndex index);
}

extension AddressV2RepositoryX on AddressV2Repository {
  TaskEither<String, AddressIndexSet> getByAccountT({
    required AccountV2 account,
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => getByAccount(account),
      onError,
    );
  }

  TaskEither<String, List<AddressV2>> getAllImportedT({
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => getAllImported(),
      onError,
    );
  }

  TaskEither<String, AddressIndexSet> getByAccountAtIndexT({
    required Bip32 account,
    required Bip32AddressIndex index,
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => getByAccountAtIndex(account, index),
      onError,
    );
  }
}
