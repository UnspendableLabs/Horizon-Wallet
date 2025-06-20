import "package:horizon/domain/entities/asset.dart";
import "package:horizon/domain/entities/cursor.dart";
import 'package:horizon/domain/entities/http_config.dart';
import 'package:fpdart/fpdart.dart';

abstract class AssetRepository {
  Future<Asset> getAssetVerbose(
      {required String assetName, required HttpConfig httpConfig});

  Future<(List<Asset>, Cursor? nextCursor, int? resultCount)>
      getValidAssetsByOwnerVerbose({
    required String address,
    Cursor? cursor,
    int? limit,
    required HttpConfig httpConfig,
  });

  Future<List<Asset>> getAllValidAssetsByOwnerVerbose({
    required String address,
    required HttpConfig httpConfig,
  });
}

extension AssetRepositoryX on AssetRepository {
  TaskEither<String, Asset> getAssetVerboseT({
    required String assetName,
    required HttpConfig httpConfig,
    String Function(Object error, StackTrace stacktrace)? onError,
  }) {
    return TaskEither.tryCatch(
      () => getAssetVerbose(assetName: assetName, httpConfig: httpConfig),
      (e, stack) => onError?.call(e, stack) ?? e.toString(),
    );
  }

  TaskEither<String, (List<Asset>, Cursor? nextCursor, int? resultCount)>
      getValidAssetsByOwnerVerboseT({
    required String address,
    Cursor? cursor,
    int? limit,
    required HttpConfig httpConfig,
    String Function(Object error, StackTrace stacktrace)? onError,
  }) {
    return TaskEither.tryCatch(
      () => getValidAssetsByOwnerVerbose(
        address: address,
        cursor: cursor,
        limit: limit,
        httpConfig: httpConfig,
      ),
      (e, stack) => onError?.call(e, stack) ?? e.toString(),
    );
  }

  TaskEither<String, List<Asset>> getAllValidAssetsByOwnerVerboseT({
    required String address,
    required HttpConfig httpConfig,
    String Function(Object error, StackTrace stacktrace)? onError,
  }) {
    return TaskEither.tryCatch(
      () => getAllValidAssetsByOwnerVerbose(
        address: address,
        httpConfig: httpConfig,
      ),
      (e, stack) => onError?.call(e, stack) ?? e.toString(),
    );
  }
}
