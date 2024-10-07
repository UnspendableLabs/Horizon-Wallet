import "package:horizon/domain/entities/asset.dart";

abstract class AssetRepository {
  Future<AssetVerbose> getAssetVerbose(String uuid);
  Future<List<AssetVerbose>> getValidAssetsByOwnerVerbose(String address);
}
