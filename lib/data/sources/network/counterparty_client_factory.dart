import 'package:dio/dio.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/http_config.dart';

class CounterpartyClientFactory {
  final Map<String, V2Api> _cache = {};

  V2Api getClient(HttpConfig config) {
    final key = _cacheKey(config);

    return _cache.putIfAbsent(
        key,
        () => V2Api(
              Dio(
                BaseOptions(
                  baseUrl: config.counterparty,
                  headers: {
                    'Content-Type': 'application/json',
                  },
                  connectTimeout: const Duration(seconds: 5),
                  receiveTimeout: const Duration(seconds: 3),
                ),
              ),
            ));
  }

  void clear() => _cache.clear();

  String _cacheKey(HttpConfig config) =>
      '${config.runtimeType}:${config.counterparty}';
}
