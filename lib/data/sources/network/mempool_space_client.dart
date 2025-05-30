import 'package:dio/dio.dart';
import 'package:horizon/domain/entities/network.dart';

class MempoolSpaceFeesRecommendedResponse {
  final int fastestFee;
  final int halfHourFee;
  final int hourFee;
  final int economyFee;
  final int minimumFee;
  MempoolSpaceFeesRecommendedResponse({
    required this.fastestFee,
    required this.halfHourFee,
    required this.hourFee,
    required this.economyFee,
    required this.minimumFee,
  });
  factory MempoolSpaceFeesRecommendedResponse.fromJson(
      Map<String, dynamic> json) {
    return MempoolSpaceFeesRecommendedResponse(
      fastestFee: json['fastestFee'] as int,
      halfHourFee: json['halfHourFee'] as int,
      hourFee: json['hourFee'] as int,
      economyFee: json['economyFee'] as int,
      minimumFee: json['minimumFee'] as int,
    );
  }
}

class MempoolSpacePricesResponse {
  final int time;
  final int usd;
  MempoolSpacePricesResponse({
    required this.time,
    required this.usd,
  });
  factory MempoolSpacePricesResponse.fromJson(Map<String, dynamic> json) {
    return MempoolSpacePricesResponse(
      time: json['time'] as int,
      usd: json['USD'] as int,
    );
  }
}

class MempoolSpaceApi {
  final Dio _dio;

  MempoolSpaceApi({
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 3),
            ));

//  TODO: this should be moved into http_config
// NOTE: we don't really care about handling testnet here
//       and in fact it ends up making more sense just to use
//       mainnet values
  Future<MempoolSpaceFeesRecommendedResponse> getFeeEstimates(
      {required Network network}) async {
    String url = switch (network) {
      Network.mainnet => 'https://mempool.space/api/v1/fees/recommended',
      Network.testnet4 => 'https://mempool.space/api/v1/fees/recommended',
    };

    final response = await _dio.get(url);
    return MempoolSpaceFeesRecommendedResponse.fromJson(response.data);
  }

  Future<MempoolSpacePricesResponse> getPrices(
      {required Network network}) async {
    String url = switch (network) {
      Network.mainnet => 'https://mempool.space/api/v1/prices',
      Network.testnet4 => 'https://mempool.space/api/v1/prices',
    };

    final response = await _dio.get(url);
    return MempoolSpacePricesResponse.fromJson(response.data);
  }
}
