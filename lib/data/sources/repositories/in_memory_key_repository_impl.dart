import 'dart:convert';
import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';

class InMemoryKeyRepositoryImpl implements InMemoryKeyRepository {
  final _key = 'DEFAULT_KEY';
  final _mapKey = 'IMPORTED_KEY_MAP';

  final SecureKVService secureKVService;

  InMemoryKeyRepositoryImpl({required this.secureKVService});

  @override
  Future<String?> get() async {
    return await secureKVService.read(key: _key);
  }

  @override
  Future<void> set({required String key}) async {
    return await secureKVService.write(key: _key, value: key);
  }

  @override
  Future<void> setMap({required Map<String, String> map}) async {
    final json = map.toString();
    return await secureKVService.write(key: _mapKey, value: json);
  }

  @override
  Future<Map<String, String>> getMap() async {
    try {
      String? string = await secureKVService.read(key: _mapKey);

      return json.decode(string!).map((key, value) {
        return MapEntry(key, value as String);
      });
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> delete() async {
    await secureKVService.delete(key: _key);
    await secureKVService.delete(key: _mapKey);
  }
}
