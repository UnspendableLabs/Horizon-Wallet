import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:horizon/domain/services/secure_kv_service.dart';

class SecureKVServiceImpl implements SecureKVService {
  final storage = const FlutterSecureStorage();

  @override
  Future<void> write({required String key, required String value }) async {
    await storage.write(key: key, value: value);
  }

  @override
  Future<String?> read({ required String key }) async {
    return await storage.read(key: key);
  }

  @override
  Future<void> delete({ required String key }) async {
    await storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await storage.deleteAll();
  }
}
