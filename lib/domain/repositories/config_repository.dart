enum Network { mainnet, testnet, regtest }

abstract class Config {
  Network get network;
  String get counterpartyApiBase;
  String get esploraBase;
}
