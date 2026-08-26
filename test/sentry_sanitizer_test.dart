import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/core/logging/sentry_sanitizer.dart';

void main() {
  group('sanitizeTelemetryText', () {
    test('redacts legacy and segwit Bitcoin addresses', () {
      const legacy = '1BoatSLRHtKNngkdXEeobR76b53LETtpyT';
      const segwit = 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh';

      final result = sanitizeTelemetryText(
        'GET /address/$legacy?change=$segwit',
      );

      expect(result, isNot(contains(legacy)));
      expect(result, isNot(contains(segwit)));
      expect(
        result,
        'GET /address/$redactedWalletAddress?change=$redactedWalletAddress',
      );
    });

    test('leaves transaction hashes and ordinary text intact', () {
      const value =
          'GET /tx/4d3f43a4e365968b2cbbf64347b62564928cf4b590cb9f14d5c01710c86c33a5';

      expect(sanitizeTelemetryText(value), value);
    });
  });

  test('recursively sanitizes breadcrumb context', () {
    const address = 'tb1qfmw0p58g4w7m9s3e7nqlk0c4xv2z8r6t5y3u2i';

    final result =
        sanitizeTelemetryValue({
              'url': 'https://example.test/address/$address',
              'addresses': [address],
            })
            as Map;

    expect(result['url'], isNot(contains(address)));
    expect(result['addresses'], [redactedWalletAddress]);
  });
}
