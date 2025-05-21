import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/asset_search_result.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/asset_search_repository.dart';
import 'package:horizon/data/sources/network/horizon_explorer_client_factory.dart';
import 'package:meilisearch/meilisearch.dart';

class MeilisearchObjectAsset {
  final String asset;
  final String? assetLongname;
  final String description;
  final String issuer;
  final String source;

  MeilisearchObjectAsset({
    required this.asset,
    required this.assetLongname,
    required this.description,
    required this.issuer,
    required this.source,
  });

  factory MeilisearchObjectAsset.fromJson(Map<String, dynamic> json) {
    return MeilisearchObjectAsset(
      asset: json['asset'],
      assetLongname: json['asset_longname'],
      description: json['description'],
      issuer: json['issuer'],
      source: json['source'],
    );
  }
}

class MeilisearchResult {
  final String id;
  final String kind;
  final MeilisearchObjectAsset object;

  MeilisearchResult(
      {required this.kind, required this.id, required this.object});

  factory MeilisearchResult.fromJson(Map<String, dynamic> json) {
    return MeilisearchResult(
      id: json['id'],
      kind: json['kind'],
      object: MeilisearchObjectAsset.fromJson(json['object']),
    );
  }

  AssetSearchResult toEntity() {
    return AssetSearchResult(
      name: object.asset,
    );
  }
}

class AssetSearchRepositoryImpl implements AssetSearchRepository {
  final HorizonExplorerClientFactory _horizonExplorerClientFactory;
  final MeiliSearchClient client = MeiliSearchClient("<HOST>", "SECRET");

  AssetSearchRepositoryImpl({
    HorizonExplorerClientFactory? horizonExplorerClientFactory,
  }) : _horizonExplorerClientFactory = horizonExplorerClientFactory ??
            GetIt.I<HorizonExplorerClientFactory>();

  Future<List<AssetSearchResult>> search(
      {required HttpConfig httpConfig, required String term}) async {
    Searcheable<Map<String, dynamic>> searchResult = await client
        .index('search-index')
        .search(term, SearchQuery(filter: ["kind = 'asset'"]));

    return searchResult.hits
        .map((e) => MeilisearchResult.fromJson(e).toEntity())
        .toList();
  }
}
