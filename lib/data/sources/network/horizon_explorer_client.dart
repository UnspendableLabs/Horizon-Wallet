import 'package:dio/dio.dart';
import 'package:horizon/domain/entities/asset_search_result.dart';

class AssetSrcResponse {
  final String? src;

  AssetSrcResponse({
    this.src,
  });

  factory AssetSrcResponse.fromJson(Map<String, dynamic> json) {
    return AssetSrcResponse(
      src: json['src'],
    );
  }
}

class AssetSearchResultModelHit {
  final String asset;
  final String assetLongname;
  final String description;
  final String issuer;
  final String source;

  AssetSearchResultModelHit({
    required this.asset,
    required this.assetLongname,
    required this.description,
    required this.issuer,
    required this.source,
  });

  factory AssetSearchResultModelHit.fromJson(Map<String, dynamic> json) {
    return AssetSearchResultModelHit(
      asset: json['asset'],
      assetLongname: json['asset_longname'],
      description: json['description'],
      issuer: json['issuer'],
      source: json['source'],
    );
  }
}

class AssetSearchResultModel {
  final String type;
  final String href;
  final AssetSearchResultModelHit hit;

  AssetSearchResultModel(
      {required this.type, required this.href, required this.hit});

  factory AssetSearchResultModel.fromJson(Map<String, dynamic> json) {
    return AssetSearchResultModel(
      type: json['asset'],
      href: json['href'],
      hit: AssetSearchResultModelHit.fromJson(json['hit']),
    );
  }

  AssetSearchResult toEntity() {
    return AssetSearchResult(
      name: hit.asset,
    );
  }
}

class HorizonExplorerApi {
  final Dio _dio;
  HorizonExplorerApi({required Dio dio}) : _dio = dio;

  Future<AssetSrcResponse> getAssetSrc(
      String assetName, String? description, bool? showLarge) async {
    final response = await _dio.get(
        '/explorer/asset-src?asset=$assetName&description=$description&show_large=$showLarge');
    return AssetSrcResponse.fromJson(response.data);
  }

  Future<List<AssetSearchResult>> searchAssets(String query) async {
    final json = await _dio.get("/explorer/search?s=$query");

    List<Map<String, dynamic>> results = json.data['results'];

    return results
        .map((r) => AssetSearchResultModel.fromJson(r))
        .map((a) => a.toEntity())
        .toList();
  }
}
