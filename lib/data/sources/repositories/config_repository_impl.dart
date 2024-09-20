import 'package:horizon/domain/repositories/config_repository.dart';

class EnvironmentConfig implements Config {
  @override
  Network get network {
    // default to testnet for now
    const networkString =
        String.fromEnvironment('NETWORK', defaultValue: 'mainnet');
    return switch (networkString.toLowerCase()) {
      'testnet' => Network.testnet,
      'regtest' => Network.regtest,
      'mainnet' => Network.mainnet,
      _ => throw Exception('Unknown network: $networkString'),
    };
  }

  @override
  String get counterpartyApiBase => switch (network) {
        Network.mainnet => 'https://dev.counterparty.io:4000/v2',
        Network.testnet => 'https://dev.counterparty.io:14000/v2',
        Network.regtest => 'http://localhost:24000/v2'
      };

  @override
  String get esploraBase => switch (network) {
        Network.mainnet => "https://blockstream.info/api",
        Network.testnet => "https://blockstream.info/testnet/api",
        Network.regtest => "http://127.0.0.1:3002/api",
      };

  @override
  String get horizonExplorerBase => switch (network) {
        Network.mainnet => "https://explorer.unspendablelabs.com",
        Network.testnet => "https://testnet-explorer.unspendablelabs.com",
        Network.regtest => "http://127.0.0.1:3000",
      };

  // @override
  // String get blockCypherBase => switch (network) {
  //       Network.mainnet => "https://api.blockcypher.com/v1/btc/main",
  //       Network.testnet => "https://api.blockcypher.com/v1/btc/test3",
  //       Network.regtest => throw UnimplementedError()
  //     };

  @override
  String get btcExplorerBase => switch (network) {
        Network.mainnet => "https://mempool.space",
        Network.testnet => "https://mempool.space/testnet",
        Network.regtest => "http://127.0.0.1:3000",
      };

  @override
  bool get isDatabaseViewerEnabled {
    return const bool.fromEnvironment('ENABLE_DB_VIEWER', defaultValue: false);
  }

  @override
  String toString() {
    return 'EnvironmentConfig(network: $network, counterpartyApiBase: $counterpartyApiBase, esploraBase: $esploraBase)';
  }
}
