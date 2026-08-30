import 'package:sentry_flutter/sentry_flutter.dart';

final _bitcoinAddressPattern = RegExp(
  r'(?:bc1|tb1|bcrt1)[0-9a-z]{11,71}|[123mn2][1-9A-HJ-NP-Za-km-z]{25,62}',
  caseSensitive: false,
);

const redactedWalletAddress = '[wallet-address-redacted]';

String sanitizeTelemetryText(String value) {
  return value.replaceAllMapped(_bitcoinAddressPattern, (match) {
    final startsInsideToken = match.start > 0 &&
        _isAsciiLetterOrDigit(value.codeUnitAt(match.start - 1));
    final endsInsideToken = match.end < value.length &&
        _isAsciiLetterOrDigit(value.codeUnitAt(match.end));
    if (startsInsideToken || endsInsideToken) {
      return match.group(0)!;
    }
    return redactedWalletAddress;
  });
}

String? sanitizeNullableTelemetryText(String? value) {
  return value == null ? null : sanitizeTelemetryText(value);
}

bool _isAsciiLetterOrDigit(int codeUnit) {
  return (codeUnit >= 48 && codeUnit <= 57) ||
      (codeUnit >= 65 && codeUnit <= 90) ||
      (codeUnit >= 97 && codeUnit <= 122);
}

/// Sanitizes a map without losing entries: two keys that redact to the same
/// placeholder would otherwise collapse onto one another and silently drop a
/// value, so colliding keys are suffixed instead.
Map<String, dynamic> sanitizeTelemetryMap(Map<dynamic, dynamic> value) {
  final sanitized = <String, dynamic>{};
  for (final entry in value.entries) {
    final key =
        _uniqueKey(sanitized, sanitizeTelemetryText(entry.key.toString()));
    sanitized[key] = sanitizeTelemetryValue(entry.value);
  }
  return sanitized;
}

Map<String, dynamic>? sanitizeNullableTelemetryMap(
    Map<dynamic, dynamic>? value) {
  return value == null ? null : sanitizeTelemetryMap(value);
}

String _uniqueKey(Map<String, dynamic> target, String key) {
  if (!target.containsKey(key)) {
    return key;
  }
  var suffix = 2;
  while (target.containsKey('$key#$suffix')) {
    suffix++;
  }
  return '$key#$suffix';
}

dynamic sanitizeTelemetryValue(dynamic value) {
  if (value == null || value is num || value is bool) {
    return value;
  }
  if (value is String) {
    return sanitizeTelemetryText(value);
  }
  if (value is Map) {
    return sanitizeTelemetryMap(value);
  }
  if (value is Iterable) {
    return value.map(sanitizeTelemetryValue).toList(growable: false);
  }

  return sanitizeTelemetryText(value.toString());
}

/// Last line of defence, wired up as `SentryOptions.beforeSend`.
///
/// Sanitizing at the call sites only covers the payloads we build ourselves;
/// exception values (`Exception('Failed to get balance for $address')`) and
/// anything Sentry captures on its own — unhandled errors, zone errors — never
/// pass through them. Every outgoing event goes through here instead.
SentryEvent sanitizeSentryEvent(SentryEvent event) {
  final message = event.message;
  final request = event.request;

  return event.copyWith(
    message: message == null
        ? null
        : message.copyWith(
            formatted: sanitizeTelemetryText(message.formatted),
            template: sanitizeNullableTelemetryText(message.template),
            params: message.params
                ?.map(sanitizeTelemetryValue)
                .toList(growable: false),
          ),
    exceptions: event.exceptions
        ?.map((exception) => exception.copyWith(
              value: sanitizeNullableTelemetryText(exception.value),
            ))
        .toList(growable: false),
    breadcrumbs: event.breadcrumbs
        ?.map((breadcrumb) => breadcrumb.copyWith(
              message: sanitizeNullableTelemetryText(breadcrumb.message),
              data: sanitizeNullableTelemetryMap(breadcrumb.data),
            ))
        .toList(growable: false),
    request: request == null
        ? null
        : request.copyWith(
            url: sanitizeNullableTelemetryText(request.url),
            queryString: sanitizeNullableTelemetryText(request.queryString),
            fragment: sanitizeNullableTelemetryText(request.fragment),
            data: sanitizeTelemetryValue(request.data),
          ),
    culprit: sanitizeNullableTelemetryText(event.culprit),
    transaction: sanitizeNullableTelemetryText(event.transaction),
  );
}
