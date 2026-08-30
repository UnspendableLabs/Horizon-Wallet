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
SentryEvent sanitizeSentryEvent(SentryEvent event) {
  final sanitized = sanitizeTelemetryValue(event.toJson()) as Map;
  return SentryEvent.fromJson(Map<String, dynamic>.from(sanitized));
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
