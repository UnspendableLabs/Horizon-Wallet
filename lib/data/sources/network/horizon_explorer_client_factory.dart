import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/data/sources/network/horizon_explorer_client.dart';
import 'package:dio/dio.dart' hide Options;

import 'package:dio/dio.dart';

class HorizonExplorerClientFactory {
  final Map<String, HorizonExplorerApi> _cache = {};

  HorizonExplorerApi getClient(HttpConfig config) {
    final key = _cacheKey(config);

    return _cache.putIfAbsent(
      key,
      () => HorizonExplorerApi(
        Dio(
          BaseOptions(
            baseUrl: config.horizonMarketApi,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ),
      ),
    );
  }

  void clear() => _cache.clear();

  String _cacheKey(HttpConfig config) =>
      '${config.runtimeType}:${config.horizonMarketApi}';
}
