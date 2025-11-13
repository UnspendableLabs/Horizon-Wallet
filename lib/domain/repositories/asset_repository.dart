import "package:horizon/domain/entities/asset.dart";
import "package:horizon/domain/entities/cursor.dart";
import 'package:horizon/domain/entities/http_config.dart';

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
