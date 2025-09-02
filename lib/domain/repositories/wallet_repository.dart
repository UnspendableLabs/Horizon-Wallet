import 'package:horizon/domain/entities/wallet.dart' as entity;
import "package:fpdart/fpdart.dart";

abstract class WalletRepositoryDeprecated {
  Future<entity.Wallet?> getWallet(String uuid);
  Future<void> insert(entity.Wallet wallet);
  Future<entity.Wallet?> getCurrentWallet();
  Future<void> deleteWallet(entity.Wallet wallet);
  Future<void> deleteAllWallets();
}

extension WalletRepositoryX on WalletRepositoryDeprecated {
  TaskEither<E, entity.Wallet?> getWalletT<E>(
    String uuid, {
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => getWallet(uuid),
      onError,
    );
  }

  TaskEither<String, Unit> insertT({
    required entity.Wallet wallet,
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () async {
        await insert(wallet);
        return unit;
      },
      onError,
    );
  }

  TaskEither<E, entity.Wallet?> getCurrentWalletT<E>({
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => getCurrentWallet(),
      onError,
    );
  }

  TaskEither<String, Unit> deleteWalletT({
    required entity.Wallet wallet,
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () async {
        await deleteWallet(wallet);
        return unit;
      },
      onError,
    );
  }

  TaskEither<String, Unit> deleteAllWalletsT({
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () async {
        await deleteAllWallets();
        return unit;
      },
      onError,
    );
  }
}
