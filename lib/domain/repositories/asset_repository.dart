import "package:horizon/domain/entities/asset.dart";
import "package:horizon/domain/entities/cursor.dart";
import 'package:horizon/domain/entities/http_config.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/network_error.dart';

abstract class AssetRepository {
  TaskEither<NetworkError, Asset> getAssetVerbose(
      {required String assetName, required HttpConfig httpConfig});

  TaskEither<NetworkError, (List<Asset>, Cursor? nextCursor, int? resultCount)>
      getValidAssetsByOwnerVerbose({
    required String address,
    Cursor? cursor,
    int? limit,
    required HttpConfig httpConfig,
  });

  TaskEither<NetworkError, List<Asset>> getAllValidAssetsByOwnerVerbose({
    required String address,
    required HttpConfig httpConfig,
  });
}
