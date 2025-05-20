
import 'package:fpdart/fpdart.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';

// TODO: this is a smell, we shouldn't be referencing data
// domain directly here.  we need an abstract client

abstract class BalanceRepository {
  Future<List<Balance>> getBalancesForAddress({
    required HttpConfig httpConfig,
    required String address,
    bool? excludeUtxoAttached,
  });

  Future<List<MultiAddressBalance>> getBalancesForAddresses({
    required HttpConfig httpConfig,
    required List<String> addresses,
  });

  Future<MultiAddressBalance> getBalancesForAddressesAndAsset({
    required HttpConfig httpConfig,
    required List<String> addresses,
    required String assetName,
    BalanceType? type,
  });

  Future<List<Balance>> getBalancesForAddressAndAssetVerbose({
    required HttpConfig httpConfig,
    required String address,
    required String assetName,
  });

  Future<List<Balance>> getBalancesForUTXO({
    required HttpConfig httpConfig,
    required String utxo,
  });
}

extension BalanceRepositoryX on BalanceRepository {
  TaskEither<E, List<Balance>> getBalancesForAddressT<E>({
    required HttpConfig httpConfig,
    required String address,
    bool? excludeUtxoAttached,
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => getBalancesForAddress(
        httpConfig: httpConfig,
        address: address,
        excludeUtxoAttached: excludeUtxoAttached,
      ),
      onError,
    );
  }

  TaskEither<E, List<MultiAddressBalance>> getBalancesForAddressesT<E>({
    required HttpConfig httpConfig,
    required List<String> addresses,
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => getBalancesForAddresses(
        httpConfig: httpConfig,
        addresses: addresses,
      ),
      onError,
    );
  }

  TaskEither<E, MultiAddressBalance> getBalancesForAddressesAndAssetT<E>({
    required HttpConfig httpConfig,
    required List<String> addresses,
    required String assetName,
    BalanceType? type,
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => getBalancesForAddressesAndAsset(
        httpConfig: httpConfig,
        addresses: addresses,
        assetName: assetName,
        type: type,
      ),
      onError,
    );
  }

  TaskEither<E, List<Balance>> getBalancesForAddressAndAssetVerboseT<E>({
    required HttpConfig httpConfig,
    required String address,
    required String assetName,
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => getBalancesForAddressAndAssetVerbose(
        httpConfig: httpConfig,
        address: address,
        assetName: assetName,
      ),
      onError,
    );
  }

  TaskEither<E, List<Balance>> getBalancesForUTXOT<E>({
    required HttpConfig httpConfig,
    required String utxo,
    required E Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => getBalancesForUTXO(
        httpConfig: httpConfig,
        utxo: utxo,
      ),
      onError,
    );
  }
}
