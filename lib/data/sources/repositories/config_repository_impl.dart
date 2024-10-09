import 'package:horizon/domain/repositories/config_repository.dart';

class ConfigImpl implements Config {
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
  String get counterpartyApiBase {
    const envValue = String.fromEnvironment('COUNTERPARTY_API_BASE');
    return envValue.isNotEmpty ? envValue : _defaultCounterpartyApiBase;
  }

  String get _defaultCounterpartyApiBase => switch (network) {
        Network.mainnet => 'https://api.counterparty.io:4000/v2',
        Network.testnet => 'https://api.counterparty.io:14000/v2',
        Network.regtest => 'http://localhost:24000/v2'
      };

  @override
  String get esploraBase {
    const envValue = String.fromEnvironment('ESPLORA_BASE');
    return envValue.isNotEmpty ? envValue : _defaultEsploraBase;
  }

  String get _defaultEsploraBase => switch (network) {
        Network.mainnet => "https://api.counterparty.io:3000",
        Network.testnet => "https://api.counterparty.io:13000",
        Network.regtest => "http://127.0.0.1:3002",
      };

  @override
  String get horizonExplorerBase => switch (network) {
        Network.mainnet => "https://explorer.unspendablelabs.com",
        Network.testnet => "https://testnet-explorer.unspendablelabs.com",
        Network.regtest => "http://127.0.0.1:3000",
      };

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
  bool get isAnalyticsEnabled {
    return const bool.fromEnvironment('ANALYTICS_ENABLED', defaultValue: false);
  }

  @override
  String toString() {
    return 'EnvironmentConfig(network: $network, counterpartyApiBase: $counterpartyApiBase, esploraBase: $esploraBase, horizonExplorerBase: $horizonExplorerBase, btcExplorerBase: $btcExplorerBase, isDatabaseViewerEnabled: $isDatabaseViewerEnabled)';
  }
}
