import 'package:horizon/core/logging/sentry_sanitizer.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Scrubs outgoing Sentry payloads at the single point they all pass through.
///
/// [ErrorServiceImpl] sanitizes the breadcrumbs it writes itself, but every
/// other route into Sentry — uncaught framework errors, zone errors, exceptions
/// captured from blocs — hands the SDK a raw object whose `toString()` becomes
/// the event's exception value. Sanitizing there covers one path; sanitizing
/// the prepared event covers all of them, including exception values, stack
/// frame data, request details, contexts and extras.
///
/// The event is scrubbed through its wire format: what gets sanitized is
/// exactly what would have been sent.
///
/// On web the request is the page URL. The extension hands the wallet a
/// request in it (`#?action=signMessage:ext,…`) whose arguments carry the
/// PSBT or the message to sign, written as is, so the query string and the
/// fragment are dropped rather than scrubbed: no pattern can tell where a
/// message ends.
SentryEvent sanitizeSentryEvent(SentryEvent event) {
  final sanitized = Map<String, dynamic>.from(
    sanitizeTelemetryValue(event.toJson()) as Map,
  );
  final request = sanitized['request'];
  if (request is Map) {
    sanitized['request'] = Map<String, dynamic>.from(request)
      ..remove('query_string')
      ..remove('fragment');
  }
  return SentryEvent.fromJson(sanitized);
}

Breadcrumb? sanitizeSentryBreadcrumb(Breadcrumb? breadcrumb) {
  if (breadcrumb == null) {
    return null;
  }
  final message = breadcrumb.message;
  final data = breadcrumb.data;
  return breadcrumb.copyWith(
    message: message == null ? null : sanitizeTelemetryText(message),
    data: data == null
        ? null
        : Map<String, dynamic>.from(sanitizeTelemetryValue(data) as Map),
  );
}

/// Drops any transaction still carrying wallet secrets.
///
/// A transaction's spans are rebuilt from its tracer on every `copyWith`, and
/// `SentrySpanContext.description` is final, so span descriptions — the field
/// that would hold a request URL — cannot be rewritten through the public API.
/// Nothing in the app currently starts a transaction, so this costs nothing
/// today; it exists so that wiring up tracing later cannot leak silently.
SentryTransaction? sanitizeSentryTransaction(SentryTransaction transaction) {
  if (containsWalletSecret(transaction.toJson())) {
    return null;
  }
  return transaction;
}
