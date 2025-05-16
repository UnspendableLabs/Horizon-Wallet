import 'package:fpdart/fpdart.dart';
import "package:horizon/domain/entities/address_v2.dart";
import "package:horizon/domain/entities/account_v2.dart";

abstract class AddressV2Repository {
  Future<List<AddressV2>> getByAccount(AccountV2 account);
}

extension AddressV2RepositoryX on AddressV2Repository {
  TaskEither<String, List<AddressV2>> getByAccountT({
    required AccountV2 account,
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => getByAccount(account),
      onError,
    );
  }
}
