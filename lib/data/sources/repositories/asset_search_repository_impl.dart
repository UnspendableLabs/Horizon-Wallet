import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/asset_search_result.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/network.dart';
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
      description: object.description,
    );
  }
}

class AssetSearchRepositoryImpl implements AssetSearchRepository {
  final HorizonExplorerClientFactory _horizonExplorerClientFactory;
  final MeiliSearchClient client = MeiliSearchClient(
      const String.fromEnvironment("M_HOST"),
      const String.fromEnvironment("M_KEY"));

  AssetSearchRepositoryImpl({
    HorizonExplorerClientFactory? horizonExplorerClientFactory,
  }) : _horizonExplorerClientFactory = horizonExplorerClientFactory ??
            GetIt.I<HorizonExplorerClientFactory>();

  @override
  Future<List<AssetSearchResult>> search(
      {required HttpConfig httpConfig, required String term}) async {
// {"data":["XCP","A10748947519108282879","A2977114591417842298","A7644917367163002844","A9571979917063295926"]}

    print("is this being called?");
    print(httpConfig);

    if (httpConfig.network.isTestnet4) {
      print("huh?");
      return [
        AssetSearchResult(name: "XCP", description: "Counterparty"),
        AssetSearchResult(
            name: "A10748947519108282879", description: "Test Asset 1"),
        AssetSearchResult(
            name: "A2977114591417842298", description: "Test Asset 2"),
        AssetSearchResult(
            name: "A7644917367163002844", description: "Test Asset 3"),
        AssetSearchResult(
            name: "A9571979917063295926", description: "Test Asset 4"),
      ];
    } else {
       print("it's noite testnt???");

    }

    Searcheable<Map<String, dynamic>> searchResult = await client
        .index('search-index')
        .search(term, const SearchQuery(filter: ["kind = 'asset'"]));

    return searchResult.hits
        .map((e) => MeilisearchResult.fromJson(e).toEntity())
        .toList();
  }
}
