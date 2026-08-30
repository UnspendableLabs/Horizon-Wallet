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

    test('redacts testnet, regtest and P2SH addresses', () {
      const testnet = 'mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn';
      const regtest = 'bcrt1qw508d6qejxtdg4y5r3zarvary0c5xw7kygt080';
      const p2sh = '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy';

      final result = sanitizeTelemetryText('$testnet $regtest $p2sh');

      expect(result, isNot(contains(testnet)));
      expect(result, isNot(contains(regtest)));
      expect(result, isNot(contains(p2sh)));
      expect(
        result,
        '$redactedWalletAddress $redactedWalletAddress '
        '$redactedWalletAddress',
      );
    });

    test('redacts extended keys and WIF private keys', () {
      const xpub =
          'xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8';
      const wif = 'L1aW4aubDFB7yfras2S1mN3bqg9nwySY8nkoLmJebSLD5BWv3ENZ';

      final result = sanitizeTelemetryText('key=$xpub secret=$wif');

      expect(result, isNot(contains(xpub)));
      expect(result, isNot(contains(wif)));
      expect(
        result,
        'key=$redactedExtendedKey secret=$redactedPrivateKey',
      );
    });

    test('leaves transaction hashes and ordinary text intact', () {
      const value =
          'GET /tx/4d3f43a4e365968b2cbbf64347b62564928cf4b590cb9f14d5c01710c86c33a5';

      expect(sanitizeTelemetryText(value), value);
    });

    test('leaves standalone hexadecimal identifiers intact', () {
      // A Sentry event id, and a hex string long enough to look like an
      // address but made only of hex characters.
      const eventId = '3c2df1a4b5e6789abcdef123456789ab';
      const hexOnly = '1234567891234567891234567891234567';

      expect(sanitizeTelemetryText(eventId), eventId);
      expect(sanitizeTelemetryText(hexOnly), hexOnly);
    });

    test('is idempotent', () {
      const message = 'sent to 1BoatSLRHtKNngkdXEeobR76b53LETtpyT';

      final once = sanitizeTelemetryText(message);

      expect(sanitizeTelemetryText(once), once);
    });
  });

  group('sanitizeTelemetryValue', () {
    test('recursively sanitizes breadcrumb context', () {
      const address = 'tb1qfmw0p58g4w7m9s3e7nqlk0c4xv2z8r6t5y3u2i';

      final result = sanitizeTelemetryValue({
        'url': 'https://example.test/address/$address',
        'addresses': [address],
      }) as Map;

      expect(result['url'], isNot(contains(address)));
      expect(result['addresses'], [redactedWalletAddress]);
    });

    test('preserves non-string scalars', () {
      final result = sanitizeTelemetryValue({
        'statusCode': 500,
        'retried': true,
        'missing': null,
      }) as Map;

      expect(result['statusCode'], 500);
      expect(result['retried'], isTrue);
      expect(result['missing'], isNull);
    });
  });

  group('containsWalletSecret', () {
    test('detects a secret nested anywhere in a payload', () {
      expect(
        containsWalletSecret({
          'spans': [
            {'description': 'GET /address/1BoatSLRHtKNngkdXEeobR76b53LETtpyT'},
          ],
        }),
        isTrue,
      );
    });

    test('accepts a payload with nothing to redact', () {
      expect(
        containsWalletSecret({
          'event_id': '3c2df1a4b5e6789abcdef123456789ab',
          'spans': [
            {'description': 'GET /v2/blocks/last'},
          ],
        }),
        isFalse,
      );
    });
  });
}
