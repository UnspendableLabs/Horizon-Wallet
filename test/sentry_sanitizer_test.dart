import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/core/logging/sentry_sanitizer.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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

    final result = sanitizeTelemetryValue({
      'url': 'https://example.test/address/$address',
      'addresses': [address],
    }) as Map;

    expect(result['url'], isNot(contains(address)));
    expect(result['addresses'], [redactedWalletAddress]);
  });

  test('keeps every entry when two map keys redact to the same placeholder',
      () {
    const first = '1BoatSLRHtKNngkdXEeobR76b53LETtpyT';
    const second = 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh';

    final result = sanitizeTelemetryMap({first: 5, second: 7});

    expect(result.length, 2);
    expect(result.keys, everyElement(contains(redactedWalletAddress)));
    expect(result.values, containsAll([5, 7]));
  });

  group('sanitizeSentryEvent', () {
    const address = '1BoatSLRHtKNngkdXEeobR76b53LETtpyT';

    test('redacts the exception value Sentry would otherwise upload raw', () {
      final event = SentryEvent(
        exceptions: [
          SentryException(
            type: '_Exception',
            value: 'Exception: Failed to get balance for $address and XCP',
          ),
        ],
      );

      final sanitized = sanitizeSentryEvent(event);

      expect(sanitized.exceptions!.single.value, isNot(contains(address)));
      expect(
        sanitized.exceptions!.single.value,
        contains(redactedWalletAddress),
      );
      expect(sanitized.exceptions!.single.type, '_Exception');
    });

    test('redacts message, breadcrumbs and request', () {
      final event = SentryEvent(
        message: SentryMessage('balance for $address'),
        breadcrumbs: [
          Breadcrumb(
            message: 'GET /address/$address',
            data: {'address': address},
          ),
        ],
        request: SentryRequest(
          url: 'https://api.example.test/address/$address/txs',
          queryString: 'change=$address',
        ),
      );

      final sanitized = sanitizeSentryEvent(event);

      expect(sanitized.message!.formatted, isNot(contains(address)));
      expect(sanitized.breadcrumbs!.single.message, isNot(contains(address)));
      expect(sanitized.breadcrumbs!.single.data!['address'],
          redactedWalletAddress);
      expect(sanitized.request!.url, isNot(contains(address)));
      expect(sanitized.request!.queryString, isNot(contains(address)));
    });

    test('leaves an event without sensitive payloads untouched', () {
      final event = SentryEvent(
        message: SentryMessage('GET /tx/4d3f43a4e365968b'),
      );

      final sanitized = sanitizeSentryEvent(event);

      expect(sanitized.message!.formatted, 'GET /tx/4d3f43a4e365968b');
      expect(sanitized.exceptions, isNull);
      expect(sanitized.request, isNull);
    });
  });
}
