const redactedWalletAddress = '[wallet-address-redacted]';
const redactedExtendedKey = '[extended-key-redacted]';
const redactedPrivateKey = '[private-key-redacted]';

const _base58 = r'[1-9A-HJ-NP-Za-km-z]';

/// Redacts wallet-identifying secrets out of anything on its way to telemetry.
///
/// The patterns cover the values that actually turn up inside error strings:
/// on-chain addresses (P2PKH, P2SH and bech32/bech32m across every network),
/// extended keys, and WIF private keys. Order matters — the more specific
/// prefixes are matched before the generic Base58Check address shape.
///
/// A match is only redacted when it stands alone as a token and is not pure
/// hexadecimal, so transaction hashes, event ids and other long alphanumeric
/// identifiers survive untouched. A real Base58 or bech32 payload of this
/// length is hexadecimal only with vanishing probability.
final _secretPatterns = <RegExp, String>{
  // Bech32 / bech32m: mainnet, testnet, signet and regtest.
  RegExp(r'(?:bc1|tb1|bcrt1)[0-9a-z]{11,71}', caseSensitive: false):
      redactedWalletAddress,
  // Extended keys, BIP32 and the SLIP-132 variants: 111 Base58 characters.
  RegExp('(?:[xyzvutYZVU]pub|[xyzvutYZVU]prv)$_base58{107}'):
      redactedExtendedKey,
  // WIF private keys: 51 characters uncompressed, 52 compressed.
  RegExp('(?:[59]$_base58{50}|[KLc]$_base58{51})'): redactedPrivateKey,
  // Base58Check addresses: P2PKH (1, m, n) and P2SH (3, 2).
  RegExp('[123mn]$_base58{25,62}'): redactedWalletAddress,
};

String sanitizeTelemetryText(String value) {
  var sanitized = value;
  for (final entry in _secretPatterns.entries) {
    final source = sanitized;
    sanitized = source.replaceAllMapped(entry.key, (match) {
      final matched = match.group(0)!;
      if (_isInsideLongerToken(source, match) || _isHexadecimal(matched)) {
        return matched;
      }
      return entry.value;
    });
  }
  return sanitized;
}

bool _isInsideLongerToken(String value, Match match) {
  final startsInsideToken = match.start > 0 &&
      _isAsciiLetterOrDigit(value.codeUnitAt(match.start - 1));
  final endsInsideToken = match.end < value.length &&
      _isAsciiLetterOrDigit(value.codeUnitAt(match.end));
  return startsInsideToken || endsInsideToken;
}

bool _isHexadecimal(String value) {
  for (var i = 0; i < value.length; i++) {
    final codeUnit = value.codeUnitAt(i);
    final isDigit = codeUnit >= 48 && codeUnit <= 57;
    final isUpperHex = codeUnit >= 65 && codeUnit <= 70;
    final isLowerHex = codeUnit >= 97 && codeUnit <= 102;
    if (!isDigit && !isUpperHex && !isLowerHex) {
      return false;
    }
  }
  return true;
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

/// Whether [value] still holds something [sanitizeTelemetryValue] would redact.
///
/// Used to fail closed on payloads whose contents cannot be rewritten through
/// the Sentry SDK's public API.
bool containsWalletSecret(dynamic value) {
  if (value == null || value is num || value is bool) {
    return false;
  }
  if (value is String) {
    return sanitizeTelemetryText(value) != value;
  }
  if (value is Map) {
    return value.entries.any(
      (entry) =>
          containsWalletSecret(entry.key.toString()) ||
          containsWalletSecret(entry.value),
    );
  }
  if (value is Iterable) {
    return value.any(containsWalletSecret);
  }
  return containsWalletSecret(value.toString());
}
