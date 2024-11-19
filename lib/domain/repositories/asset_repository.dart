import "package:horizon/domain/entities/asset.dart";

abstract class AssetRepository {
  Future<Asset> getAssetVerbose(String assetName);
  Future<List<Asset>> getValidAssetsByOwnerVerbose(String address);
}
