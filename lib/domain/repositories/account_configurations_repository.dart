import "package:horizon/domain/entities/account_configuration.dart";
import 'package:fpdart/fpdart.dart';

abstract class AccountConfigurationsRepository {
  // Future<Option<AccountV2>> getByID(String id);

  Future<int> create(AccountConfiguration account);
  Future<AccountConfiguration> createOrUpdate(AccountConfiguration account);

  Future<AccountConfiguration?> getByPrimaryKey({
    required String walletId,
    required int accountIndex,
  });
}

extension AccountConfigurationsRepositoryX on AccountConfigurationsRepository {
  TaskEither<E, int> createT<E>({
    required AccountConfiguration account,
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => create(account),
      onError,
    );
  }

  TaskEither<E, AccountConfiguration> createOrUpdateT<E>({
    required AccountConfiguration config,
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => createOrUpdate(config),
      onError,
    );
  }

  TaskEither<E, AccountConfiguration?> getByPrimaryKeyT<E>({
    required String walletId,
    required int accountIndex,
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => getByPrimaryKey(
        walletId: walletId,
        accountIndex: accountIndex,
      ),
      onError,
    );
  }
}
