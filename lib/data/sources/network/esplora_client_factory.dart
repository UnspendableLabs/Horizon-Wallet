import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/data/sources/network/esplora_client.dart';
import 'package:dio/dio.dart' hide Options;

import 'package:dio/dio.dart';

class EsploraClientFactory {
  final Map<String, EsploraApi> _cache = {};

  EsploraApi getClient(HttpConfig config) {
    final key = _cacheKey(config);

    return _cache.putIfAbsent(
      key,
      () => EsploraApi(
        dio: Dio(
          BaseOptions(
            baseUrl: config.esplora,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 3),
          ),
        ),
      ),
    );
  }

  void clear() => _cache.clear();

  String _cacheKey(HttpConfig config) =>
      '${config.runtimeType}:${config.esplora}';
}
