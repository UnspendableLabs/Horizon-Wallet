
import 'package:shared_preferences/shared_preferences.dart';
import 'package:horizon/domain/services/kv_service.dart';


class SharedPrefsKVService implements KVService {
  final SharedPreferences _prefs;

  // Private constructor for internal use
  SharedPrefsKVService._(this._prefs);

  /// Factory method for async creation
  static Future<SharedPrefsKVService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefsKVService._(prefs);
  }

  @override
  Future<void> write(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<String?> read(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}

