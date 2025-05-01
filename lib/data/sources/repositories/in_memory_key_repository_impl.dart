import 'dart:convert';
import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';

class InMemoryKeyRepositoryImpl implements InMemoryKeyRepository {
  final _key = 'DEFAULT_KEY';
  final _mnemonicKey = 'MNEMONIC_DECRYPTION_KEY';
  final _mapKey = 'IMPORTED_KEY_MAP';

  final SecureKVService secureKVService;

  InMemoryKeyRepositoryImpl({required this.secureKVService});

  @override
  Future<String?> get() async {
    print("why are we calln this");
    return await secureKVService.read(key: _key);
  }

  @override
  Future<void> set({required String key}) async {
    return await secureKVService.write(key: _key, value: key);
  }

  @override
  Future<void> setMnemonicKey({required String key}) async {
    print("setting mnemonic key");
    return await secureKVService.write(key: _mnemonicKey, value: key);
  }

  @override
  Future<String?> getMnemonicKey() async {
    print("get mnemonic decryption key called");
    final v = await secureKVService.read(key: _mnemonicKey);
    print("value $v");

    return v;
  }

  @override
  Future<void> setMap({required Map<String, String> map}) async {
    final jsonString = json.encode(map);
    await secureKVService.write(key: _mapKey, value: jsonString);
  }

  @override
  Future<Map<String, String>> getMap() async {
    try {
      final string = await secureKVService.read(key: _mapKey);
      if (string == null) {
        return {};
      }
      final Map<String, dynamic> decoded = json.decode(string);
      return decoded.map((key, value) => MapEntry(key, value as String));
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> delete() async {
    await secureKVService.delete(key: _key);
    await secureKVService.delete(key: _mnemonicKey);
    await secureKVService.delete(key: _mapKey);
  }
}
