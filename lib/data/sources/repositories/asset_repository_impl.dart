import 'package:horizon/domain/entities/asset.dart' as a;
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';

import 'package:dio/dio.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:horizon/data/models/cursor.dart' as cursor_model;
import 'package:horizon/domain/entities/cursor.dart' as cursor_entity;
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/data/sources/network/counterparty_client_factory.dart';

class AssetRepositoryImpl implements AssetRepository {
  final CounterpartyClientFactory _counterpartyClientFactory;

  AssetRepositoryImpl({
    CounterpartyClientFactory? counterpartyClientFactory,
  }) : _counterpartyClientFactory =
            counterpartyClientFactory ?? GetIt.I<CounterpartyClientFactory>();

  @override
  Future<a.Asset> getAssetVerbose(
      {required String assetName, required HttpConfig httpConfig}) async {
    final response = await _counterpartyClientFactory
        .getClient(httpConfig)
        .getAssetVerbose(assetName, Options()..disableRetry = true);

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
      getValidAssetsByOwnerVerbose(
          {required String address,
          cursor_entity.Cursor? cursor,
          int? limit,
          required HttpConfig httpConfig}) async {
    final response = await _counterpartyClientFactory
        .getClient(httpConfig)
        .getValidAssetsByOwnerVerbose(
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
      {required String address, required HttpConfig httpConfig}) async {
    final allAssets = <a.Asset>[];
    cursor_entity.Cursor? cursor;
    bool hasMore = true;

    while (hasMore) {
      final (assets, nextCursor, _) = await getValidAssetsByOwnerVerbose(
          address: address,
          cursor: cursor,
          limit: 1000,
          httpConfig: httpConfig);

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
