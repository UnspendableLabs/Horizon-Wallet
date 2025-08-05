import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:fpdart/fpdart.dart';

class ConfigImpl implements Config {
  @override
  Version get version => Version.parse('1.7.7');

  @override
  String get versionInfoEndpoint {
    const envValue = String.fromEnvironment('HORIZON_VERSION_INFO_ENDPOINT');
    return envValue.isNotEmpty
        ? envValue
        : "https://version-service.vercel.app/api";
  }

  @override
  bool get disableNativeOrders {
    return const bool.fromEnvironment('HORIZON_DISABLE_NATIVE_ORDERS',
        defaultValue: true); // TODO: should be changed to false
  }

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

  String get _defaultSentryDsn => "";

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
  int get defaultEnvelopeSize {
    const envValue = String.fromEnvironment('HORIZON_DEFAULT_ENVELOPE_SIZE');
    return envValue.isNotEmpty ? int.parse(envValue) : 546;
  }

  @override
  Option<MeilisearchConfig> get meilisearchConfigMainnet {
    const api = String.fromEnvironment('HORIZON_MEILISEARCH_API_MAINNET');
    const key = String.fromEnvironment('HORIZON_MEILISEARCH_KEY_MAINNET');

    if (api.isEmpty || key.isEmpty) {
      return Option.none();
    }

    return Option.of(MeilisearchConfig(api: api, key: key));
  }

  @override
  Option<MeilisearchConfig> get meilisearchConfigTestnet {
    const api = String.fromEnvironment('HORIZON_MEILISEARCH_API_TESTNET');
    const key = String.fromEnvironment('HORIZON_MEILISEARCH_KEY_TESTNET');

    if (api.isEmpty || key.isEmpty) {
      return Option.none();
    }

    return Option.of(MeilisearchConfig(api: api, key: key));
  }
}
