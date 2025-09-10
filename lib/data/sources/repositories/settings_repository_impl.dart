import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  @override
  bool get requirePasswordForCryptoOperations =>
      Settings.getValue<bool>(
          SettingsKeys.requiredPasswordForCryptoOperations.toString()) ??
      false;

  @override
  int get inactivityTimeout =>
      Settings.getValue<int>(SettingsKeys.inactivityTimeout.toString()) ?? 5;

  @override
  int get lostFocusTimeout =>
      Settings.getValue<int>(SettingsKeys.lostFocusTimeout.toString()) ?? 1;

  @override
  Future<String> getStableID() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('analytics_id');
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString('analytics_id', id);
    }
    return id;
  }
}
