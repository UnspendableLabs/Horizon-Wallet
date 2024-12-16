import "package:horizon/domain/entities/asset.dart";
import "package:horizon/domain/entities/cursor.dart";

abstract class AssetRepository {
  Future<Asset> getAssetVerbose(String assetName);

  Future<(List<Asset>, Cursor? nextCursor, int? resultCount)>
      getValidAssetsByOwnerVerbose({
    required String address,
    Cursor? cursor,
    int? limit,
  });

  Future<List<Asset>> getAllValidAssetsByOwnerVerbose(String address);
}
