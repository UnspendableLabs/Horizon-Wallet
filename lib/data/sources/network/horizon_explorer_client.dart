import 'package:dio/dio.dart';

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

class HorizonExplorerApi {
  final Dio _dio;
  HorizonExplorerApi({required Dio dio}) : _dio = dio;

  Future<AssetSrcResponse> getAssetSrc(
      String assetName, String? description, bool? showLarge) async {
    final response = await _dio.get(
        '/asset-src?asset=$assetName&description=$description&show_large=$showLarge');
    return AssetSrcResponse.fromJson(response.data);
  }
}
