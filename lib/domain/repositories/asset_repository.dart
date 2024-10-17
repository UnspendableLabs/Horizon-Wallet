import "package:horizon/domain/entities/asset.dart";

abstract class AssetRepository {
  Future<Asset> getAssetVerbose(String uuid);
  Future<List<Asset>> getValidAssetsByOwnerVerbose(String address);
}
