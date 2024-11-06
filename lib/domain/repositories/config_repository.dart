enum Network { mainnet, testnet, regtest }

abstract class Config {
  Network get network;
  String get counterpartyApiBase;
  String get counterpartyApiUsername;
  String get counterpartyApiPassword;
  String get counterpartyApiBaseV1;
  String get counterpartyV1Username;
  String get counterpartyV1Password;
  String get bitcoinApiBase;
  String get bitcoinUsername;
  String get bitcoinPassword;
  String get esploraBase;
  // String get blockCypherBase;
  String get horizonExplorerBase;
  String get btcExplorerBase;
  bool get isDatabaseViewerEnabled;
  bool get isAnalyticsEnabled;
}
