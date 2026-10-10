import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/core/logging/sentry_event_sanitizer.dart';
import 'package:horizon/core/logging/sentry_sanitizer.dart';
// SentryTransaction can only be built from a tracer, which the SDK keeps
// internal.
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:sentry/src/sentry_tracer.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class WalletException implements Exception {
  const WalletException(this.address);

  final String address;

  @override
  String toString() => 'WalletException: no UTXOs for $address';
}

void main() {
  const address = '1BoatSLRHtKNngkdXEeobR76b53LETtpyT';

  test('redacts the exception value, not just the breadcrumb', () {
    final event = SentryEvent(
      exceptions: [
        SentryException(
          type: 'WalletException',
          value: const WalletException(address).toString(),
        ),
      ],
    );

    final sanitized = sanitizeSentryEvent(event);

    expect(sanitized.exceptions!.single.value, isNot(contains(address)));
    expect(
      sanitized.exceptions!.single.value,
      contains(redactedWalletAddress),
    );
    expect(sanitized.exceptions!.single.type, 'WalletException');
  });

  test('redacts messages, breadcrumbs, request data and extras', () {
    final event = SentryEvent(
      message: const SentryMessage('failed for $address'),
      breadcrumbs: [
        Breadcrumb(
          message: 'GET /address/$address',
          data: const {'address': address},
        ),
      ],
      request: SentryRequest(
        url: 'https://example.test/address/$address',
      ),
      // ignore: deprecated_member_use
      extra: const {'account': address},
      tags: const {'lastAddress': address},
    );

    final sanitized = sanitizeSentryEvent(event);
    final serialized = sanitized.toJson().toString();

    expect(serialized, isNot(contains(address)));
    expect(serialized, contains(redactedWalletAddress));
  });

  test('drops the query string and fragment of the page URL', () {
    // On web, Sentry fills the request from window.location, split into its
    // query string and fragment. The extension writes the message to sign
    // into the fragment as is.
    const args = '1,req,cHNidP8BAHECAAAAAQ,eyJ9';
    final event = SentryEvent(
      request: SentryRequest(
        url: 'https://wallet.test/index.html',
        method: 'GET',
        queryString: 'action=signPsbt%3Aext%2C${Uri.encodeComponent(args)}',
        fragment: "?action=signMessage:ext,1,req,I'm signing & my nonce,"
            '$address',
      ),
    );

    final request = sanitizeSentryEvent(event).request!;

    expect(request.queryString, isNull);
    expect(request.fragment, isNull);
    expect(request.url, 'https://wallet.test/index.html');
    expect(request.method, 'GET');
  });

  test('keeps the route the fragment of the page URL holds', () {
    // Under the hash URL strategy the fragment is the screen's route.
    SentryRequest requestFor(String fragment) => sanitizeSentryEvent(
          SentryEvent(
            request: SentryRequest(
              url: 'https://wallet.test/',
              fragment: fragment,
            ),
          ),
        ).request!;

    expect(requestFor('/compose/send').fragment, '/compose/send');
    expect(
      requestFor("/dashboard?action=signMessage:ext,1,req,I'm,$address")
          .fragment,
      '/dashboard',
    );
    expect(
      requestFor('/address/$address').fragment,
      '/address/$redactedWalletAddress',
    );
  });

  group('sanitizeSentryTransaction', () {
    SentryTransaction transactionWith({
      required SentryRequest request,
      Map<String, String>? tags,
    }) {
      final hub = Hub(SentryOptions(dsn: 'https://key@sentry.test/1'));
      return SentryTransaction(
        SentryTracer(SentryTransactionContext('send', 'ui.action'), hub),
        request: request,
        tags: tags,
      );
    }

    test('drops the arguments of the page URL rather than the transaction', () {
      final sanitized = sanitizeSentryTransaction(
        transactionWith(
          request: SentryRequest(
            url: 'https://wallet.test/',
            queryString: 'action=signPsbt%3Aext%2C1%2Creq%2CcHNidP8B',
            fragment: "/dashboard?action=signMessage:ext,1,req,I'm,$address",
          ),
        ),
      );

      expect(sanitized, isNotNull);
      expect(sanitized!.request!.queryString, isNull);
      expect(sanitized.request!.fragment, '/dashboard');
      expect(sanitized.request!.url, 'https://wallet.test/');
    });

    test('drops a transaction still carrying a wallet secret', () {
      final transaction = transactionWith(
        request: SentryRequest(url: 'https://wallet.test/'),
        tags: const {'lastAddress': address},
      );

      expect(sanitizeSentryTransaction(transaction), isNull);
    });
  });

  test('preserves the event id and other structural fields', () {
    final event = SentryEvent(
      release: 'horizon@1.7.11+1',
      environment: 'production',
      level: SentryLevel.error,
      message: const SentryMessage('sent to $address'),
    );

    final sanitized = sanitizeSentryEvent(event);

    expect(sanitized.eventId, event.eventId);
    expect(sanitized.release, 'horizon@1.7.11+1');
    expect(sanitized.environment, 'production');
    expect(sanitized.level, SentryLevel.error);
  });

  test('sanitizeSentryBreadcrumb scrubs message and data', () {
    final sanitized = sanitizeSentryBreadcrumb(
      Breadcrumb(message: 'GET /address/$address', data: const {'to': address}),
    )!;

    expect(sanitized.message, isNot(contains(address)));
    expect(sanitized.data!['to'], redactedWalletAddress);
  });

  test('sanitizeSentryBreadcrumb tolerates a null breadcrumb', () {
    expect(sanitizeSentryBreadcrumb(null), isNull);
  });
}
