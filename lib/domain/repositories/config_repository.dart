enum Network { mainnet, testnet, regtest }

abstract class Config {
  Network get network;
  String get counterpartyApiBase;
  String get esploraBase;
  // String get blockCypherBase;
  String get horizonExplorerBase;
  String get btcExplorerBase;
  bool get isDatabaseViewerEnabled;
  bool get isAnalyticsEnabled;
}
