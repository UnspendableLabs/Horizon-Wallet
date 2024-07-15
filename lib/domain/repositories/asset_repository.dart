import "package:horizon/domain/entities/asset.dart";

abstract class AssetRepository {
  Future<Asset?> getAsset(String uuid);
}
