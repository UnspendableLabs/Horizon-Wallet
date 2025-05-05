import "package:horizon/domain/entities/network.dart";
export "package:horizon/domain/entities/network.dart";

enum SettingsKeys {
  requiredPasswordForCryptoOperations,
  inactivityTimeout,
  lostFocusTimeout,
  network,
}

abstract class SettingsRepository {
  bool get requirePasswordForCryptoOperations;
  int get inactivityTimeout;
  int get lostFocusTimeout;
  Network get network;
  Future<void> setNetwork(Network value);
}
