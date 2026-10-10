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

    test('redacts signed transaction and PSBT query payloads', () {
      final result = sanitizeTelemetryText(
          'POST /v2/bitcoin/transactions?signedhex=deadbeef&network=mainnet psbt_base64=abcsDEF== status=offline');
      expect(result, isNot(contains('deadbeef')));
      expect(result, isNot(contains('abcsDEF==')));
      expect(result, contains('signedhex=$redactedTransactionPayload'));
      expect(result, contains('network=mainnet'));
      expect(result, contains('status=offline'));
    });

    test('redacts raw transactions sent to the decode and info endpoints', () {
      final decode = sanitizeTelemetryText(
          'GET /v2/bitcoin/transactions/decode?rawtx=0200000001aabbccdd');
      final info = sanitizeTelemetryText(
          'GET /v2/transactions/info?verbose=true&rawtransaction=0200000001aabbccdd');
      expect(decode, isNot(contains('0200000001aabbccdd')));
      expect(decode, contains('rawtx=$redactedTransactionPayload'));
      expect(info, isNot(contains('0200000001aabbccdd')));
      expect(info, contains('verbose=true'));
      expect(info, contains('rawtransaction=$redactedTransactionPayload'));
    });

    test('redacts payload fields whatever their case or underscores', () {
      final result = sanitizeTelemetryText(
        'txHex=0200aa&psbtBase64=cHNidP8B%2B%3D&inputs_set=ab%3A0%2Ccd%3A1',
      );

      expect(
        result,
        'txHex=$redactedTransactionPayload'
        '&psbtBase64=$redactedTransactionPayload'
        '&inputs_set=$redactedTransactionPayload',
      );
    });

    test('leaves fields that only contain a payload name intact', () {
      const value = 'GET /v2/assets?is_psbt=true&has_rawtx=1&psbtcount=2';

      expect(sanitizeTelemetryText(value), value);
    });

    test('stops a redacted payload at the end of its value', () {
      expect(
        sanitizeTelemetryText('rawtx=0200aa;status=offline'),
        'rawtx=$redactedTransactionPayload;status=offline',
      );
      expect(
        sanitizeTelemetryText('{"url":"/tx?signedhex=0200aa","status":500}'),
        '{"url":"/tx?signedhex=$redactedTransactionPayload","status":500}',
      );
    });

    test('redacts addresses and keys after a percent-encoded delimiter', () {
      const segwit = 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh';
      const legacy = '1BoatSLRHtKNngkdXEeobR76b53LETtpyT';
      const wif = 'L1aW4aubDFB7yfras2S1mN3bqg9nwySY8nkoLmJebSLD5BWv3ENZ';

      final result = sanitizeTelemetryText(
        '/balances?addresses=$segwit%2C$segwit%2c$legacy&keys=%5B$wif%5D',
      );

      expect(
        result,
        '/balances?addresses=$redactedWalletAddress%2C$redactedWalletAddress'
        '%2c$redactedWalletAddress&keys=%5B$redactedPrivateKey%5D',
      );
    });

    test('keeps only the verb of a wallet request', () {
      expect(
        sanitizeTelemetryText(
          'https://wallet.test/?action=signPsbt%3Aext%2C1%2Creq%2CcHNidP8BAHEC%2B%2F%3D%2CeyJ9',
        ),
        'https://wallet.test/?action=signPsbt%3Aext$redactedWalletRequest',
      );
      expect(
        sanitizeTelemetryText(
          '#/dashboard?action=signMessage:ext,1,req,hello,1BoatSLRHtKNngkdXEeobR76b53LETtpyT&tab=2',
        ),
        '#/dashboard?action=signMessage:ext$redactedWalletRequest&tab=2',
      );
    });

    test('leaves an API action field intact', () {
      const value = '{"action": "issuance fee", "action=": 1}';

      expect(sanitizeTelemetryText(value), value);
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
      const messages = [
        'sent to 1BoatSLRHtKNngkdXEeobR76b53LETtpyT',
        '/?action=signPsbt%3Aext%2C1%2Creq%2CcHNidP8B&signedhex=0200aa'
            '&addresses=%2Cbc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
      ];

      for (final message in messages) {
        final once = sanitizeTelemetryText(message);

        expect(sanitizeTelemetryText(once), once);
      }
    });
  });

  group('sanitizeTelemetryValue', () {
    test('redacts payload fields in nested telemetry maps', () {
      final result = sanitizeTelemetryValue({
        'request': {
          'signedhex': 'deadbeef',
          'psbt_hex': '70736274',
          'rawTransaction': '0200000001aabbccdd',
          'txHex': '0200000001aabbccdd',
          'psbtBase64': 'cHNidP8B',
          'txid': 'public-id',
        },
      }) as Map;

      expect(result['request'], {
        'signedhex': redactedTransactionPayload,
        'psbt_hex': redactedTransactionPayload,
        'rawTransaction': redactedTransactionPayload,
        'txHex': redactedTransactionPayload,
        'psbtBase64': redactedTransactionPayload,
        'txid': 'public-id',
      });
    });

    test('redacts the PSBT fields of a sign request', () {
      final result = sanitizeTelemetryValue({
        'unsignedPsbt': '70736274ff01',
        'signedPsbt': '70736274ff02',
        'signedPsbtHex': '70736274ff02',
        'unsignedTransactionHex': '0200000001aabbccdd',
        'url': '/sign?signedPsbt=70736274ff02&tabId=1',
      }) as Map;

      expect(result, {
        'unsignedPsbt': redactedTransactionPayload,
        'signedPsbt': redactedTransactionPayload,
        'signedPsbtHex': redactedTransactionPayload,
        'unsignedTransactionHex': redactedTransactionPayload,
        'url': '/sign?signedPsbt=$redactedTransactionPayload&tabId=1',
      });
    });

    test('keeps a missing payload missing', () {
      final result = sanitizeTelemetryValue({'psbt': null}) as Map;

      expect(result['psbt'], isNull);
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

    test('detects transaction payloads for fail-closed telemetry', () {
      expect(containsWalletSecret({'psbt': 'deadbeef'}), isTrue);
      expect(containsWalletSecret({'url': '/broadcast?signedhex=deadbeef'}),
          isTrue);
      expect(containsWalletSecret({'rawtx': '0200000001aabbccdd'}), isTrue);
      expect(
          containsWalletSecret({'url': '/transactions/info?rawtransaction=02'}),
          isTrue);
      expect(containsWalletSecret({'txid': 'public-id'}), isFalse);
    });

    test('accepts payload fields that are missing or already redacted', () {
      final sanitized = sanitizeTelemetryValue({
        'psbt': 'cHNidP8B',
        'url': '/broadcast?signedhex=deadbeef',
      });

      expect(containsWalletSecret({'psbt': null}), isFalse);
      expect(containsWalletSecret(sanitized), isFalse);
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
