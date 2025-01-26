import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';

class InMemoryKeyRepositoryImpl implements InMemoryKeyRepository {
  final _key = 'DEFAULT_KEY';

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
  Future<void> delete() async {
    return await secureKVService.delete(key: _key);
  }
}
