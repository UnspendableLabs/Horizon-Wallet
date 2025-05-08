export "package:horizon/domain/entities/network.dart";

enum SettingsKeys {
  requiredPasswordForCryptoOperations,
  inactivityTimeout,
  lostFocusTimeout,
  walletConfigID
}

abstract class SettingsRepository {
  bool get requirePasswordForCryptoOperations;
  int get inactivityTimeout;
  int get lostFocusTimeout;

  String? get walletConfigID;
  Future<void> setWalletConfigID(String value);
}
