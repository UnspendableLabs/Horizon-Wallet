import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// TODO
class SecureStorage {
  static const _storage = FlutterSecureStorage();

  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll(
        iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions(),
      );
      // _readAll();
    } catch (e) {
      // ERROR TODO
      print(e);
    }
  }

  Future<String?> readSecureData({required String key}) async {
    String? value;
    try {
      value = (await _storage.read(
        key: key,
        iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions(),
      ));
    } catch (e) {
      print(e);
    }
    return value;
  }

  Future<void> deleteSecureData(String key) async {
    try {
      await _storage.delete(
        key: key,
        iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions(),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> writeSecureData({required String key, required String value}) async {
    try {
      await _storage.write(
        key: key,
        value: value,
        iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions(),
      );
    } catch (e) {
      print(e);
    }
  }

  IOSOptions _getIOSOptions() => const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      );

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );
}
