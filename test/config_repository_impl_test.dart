import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/data/sources/repositories/config_repository_impl.dart';

void main() {
  test('Sentry defaults are production-safe and low-volume', () {
    final config = ConfigImpl();

    expect(config.sentrySampleRate, 0.01);
    expect(config.isSentryEnabled, isFalse);
  });

  test('non-release builds are never tagged as a shipping environment', () {
    final config = ConfigImpl();

    // The suite runs in debug mode, which is exactly the case the environment
    // tag and the enablement gate have to keep out of Sentry: a stray
    // HORIZON_SENTRY_ENABLED=true must not start reporting, and the events it
    // would produce must not claim to come from production.
    expect(kReleaseMode, isFalse);
    expect(config.sentryEnvironment, 'development');
    expect(config.isSentryEnabled, isFalse);
  });
}
