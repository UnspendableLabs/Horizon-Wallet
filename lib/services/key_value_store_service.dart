import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class KeyValueService {
  Future<void> set(String key, String value);
  Future<String?> get(String key);
  Future<void> deleteAll();
}

class SharedSettingsKeyValueServiceImpl implements KeyValueService {
  @override
  Future<void> set(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<String?> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

class SecureKeyValueImpl implements KeyValueService {
  static const _storage = FlutterSecureStorage();
  @override
  Future<void> set(String key, String value) async {
    return await _storage.write(
      key: key,
      value: value,
      // iOptions: _getIOSOptions(),
      // aOptions: _getAndroidOptions(),
    );
  }

  @override
  Future<String?> get(String key) async {
    return await _storage.read(
      key: key,
      // iOptions: _getIOSOptions(),
      // aOptions: _getAndroidOptions(),
    );
  }

  @override
  Future<void> deleteAll() async {
    return await _storage.deleteAll(
        // iOptions: _getIOSOptions(),
        // aOptions: _getAndroidOptions(),
        );
  }

  IOSOptions _getIOSOptions() => const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      );

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );
}
