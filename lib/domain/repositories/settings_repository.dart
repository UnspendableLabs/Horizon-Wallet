
enum SettingsKeys {
  requiredPasswordForCryptoOperations,
  inactivityTimeout,
  lostFocusTimeout,
}

abstract class SettingsRepository {
  bool get requirePasswordForCryptoOperations;
  int get inactivityTimeout;
  int get lostFocusTimeout;
}
