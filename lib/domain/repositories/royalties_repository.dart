import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/royalty_by_asset.dart';
import "package:fpdart/fpdart.dart";

abstract class RoyaltiesRepository {
  Future<RoyaltyByAsset?> getByAsset(
      {required String assetName, required HttpConfig httpConfig});
}

extension RoyaltiesRepositoryX on RoyaltiesRepository {
  TaskEither<String, Option<RoyaltyByAsset>> getByAssetT({
    required String assetName,
    required HttpConfig httpConfig,
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
            () => getByAsset(assetName: assetName, httpConfig: httpConfig),
            onError)
        .map(Option.fromNullable);
  }
}
