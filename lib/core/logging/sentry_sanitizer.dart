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

bool _isAsciiLetterOrDigit(int codeUnit) {
  return (codeUnit >= 48 && codeUnit <= 57) ||
      (codeUnit >= 65 && codeUnit <= 90) ||
      (codeUnit >= 97 && codeUnit <= 122);
}

dynamic sanitizeTelemetryValue(dynamic value) {
  if (value == null || value is num || value is bool) {
    return value;
  }
  if (value is String) {
    return sanitizeTelemetryText(value);
  }
  if (value is Map) {
    return value.map(
      (key, nestedValue) => MapEntry(
        sanitizeTelemetryText(key.toString()),
        sanitizeTelemetryValue(nestedValue),
      ),
    );
  }
  if (value is Iterable) {
    return value.map(sanitizeTelemetryValue).toList(growable: false);
  }

  return sanitizeTelemetryText(value.toString());
}
