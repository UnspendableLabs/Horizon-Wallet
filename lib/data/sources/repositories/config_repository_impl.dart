import 'package:flutter/foundation.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:pub_semver/pub_semver.dart';

class ConfigImpl implements Config {
  @override
  Version get version => Version.parse('2.3.1');

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
  String get sentryEnvironment {
    const envValue = String.fromEnvironment('HORIZON_SENTRY_ENVIRONMENT');
    if (envValue.isNotEmpty) {
      return envValue;
    }
    if (!kReleaseMode) {
      return 'development';
    }
    return isWebExtension ? 'extension' : 'production';
  }

  @override
  double get sentrySampleRate {
    const envValue = String.fromEnvironment('HORIZON_SENTRY_SAMPLE_RATE');
    return envValue.isNotEmpty ? double.parse(envValue) : 0.01;
  }

  @override
  bool get isSentryEnabled {
    const configured =
        bool.fromEnvironment('HORIZON_SENTRY_ENABLED', defaultValue: false);
    // Only release builds report. Gating on `sentryEnvironment` instead would
    // be vacuous — it defaults to a shipping value — and would silently drop
    // any deliberate environment such as `staging`.
    return configured && kReleaseMode;
  }

  @override
  int get defaultEnvelopeSize {
    const envValue = String.fromEnvironment('HORIZON_DEFAULT_ENVELOPE_SIZE');
    return envValue.isNotEmpty ? int.parse(envValue) : 546;
  }

  @override
  bool get mpmaEnabled {
    return const bool.fromEnvironment('HORIZON_MPMA_ENABLED',
        defaultValue: false);
  }
}
