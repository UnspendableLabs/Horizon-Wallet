import "package:horizon/domain/entities/wallet_config.dart";
import "package:horizon/domain/entities/network.dart";
import "package:horizon/domain/entities/base_path.dart";
import "package:horizon/domain/entities/seed_derivation.dart";
import "package:fpdart/fpdart.dart";

abstract class WalletConfigRepository {
  Future<List<WalletConfig>> getAll();
  Future<WalletConfig> getCurrent();
  Future<Option<WalletConfig>> getByID({required String id});
  Future<int> create(WalletConfig walletConfig);
  Future<bool> update(WalletConfig walletConfig);
  Future<WalletConfig> createOrUpdate(WalletConfig config);
  Future<WalletConfig> findOrCreate(
      {required BasePath basePath,
      required Network network,
      required SeedDerivation seedDerivation});
}

extension WalletConfigRepositoryX on WalletConfigRepository {
  TaskEither<String, List<WalletConfig>> getAllT(
      String Function(Object error) onError) {
    return TaskEither.tryCatch(
      () => getAll(),
      (e, _) => onError(e),
    );
  }

  TaskEither<String, WalletConfig> getCurrentT(
      String Function(Object error) onError) {
    return TaskEither.tryCatch(
      () => getCurrent(),
      (e, _) => onError(e),
    );
  }

  TaskEither<String, Option<WalletConfig>> getByIDT({
    required String id,
    required String Function(Object error) onError,
  }) {
    return TaskEither.tryCatch(
      () => getByID(id: id),
      (e, _) => onError(e),
    );
  }

  TaskEither<String, int> createT(
      WalletConfig config, String Function(Object error) onError) {
    return TaskEither.tryCatch(
      () => create(config),
      (e, _) => onError(e),
    );
  }

  TaskEither<String, bool> updateT(
      WalletConfig config, String Function(Object error) onError) {
    return TaskEither.tryCatch(
      () => update(config),
      (e, _) => onError(e),
    );
  }

  TaskEither<String, WalletConfig> createOrUpdateT(
      WalletConfig config, String Function(Object error) onError) {
    return TaskEither.tryCatch(
      () => createOrUpdate(config),
      (e, _) => onError(e),
    );
  }

  TaskEither<String, WalletConfig> findOrCreateT({
    required BasePath basePath,
    required Network network,
    required SeedDerivation seedDerivation,
    required String Function(Object error) onError,
  }) {
    return TaskEither.tryCatch(
      () => findOrCreate(
        basePath: basePath,
        network: network,
        seedDerivation: seedDerivation,
      ),
      (e, _) => onError(e),
    );
  }
}
