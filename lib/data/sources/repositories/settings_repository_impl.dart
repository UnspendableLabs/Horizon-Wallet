import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

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
}
