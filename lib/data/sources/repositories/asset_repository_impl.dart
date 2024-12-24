import 'package:horizon/domain/entities/asset.dart' as a;
import 'package:horizon/domain/repositories/asset_repository.dart';

import 'package:dio/dio.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:horizon/data/models/cursor.dart' as cursor_model;
import 'package:horizon/domain/entities/cursor.dart' as cursor_entity;

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
  Future<(List<a.Asset>, cursor_entity.Cursor? nextCursor, int? resultCount)>
      getValidAssetsByOwnerVerbose({
    required String address,
    cursor_entity.Cursor? cursor,
    int? limit,
  }) async {
    final response = await api.getValidAssetsByOwnerVerbose(
      address,
      cursor_model.CursorMapper.toData(cursor),
      limit,
    );

    if (response.error != null) {
      throw Exception('Error getting assets by owner: ${response.error}');
    }

    cursor_entity.Cursor? nextCursor =
        cursor_model.CursorMapper.toDomain(response.nextCursor);

    final assets = response.result!
        .map((asset) => a.Asset(
              asset: asset.asset,
              assetLongname: asset.assetLongname,
              divisible: asset.divisible,
              description: asset.description,
              locked: asset.locked,
              issuer: asset.issuer,
              owner: asset.owner,
              supply: asset.supply,
              supplyNormalized: asset.supplyNormalized,
            ))
        .toList();

    return (assets, nextCursor, response.resultCount);
  }

  @override
  Future<List<a.Asset>> getAllValidAssetsByOwnerVerbose(
    String address,
  ) async {
    final allAssets = <a.Asset>[];
    cursor_entity.Cursor? cursor;
    bool hasMore = true;

    while (hasMore) {
      final (assets, nextCursor, _) = await getValidAssetsByOwnerVerbose(
        address: address,
        cursor: cursor,
        limit: 1000,
      );

      allAssets.addAll(assets);

      if (nextCursor == null) {
        hasMore = false;
      } else {
        cursor = nextCursor;
      }
    }

    return allAssets;
  }
}
