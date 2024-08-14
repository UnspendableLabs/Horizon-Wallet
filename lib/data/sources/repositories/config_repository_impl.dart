import 'package:horizon/domain/repositories/config_repository.dart';

class EnvironmentConfig implements Config {
  @override
  Network get network {
    // default to testnet for now
    final networkString =
        const String.fromEnvironment('NETWORK', defaultValue: 'testnet');
    return switch (networkString.toLowerCase()) {
      'testnet' => Network.testnet,
      'regtest' => Network.regtest,
      'mainnet' => Network.mainnet,
      _ => throw Exception('Unknown network: $networkString'),
    };
  }

  @override
  String get counterpartyApiBase => switch (network) {
        Network.mainnet => 'https://api.counterparty.io:4000/v2',
        Network.testnet => 'https://api.counterparty.io:14000/v2',
        Network.regtest => 'http://localhost:24000/v2'
      };

  @override
  String get esploraBase => switch (network) {
        Network.mainnet => "https://blockstream.info/api/",
        Network.testnet => "https://blockstream.info/testnet/api/",
        Network.regtest => "http://127.0.0.1:3002",
      };

  @override
  String toString() {
    return 'EnvironmentConfig(network: $network, counterpartyApiBase: $counterpartyApiBase, esploraBase: $esploraBase)';
  }
}
