import 'package:dio/dio.dart';

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
    required Dio dio,
  }) : _dio = dio;

  Future<MempoolSpaceFeesRecommendedResponse> getFeeEstimates() async {
    const url = '/fees/recommended';
    final response = await _dio.get(url);
    return MempoolSpaceFeesRecommendedResponse.fromJson(response.data);
  }

  Future<MempoolSpacePricesResponse> getPrices() async {
    const url = '/prices';
    final response = await _dio.get(url);
    return MempoolSpacePricesResponse.fromJson(response.data);
  }
}
