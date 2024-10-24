import 'package:dio/dio.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

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

class MempoolSpaceApi {
  final Dio _dio;
  final Config _configRepository;

  MempoolSpaceApi({required Dio dio, required Config configRepository})
      : _dio = dio,
        _configRepository = configRepository;

  Future<MempoolSpaceFeesRecommendedResponse> getFeeEstimates() async {
    String url = switch (_configRepository.network) {
      Network.mainnet => 'https://mempool.space/api/v1/fees/recommended',
      Network.testnet => 'https://mempool.space/api/v1/fees/recommended',
      Network.regtest => throw UnsupportedError(
          'MempoolSpace.getFeeEstimates not supported on regtest network.')
    };

    final response = await _dio.get(url);
    return MempoolSpaceFeesRecommendedResponse.fromJson(response.data);
  }
}
