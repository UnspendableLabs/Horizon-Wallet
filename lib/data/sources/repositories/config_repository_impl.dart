import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:pub_semver/pub_semver.dart';

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
  String toString() {
    return '''EnvironmentConfig(
      version: $version,
      versionInfoEndpoint: $versionInfoEndpoint,
      isDatabaseViewerEnabled: $isDatabaseViewerEnabled,
      isAnalyticsEnabled: $isAnalyticsEnabled,
      isWebExtension: $isWebExtension,
      isSentryEnabled: $isSentryEnabled
      sentryDsn: $sentryDsn,
      sentrySampleRate: $sentrySampleRate,
    )''';
  }
}
