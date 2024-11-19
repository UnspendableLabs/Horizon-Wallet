import 'package:horizon/domain/entities/asset.dart' as a;
import 'package:horizon/domain/repositories/asset_repository.dart';

import 'package:dio/dio.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

class AssetRepositoryImpl implements AssetRepository {
  final V2Api api;
  AssetRepositoryImpl({required this.api});
  @override
  Future<a.Asset> getAssetVerbose(String assetName) async {
    final response =
        await api.getAssetVerbose(assetName, Options()..disableRetry = true);

    if (response.result == null) {
      throw Exception('Asset not found');
    }

    final asset = response.result!;

    return a.Asset(
        asset: asset.asset,
        assetLongname: asset.assetLongname,
        divisible: asset.divisible,
        issuer: asset.issuer,
        owner: asset.owner,
        locked: asset.locked,
        supply: asset.supply,
        description: asset.description,
        supplyNormalized: asset.supplyNormalized);
  }

  @override
  Future<List<a.Asset>> getValidAssetsByOwnerVerbose(String address) async {
    final response = await api.getValidAssetsByOwnerVerbose(address);

    if (response.result == null) {
      return [];
    }

    final assets = response.result!;

    return assets
        .map((result) => a.Asset(
            asset: result.asset,
            assetLongname: result.assetLongname,
            divisible: result.divisible,
            description: result.description,
            locked: result.locked,
            issuer: result.issuer,
            owner: result.owner,
            supply: result.supply,
            supplyNormalized: result.supplyNormalized))
        .toList();
  }
}
