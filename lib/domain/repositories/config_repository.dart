import 'package:pub_semver/pub_semver.dart';

enum Network { mainnet, testnet, regtest }

abstract class Config {
  Version get version;
  Network get network;
  String get counterpartyApiBase;
  String get counterpartyApiUsername;
  String get counterpartyApiPassword;
  String get esploraBase;
  // String get blockCypherBase;
  String get horizonExplorerBase;
  String get btcExplorerBase;
  bool get isDatabaseViewerEnabled;
  bool get isAnalyticsEnabled;
  bool get isWebExtension;
}
