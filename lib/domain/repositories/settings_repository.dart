import "package:horizon/domain/entities/network.dart";
export "package:horizon/domain/entities/network.dart";
import 'package:horizon/domain/entities/base_path.dart';

enum SettingsKeys {
  requiredPasswordForCryptoOperations,
  inactivityTimeout,
  lostFocusTimeout,
  network,
}

abstract class SettingsRepository {
  BasePath get basePath;
  bool get requirePasswordForCryptoOperations;
  int get inactivityTimeout;
  int get lostFocusTimeout;
  Network get network;
  Future<void> setNetwork(Network value);
}
