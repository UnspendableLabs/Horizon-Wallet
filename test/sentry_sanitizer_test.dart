import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/core/logging/sentry_sanitizer.dart';

void main() {
  // A signed one-input, one-output segwit transaction, and the start of a
  // PSBT in base64.
  final rawTransaction = '0200000001${'ab' * 32}0000000000ffffffff01'
      'e803000000000000160014${'cd' * 20}00000000';
  const psbt = 'cHNidP8BAHECAAAAAQ+/AHE=';

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

    test('redacts the payload fields the app names', () {
      expect(
        sanitizeTelemetryText(
          'transactionHex=0200aa&hex=0200bb&signedDispenser=0200cc'
          '&signed-hex=0200dd&psbt-base64=$psbt',
        ),
        'transactionHex=$redactedTransactionPayload'
        '&hex=$redactedTransactionPayload'
        '&signedDispenser=$redactedTransactionPayload'
        '&signed-hex=$redactedTransactionPayload'
        '&psbt-base64=$redactedTransactionPayload',
      );
    });

    test('leaves fields that only contain a payload name intact', () {
      const value = 'GET /v2/assets?is_psbt=true&has_rawtx=1&psbtcount=2'
          '&memo_is_hex=true&x-psbt=1';

      expect(sanitizeTelemetryText(value), value);
    });

    test('redacts a payload joined to the field before it', () {
      expect(
        sanitizeTelemetryText('status=500,signedhex=0200000001aabbccdd'),
        'status=500,signedhex=$redactedTransactionPayload',
      );
      expect(
        sanitizeTelemetryText('request=signedhex=0200000001aabbccdd'),
        'request=signedhex=$redactedTransactionPayload',
      );
    });

    test('redacts a payload field after a percent escape', () {
      expect(
        sanitizeTelemetryText('a%26signedhex=0200aa'),
        'a%26signedhex=$redactedTransactionPayload',
      );
      expect(
        sanitizeTelemetryText('x%3Fpsbt=$psbt'),
        'x%3Fpsbt=$redactedTransactionPayload',
      );
      expect(
        sanitizeTelemetryText(
          'next=%2Fbroadcast%3Fsignedhex%3D0200aa%26network%3Dmainnet',
        ),
        'next=%2Fbroadcast%3Fsignedhex%3D$redactedTransactionPayload'
        '%26network%3Dmainnet',
      );
      expect(
        sanitizeTelemetryText(
          'next=%252Fbroadcast%253Fsignedhex%253D0200aa%2526network%253D1',
        ),
        'next=%252Fbroadcast%253Fsignedhex%253D$redactedTransactionPayload'
        '%2526network%253D1',
      );
    });

    test('redacts a base64url payload whole', () {
      expect(
        sanitizeTelemetryText('psbt=cHNidP8B-AHE_CAAAAAQ&tab=1'),
        'psbt=$redactedTransactionPayload&tab=1',
      );
    });

    test('redacts payload fields written as JSON or by toString()', () {
      expect(
        sanitizeTelemetryText('{"psbt":"$psbt","status":500}'),
        '{"psbt":"$redactedTransactionPayload","status":500}',
      );
      expect(
        sanitizeTelemetryText(r'{\"signedhex\":\"0200000001aabbccdd\"}'),
        '{\\"signedhex\\":\\"$redactedTransactionPayload\\"}',
      );
      expect(
        sanitizeTelemetryText("{'rawtx': '0200000001aabbccdd'}"),
        "{'rawtx': '$redactedTransactionPayload'}",
      );
      expect(
        sanitizeTelemetryText('%22psbt%22%3A%22cHNidP8B%2B%22'),
        '%22psbt%22%3A%22$redactedTransactionPayload%22',
      );
      expect(
        sanitizeTelemetryText(
          'State(signedDispenser: 0200000001aabbccdd, status: done)',
        ),
        'State(signedDispenser: $redactedTransactionPayload, status: done)',
      );
    });

    test('leaves prose and missing values after a payload name intact', () {
      const value = 'Failed to sign psbt: 3 inputs missing; psbt: invalid; '
          '{"psbt": null, "rawtx": ""}';

      expect(sanitizeTelemetryText(value), value);
    });

    test('redacts transactions and PSBTs under any name or none', () {
      expect(
        sanitizeTelemetryText('SubmitSuccess($rawTransaction, sent)'),
        'SubmitSuccess($redactedTransactionPayload, sent)',
      );
      expect(
        sanitizeTelemetryText('blob=$rawTransaction&next=%2C$rawTransaction'),
        'blob=$redactedTransactionPayload'
        '&next=%2C$redactedTransactionPayload',
      );
      expect(
        sanitizeTelemetryText('RPCSignPsbtAction(1, req, $psbt, e30=)'),
        'RPCSignPsbtAction(1, req, $redactedTransactionPayload, e30=)',
      );
      expect(
        sanitizeTelemetryText('psbt hex 70736274ff0100710200'),
        'psbt hex $redactedTransactionPayload',
      );
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

    test('redacts addresses after a double-encoded delimiter', () {
      const segwit = 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh';

      expect(
        sanitizeTelemetryText('addresses=$segwit%252C$segwit'),
        'addresses=$redactedWalletAddress%252C$redactedWalletAddress',
      );
    });

    test('keeps only the verb of a wallet request', () {
      const address = '1BoatSLRHtKNngkdXEeobR76b53LETtpyT';

      expect(
        sanitizeTelemetryText(
          'https://wallet.test/?action=signPsbt%3Aext%2C1%2Creq%2CcHNidP8BAHEC%2B%2F%3D%2CeyJ9',
        ),
        'https://wallet.test/?action=signPsbt%3Aext$redactedWalletRequest',
      );
      // The message is written as is, so nothing after the verb is kept.
      expect(
        sanitizeTelemetryText(
          '#/dashboard?action=signMessage:ext,1,req,hello & bye,$address&tab=2',
        ),
        '#/dashboard?action=signMessage:ext$redactedWalletRequest',
      );
      // Uri.encodeComponent leaves `'` as is.
      expect(
        sanitizeTelemetryText(
          '/?action=${Uri.encodeComponent("signMessage:ext,1,req,I'm approving my seed backup,$address")}',
        ),
        '/?action=signMessage%3Aext$redactedWalletRequest',
      );
      expect(
        sanitizeTelemetryText(
          'next=%2F%3Faction%3DsignPsbt%3Aext%2C1%2Creq%2CcHNidP8B',
        ),
        'next=%2F%3Faction%3DsignPsbt%3Aext$redactedWalletRequest',
      );
      expect(
        sanitizeTelemetryText(
          '{"location":"/?action=signMessage:ext,1,req,hi","level":"error"}',
        ),
        '{"location":"/?action=signMessage:ext$redactedWalletRequest',
      );
      // A verb not known to be public is redacted whatever it carries.
      expect(
        sanitizeTelemetryText('action=signTransaction:ext,1,req,0200aa'),
        'action=signTransaction:ext$redactedWalletRequest',
      );
    });

    test('keeps the arguments of a public wallet request', () {
      const fairmint = 'action=fairmint:ext,'
          '4d3f43a4e365968b2cbbf64347b62564928cf4b590cb9f14d5c01710c86c33a5,2';
      const openOrder = 'action=openOrder%3Aext%2CXCP%2C100%2CPEPECASH%2C200';

      expect(sanitizeTelemetryText(fairmint), fairmint);
      expect(sanitizeTelemetryText(openOrder), openOrder);
      expect(
        sanitizeTelemetryText(
          'action=dispense:ext,1BoatSLRHtKNngkdXEeobR76b53LETtpyT',
        ),
        'action=dispense:ext,$redactedWalletAddress',
      );
    });

    test('leaves an action that is no wallet request intact', () {
      const value = '{"action": "issuance fee", "action=": 1} '
          'GET /v2/x?action=compose-send&foo=1';

      expect(sanitizeTelemetryText(value), value);
    });

    test('leaves transaction hashes and ordinary text intact', () {
      const value =
          'GET /tx/4d3f43a4e365968b2cbbf64347b62564928cf4b590cb9f14d5c01710c86c33a5'
          ' /tx/01000000e365968b2cbbf64347b62564928cf4b590cb9f14d5c01710c86c33a5';

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
      final messages = [
        'sent to 1BoatSLRHtKNngkdXEeobR76b53LETtpyT',
        '/?signedhex=0200aa&addresses=%2Cbc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh'
            '&action=signPsbt%3Aext%2C1%2Creq%2CcHNidP8B',
        '{"psbt":"$psbt"} State(signedDispenser: 0200000001aabbccdd) '
            '$rawTransaction',
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

    test('redacts the payload fields the app names', () {
      final result = sanitizeTelemetryValue({
        'transactionHex': '0200000001aabbccdd',
        'hex': '0200000001aabbccdd',
        'signedDispenser': '0200000001aabbccdd',
        'signedAssetSend': '0200000001aabbccdd',
        'signed-hex': '0200000001aabbccdd',
        'inputs_set': ['aabb:0', 'ccdd:1'],
        'memo_is_hex': true,
        'signed_tx_estimated_size': 250,
      }) as Map;

      expect(result, {
        'transactionHex': redactedTransactionPayload,
        'hex': redactedTransactionPayload,
        'signedDispenser': redactedTransactionPayload,
        'signedAssetSend': redactedTransactionPayload,
        'signed-hex': redactedTransactionPayload,
        'inputs_set': redactedTransactionPayload,
        'memo_is_hex': true,
        'signed_tx_estimated_size': 250,
      });
    });

    test('redacts a transaction under a name it does not know', () {
      final result = sanitizeTelemetryValue({
        'state': {'blob': rawTransaction},
      }) as Map;

      expect(result['state'], {'blob': redactedTransactionPayload});
    });

    test('keeps a payload field that holds no payload', () {
      const value = {'psbt': null, 'hex': true, 'rawtx': '', 'txhex': 0};

      expect(sanitizeTelemetryValue(value), value);
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

    test('detects payloads the field before them used to hide', () {
      expect(containsWalletSecret('status=500,signedhex=0200aa'), isTrue);
      expect(containsWalletSecret({'body': '{"psbt":"$psbt"}'}), isTrue);
      expect(containsWalletSecret({'state': 'Sent($rawTransaction)'}), isTrue);
      expect(containsWalletSecret({'hex': true, 'psbt': ''}), isFalse);
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
