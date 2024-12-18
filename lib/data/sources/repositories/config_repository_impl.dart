import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:pub_semver/pub_semver.dart';

class ConfigImpl implements Config {
  @override
  Version get version => Version.parse('1.5.0');

  @override
  String get versionInfoEndpoint {
    const envValue = String.fromEnvironment('HORIZON_VERSION_INFO_ENDPOINT');
    return envValue.isNotEmpty
        ? envValue
        : "https://version-service.vercel.app/api";
  }

  @override
  Network get network {
    // default to testnet for now
    const networkString =
        String.fromEnvironment('HORIZON_NETWORK', defaultValue: 'mainnet');
    return switch (networkString.toLowerCase()) {
      'testnet' => Network.testnet,
      'regtest' => Network.regtest,
      'mainnet' => Network.mainnet,
      _ => throw Exception('Unknown network: $networkString'),
    };
  }

  @override
  String get counterpartyApiBase {
    const envValue = String.fromEnvironment('HORIZON_COUNTERPARTY_API_BASE');
    return envValue.isNotEmpty ? envValue : _defaultCounterpartyApiBase;
  }

  String get _defaultCounterpartyApiBase => switch (network) {
        Network.mainnet => 'https://api.unspendablelabs.com:4000/v2',
        Network.testnet => 'https://api.counterparty.io:14000/v2',
        Network.regtest => 'http://localhost:24000/v2'
      };

  @override
  String get counterpartyApiUsername {
    const envValue =
        String.fromEnvironment('HORIZON_COUNTERPARTY_API_USERNAME');
    return envValue.isNotEmpty ? envValue : _defaultCounterpartyApiUsername;
  }

  String get _defaultCounterpartyApiUsername => switch (network) {
        Network.mainnet => '',
        Network.testnet => '',
        Network.regtest => '',
      };

  @override
  String get counterpartyApiPassword {
    const envValue =
        String.fromEnvironment('HORIZON_COUNTERPARTY_API_PASSWORD');
    return envValue.isNotEmpty ? envValue : _defaultCounterpartyApiPassword;
  }

  String get _defaultCounterpartyApiPassword => switch (network) {
        Network.mainnet => '',
        Network.testnet => '',
        Network.regtest => '',
      };

  @override
  String get esploraBase {
    const envValue = String.fromEnvironment('HORIZON_ESPLORA_BASE');
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
    return const bool.fromEnvironment('HORIZON_ENABLE_DB_VIEWER',
        defaultValue: false);
  }

  @override
  bool get isAnalyticsEnabled {
    return const bool.fromEnvironment('HORIZON_ANALYTICS_ENABLED',
        defaultValue: false);
  }

  @override
  bool get isWebExtension {
    return const bool.fromEnvironment('HORIZON_IS_EXTENSION',
        defaultValue: false);
  }

  @override
  String get sentryDsn {
    const envValue = String.fromEnvironment('HORIZON_SENTRY_DSN');
    return envValue.isNotEmpty ? envValue : _defaultSentryDsn;
  }

  String get _defaultSentryDsn => switch (network) {
        Network.mainnet => '',
        Network.testnet => '',
        Network.regtest => '',
      };

  @override
  double get sentrySampleRate {
    const envValue = String.fromEnvironment('HORIZON_SENTRY_SAMPLE_RATE');
    return envValue.isNotEmpty ? double.parse(envValue) : 1.0;
  }

  @override
  bool get isSentryEnabled {
    return const bool.fromEnvironment('HORIZON_SENTRY_ENABLED',
        defaultValue: false);
  }

  @override
  String toString() {
    return '''EnvironmentConfig(
      network: $network,
      counterpartyApiBase: $counterpartyApiBase,
      esploraBase: $esploraBase,
      horizonExplorerBase: $horizonExplorerBase,
      btcExplorerBase: $btcExplorerBase,
      isDatabaseViewerEnabled: $isDatabaseViewerEnabled,
      isSentryEnabled: $isSentryEnabled
    )''';
  }
}
