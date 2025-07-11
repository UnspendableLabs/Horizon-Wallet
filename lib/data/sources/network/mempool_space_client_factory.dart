import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/data/sources/network/mempool_space_client.dart';
import 'package:dio/dio.dart' hide Options;

class MempoolSpaceClientFactory {
  final Map<String, MempoolSpaceApi> _cache = {};

  MempoolSpaceApi getClient(HttpConfig config) {
    final key = _cacheKey(config);

    return _cache.putIfAbsent(
      key,
      () => MempoolSpaceApi(
        dio: Dio(
          BaseOptions(
            baseUrl: config.mempoolSpaceApi,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 3),
          ),
        ),
      ),
    );
  }

  void clear() => _cache.clear();

  String _cacheKey(HttpConfig config) =>
      '${config.runtimeType}:${config.mempoolSpaceApi}';
}
