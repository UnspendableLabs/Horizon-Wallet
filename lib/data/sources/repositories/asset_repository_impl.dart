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
        divisible: asset.divisible);
  }
}
