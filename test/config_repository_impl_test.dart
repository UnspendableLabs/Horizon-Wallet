import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/data/sources/repositories/config_repository_impl.dart';

void main() {
  test('Sentry defaults are production-safe and low-volume', () {
    final config = ConfigImpl();

    expect(config.sentryEnvironment, 'production');
    expect(config.sentrySampleRate, 0.01);
    expect(config.isSentryEnabled, isFalse);
  });
}
