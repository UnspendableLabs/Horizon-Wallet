import 'package:horizon/domain/entities/asset.dart' as a;
import 'package:horizon/domain/repositories/asset_repository.dart';

import 'package:horizon/data/sources/network/api/v2_api.dart';

class AssetRepositoryImpl implements AssetRepository {
  final V2Api api;
  AssetRepositoryImpl({required this.api});
  @override
  Future<a.Asset?> getAsset(String uuid) async {
    final response = await api.getAsset(uuid);

    if (response.result == null) {
      return null;
    }

    final asset = response.result!;

    return a.Asset(
        asset: asset.asset,
        assetLongname: asset.assetLongname,
        divisible: asset.divisible,
        issuer: asset.issuer,
        owner: asset.owner,
        supply: asset.supply);
  }

  @override
  Future<List<a.Asset>> getValidAssetsByIssuer(String address) async {
    final response = await api.getValidAssetsByIssuer(address);

    if (response.result == null) {
      return [];
    }

    final assets = response.result!;

    return assets
        .map((e) => a.Asset(
            asset: e.asset,
            assetLongname: e.assetLongname,
            divisible: e.divisible,
            issuer: e.issuer,
            owner: e.owner,
            supply: e.supply))
        .toList();
  }
}
