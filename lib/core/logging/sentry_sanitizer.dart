const redactedWalletAddress = '[wallet-address-redacted]';
const redactedExtendedKey = '[extended-key-redacted]';
const redactedPrivateKey = '[private-key-redacted]';
const redactedTransactionPayload = '[transaction-payload-redacted]';
const redactedWalletRequest = '[wallet-request-redacted]';

/// Fields that carry a transaction, a PSBT or the inputs it spends. Names are
/// compared lowercased and without underscores, so `tx_hex`, `txHex` and
/// `TXHEX` are one field. The value is redacted; the name is kept.
const _transactionPayloadKeys = {
  'signedhex',
  'unsignedhex',
  'signedtx',
  'unsignedtx',
  'signedtransaction',
  'unsignedtransaction',
  'rawtransaction',
  'rawtx',
  'txhex',
  'datahex',
  'inputsset',
  'psbt',
  'psbthex',
  'psbtbase64',
};

bool _isTransactionPayloadKey(Object? key) => _transactionPayloadKeys.contains(
      key.toString().toLowerCase().replaceAll('_', ''),
    );

/// Whether [value], filed under [key], is a payload still to be redacted.
bool _isUnredactedPayload(Object? key, Object? value) =>
    value != null &&
    value != redactedTransactionPayload &&
    _isTransactionPayloadKey(key);

/// A `name=value` pair. The value stops at anything a hex, base64 or
/// percent-encoded payload cannot contain, so a redaction never swallows the
/// `;`, `"` or `}` that follows it.
final _namedValuePattern = RegExp(r'\b([A-Za-z_]\w*)=([A-Za-z0-9+/=%:,]+)');

/// The extension hands the wallet a request as `?action=<verb>,<args>`. The
/// arguments carry the PSBT or the message to sign, so only the verb is kept
/// wherever the request turns up in text. The page URL itself is dropped from
/// events in `sanitizeSentryEvent`.
final _walletRequestPattern = RegExp(
  r'''\b(action=[a-z_]*(?:(?::|%(?:25)?3a)[a-z]+)?)([^&\s#"']*)''',
  caseSensitive: false,
);

/// A percent escape right before a secret, such as the `%2C` between the
/// addresses of an encoded list, delimits the secret rather than being part
/// of it. It is matched and kept so the secret is read from the character
/// after it.
const _percentEscape = '(%[0-9A-Fa-f]{2})?';

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
  RegExp(
    '$_percentEscape(?:bc1|tb1|bcrt1)[0-9a-z]{11,71}',
    caseSensitive: false,
  ): redactedWalletAddress,
  // Extended keys, BIP32 and the SLIP-132 variants: 111 Base58 characters.
  RegExp('$_percentEscape(?:[xyzvutYZVU]pub|[xyzvutYZVU]prv)$_base58{107}'):
      redactedExtendedKey,
  // WIF private keys: 51 characters uncompressed, 52 compressed.
  RegExp('$_percentEscape(?:[59]$_base58{50}|[KLc]$_base58{51})'):
      redactedPrivateKey,
  // Base58Check addresses: P2PKH (1, m, n) and P2SH (3, 2).
  RegExp('$_percentEscape[123mn]$_base58{25,62}'): redactedWalletAddress,
};

String sanitizeTelemetryText(String value) {
  var sanitized = value
      .replaceAllMapped(
        _walletRequestPattern,
        (match) =>
            match[2]!.isEmpty ? match[0]! : '${match[1]}$redactedWalletRequest',
      )
      .replaceAllMapped(
        _namedValuePattern,
        (match) => _isTransactionPayloadKey(match[1])
            ? '${match[1]}=$redactedTransactionPayload'
            : match[0]!,
      );
  for (final entry in _secretPatterns.entries) {
    final source = sanitized;
    sanitized = source.replaceAllMapped(entry.key, (match) {
      final escape = match[1] ?? '';
      final secret = match[0]!.substring(escape.length);
      if (_isInsideLongerToken(source, match) || _isHexadecimal(secret)) {
        return match[0]!;
      }
      return escape + entry.value;
    });
  }
  return sanitized;
}

/// Whether a secret match runs into the characters around it. A percent
/// escape matched in front of it counts as a delimiter.
bool _isInsideLongerToken(String value, Match match) {
  final startsInsideToken = match[1] == null &&
      match.start > 0 &&
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
        _isUnredactedPayload(key, nestedValue)
            ? redactedTransactionPayload
            : sanitizeTelemetryValue(nestedValue),
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
          _isUnredactedPayload(entry.key, entry.value) ||
          containsWalletSecret(entry.key.toString()) ||
          containsWalletSecret(entry.value),
    );
  }
  if (value is Iterable) {
    return value.any(containsWalletSecret);
  }
  return containsWalletSecret(value.toString());
}
