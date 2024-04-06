import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uniparty/models/wallet_retrieve_info.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  Future<void> writeWalletRetrieveInfo(WalletRetrieveInfo model) async {
    await _storage.write(key: 'wallet_info', value: WalletRetrieveInfo.serialize(model));
  }

  Future<WalletRetrieveInfo?> readWalletRetrieveInfo() async {
    String? walletInfo = await _storage.read(key: 'wallet_info');
    if (walletInfo == null) {
      return null;
    }
    WalletRetrieveInfo model = WalletRetrieveInfo.deserialize(walletInfo);
    return model;
  }

  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll(
        iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions(),
      );
      // _readAll();
    } catch (e) {
      print(e);
    }
  }

  Future<String?> readSecureData(String key) async {
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

  Future<void> writeSecureData(String key, String value) async {
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
