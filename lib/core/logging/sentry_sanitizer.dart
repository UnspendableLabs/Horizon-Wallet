const redactedWalletAddress = '[wallet-address-redacted]';
const redactedExtendedKey = '[extended-key-redacted]';
const redactedPrivateKey = '[private-key-redacted]';
const redactedTransactionPayload = '[transaction-payload-redacted]';
const redactedWalletRequest = '[wallet-request-redacted]';

/// Fields that carry a transaction, a PSBT or the inputs it spends. Names are
/// compared lowercased and without underscores or hyphens, so `tx_hex`,
/// `txHex`, `tx-hex` and `TXHEX` are one field. The value is redacted; the
/// name is kept.
const _transactionPayloadKeys = {
  'hex',
  'signedhex',
  'unsignedhex',
  'signedtx',
  'unsignedtx',
  'signedtransaction',
  'unsignedtransaction',
  'signedtransactionhex',
  'unsignedtransactionhex',
  'transactionhex',
  'bitcointransactionhex',
  'rawtransaction',
  'rawtx',
  'txhex',
  'datahex',
  'inputsset',
  'psbt',
  'psbthex',
  'psbtbase64',
  'signedpsbt',
  'unsignedpsbt',
  'signedpsbthex',
  // The transactions signed to open a dispenser on a new address.
  'signedassetsend',
  'signeddispenser',
  'signedconstructedassetsend',
  'signedcomposedispenserchain',
};

/// The verbs of a request handed to the wallet as `action=<verb>,<args>`
/// (see `ActionRepositoryImpl`) whose arguments are public: assets and
/// quantities, a fairminter hash, a dispenser address (redacted as any
/// address is) and request ids. Any other verb has its arguments redacted,
/// so a verb added later is covered before anyone reviews what it carries.
const _publicActionVerbs = {
  'open_order',
  'openorder',
  'dispense',
  'fairmint',
  'getaddresses',
};

final _nameSeparators = RegExp('[_-]');

String _normalizedName(String name) =>
    name.toLowerCase().replaceAll(_nameSeparators, '');

bool _isTransactionPayloadKey(Object? key) =>
    _transactionPayloadKeys.contains(_normalizedName(key.toString()));

/// Whether [value] can be a payload: a transaction is never a number, a flag
/// or empty.
bool _canBePayload(Object? value) => switch (value) {
      String text => text.isNotEmpty,
      Iterable items => items.isNotEmpty,
      Map entries => entries.isNotEmpty,
      _ => false,
    };

/// A percent escape, encoded once or twice (`%2C`, `%252C`). Right before a
/// secret it delimits it, as the `%2C` between the addresses of an encoded
/// list does, rather than being part of it.
const _percentEscape = '(%(?:25)?[0-9A-Fa-f]{2})?';

/// [body] read after the percent escape that may delimit it. The escape is
/// always group 1, whatever groups [body] has, so every match is read the
/// same way: the escape is kept and what follows it is redacted.
RegExp _afterEscape(String body, {bool caseSensitive = true}) =>
    RegExp('$_percentEscape(?:$body)', caseSensitive: caseSensitive);

/// A run of what a field name is written with. Runs are maximal, so a name is
/// matched whole: `is_psbt` is not `psbt`.
final _nameRunPattern = RegExp('[A-Za-z0-9_-]+');

/// The rest of a percent escape, encoded once or twice, at the start of a run
/// that follows a `%`.
final _escapeTailPattern = RegExp('(?:25)?[0-9A-Fa-f]{2}');

/// What assigns a field its value after its name: `=`, `: `, the JSON `":"`,
/// and their escaped and percent-encoded forms. The value is not part of the
/// match, so a field never hides the one after it.
///
/// Groups: 1 the name's closing quote, 2 the `=` or `:`, 3 the value's
/// opening quote.
final _assignmentPattern = RegExp(
  r'''(\\?["']|%(?:25)?2[27])?\s*([=:]|%(?:25)?3[ADad])\s*(\\?["']|%(?:25)?2[27])?''',
);

/// What a payload is written with: hex, base64 and base64url, the
/// `txid:vout` list of a set of inputs, and their percent escapes. The run
/// may go past the payload into a field joined to it by `,` or `=`, never
/// short of it.
final _payloadValuePattern = RegExp(
  r'(?:[A-Za-z0-9+/=_.,:-]|\\/|%(?:25)?(?:2[B-Fb-f]|3[ADad]|5[Ff]))+',
);

/// The verb of a wallet request, up to the `,` its arguments follow.
final _walletRequestVerbPattern = RegExp(
  r'([a-z_]+)(?:(?::|%(?:25)?3a)ext)?(?=,|%(?:25)?2c)',
  caseSensitive: false,
);

/// The start of a bare `name: value` payload: 16 payload characters with a
/// digit among them. A word, a count or `null` has none or is shorter.
final _barePayloadPattern = RegExp(
  r'(?=[A-Za-z0-9+/=_.,:-]{16})[A-Za-z+/=_.,:-]{0,15}[0-9]',
);

/// Redacts the value of every transaction payload field in [value], and the
/// arguments of a wallet request along with everything after them: they
/// carry the PSBT or the message to sign, written as is or encoded, and no
/// pattern can tell where a message ends.
String _redactFields(String value) {
  final redacted = StringBuffer();
  var copied = 0;
  for (final run in _nameRunPattern.allMatches(value)) {
    if (run.start < copied) {
      // Inside a value already redacted.
      continue;
    }
    final name = _normalizedName(_fieldName(value, run));
    final isAction = name == 'action';
    if (!isAction && !_transactionPayloadKeys.contains(name)) {
      continue;
    }
    final assignment = _assignmentPattern.matchAsPrefix(value, run.end);
    if (assignment == null) {
      continue;
    }
    if (isAction) {
      final verb =
          _walletRequestVerbPattern.matchAsPrefix(value, assignment.end);
      if (verb != null &&
          !_publicActionVerbs.contains(verb[1]!.toLowerCase())) {
        redacted
          ..write(value.substring(copied, verb.end))
          ..write(redactedWalletRequest);
        return redacted.toString();
      }
      continue;
    }
    final end = _payloadEnd(value, assignment);
    if (end != null) {
      redacted
        ..write(value.substring(copied, assignment.end))
        ..write(redactedTransactionPayload);
      copied = end;
    }
  }
  redacted.write(value.substring(copied));
  return redacted.toString();
}

/// The field name [run] holds. A run right after a `%` starts with the rest
/// of a percent escape, such as the `26` of `%26`, which delimits the name
/// rather than being part of it.
String _fieldName(String value, Match run) {
  final name = run[0]!;
  if (run.start == 0 || value[run.start - 1] != '%') {
    return name;
  }
  final escape = _escapeTailPattern.matchAsPrefix(name);
  return escape == null ? name : name.substring(escape.end);
}

/// Where the payload that [assignment] assigns ends, or null when it assigns
/// none: nothing, `null`, or, for a bare `name: value` that could be prose, a
/// word or a count rather than a long run with digits in it.
///
/// A bare value is told from prose by its first characters only, so a long
/// run of prose is not read again for every payload name it holds.
int? _payloadEnd(String value, Match assignment) {
  final start = assignment.end;
  final isQuoted = assignment[1] != null || assignment[3] != null;
  final operator = assignment[2]!.toUpperCase();
  final isAssignedByEquals = operator == '=' || operator.endsWith('3D');
  if (!isQuoted &&
      !isAssignedByEquals &&
      _barePayloadPattern.matchAsPrefix(value, start) == null) {
    return null;
  }
  var end = _payloadValuePattern.matchAsPrefix(value, start)?.end ?? start;
  // A payload never ends with these; the sentence or list around it does.
  while (end > start && ',.:'.contains(value[end - 1])) {
    end--;
  }
  if (end == start ||
      (end - start == 4 &&
          value.substring(start, end).toLowerCase() == 'null')) {
    return null;
  }
  return end;
}

/// Transactions and PSBTs told by their content, under a name this file does
/// not know or under none, as in an object's `toString()`: a PSBT by its
/// magic bytes, in hex or base64, and a raw transaction by its version and a
/// length no hash or public key reaches.
final _payloadPatterns = [
  _afterEscape(r'70736274ff[0-9a-f]*', caseSensitive: false),
  _afterEscape(r'cHNidP8(?:[A-Za-z0-9+/=_-]|%(?:25)?(?:2[BbFf]|3[Dd]))*'),
  _afterEscape(r'0[1-3]000000[0-9a-f]{112,}', caseSensitive: false),
];

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
  _afterEscape('(?:bc1|tb1|bcrt1)[0-9a-z]{11,71}', caseSensitive: false):
      redactedWalletAddress,
  // Extended keys, BIP32 and the SLIP-132 variants: 111 Base58 characters.
  _afterEscape('(?:[xyzvutYZVU]pub|[xyzvutYZVU]prv)$_base58{107}'):
      redactedExtendedKey,
  // WIF private keys: 51 characters uncompressed, 52 compressed.
  _afterEscape('[59]$_base58{50}|[KLc]$_base58{51}'): redactedPrivateKey,
  // Base58Check addresses: P2PKH (1, m, n) and P2SH (3, 2).
  _afterEscape('[123mn]$_base58{25,62}'): redactedWalletAddress,
};

String sanitizeTelemetryText(String value) {
  var sanitized = _redactFields(value);
  for (final pattern in _payloadPatterns) {
    final source = sanitized;
    sanitized = source.replaceAllMapped(
      pattern,
      (match) => _startsInsideToken(source, match)
          ? match[0]!
          : '${match[1] ?? ''}$redactedTransactionPayload',
    );
  }
  for (final entry in _secretPatterns.entries) {
    final source = sanitized;
    sanitized = source.replaceAllMapped(entry.key, (match) {
      final escape = match[1] ?? '';
      final secret = match[0]!.substring(escape.length);
      if (_startsInsideToken(source, match) ||
          _endsInsideToken(source, match) ||
          _isHexadecimal(secret)) {
        return match[0]!;
      }
      return escape + entry.value;
    });
  }
  return sanitized;
}

/// Whether a match built by [_afterEscape] runs into the characters before
/// it. A percent escape matched in front of it counts as a delimiter.
bool _startsInsideToken(String value, Match match) =>
    match[1] == null &&
    match.start > 0 &&
    _isAsciiLetterOrDigit(value.codeUnitAt(match.start - 1));

bool _endsInsideToken(String value, Match match) =>
    match.end < value.length &&
    _isAsciiLetterOrDigit(value.codeUnitAt(match.end));

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
        _isTransactionPayloadKey(key) && _canBePayload(nestedValue)
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
          (_isTransactionPayloadKey(entry.key) &&
              _canBePayload(entry.value) &&
              entry.value != redactedTransactionPayload) ||
          containsWalletSecret(entry.key.toString()) ||
          containsWalletSecret(entry.value),
    );
  }
  if (value is Iterable) {
    return value.any(containsWalletSecret);
  }
  return containsWalletSecret(value.toString());
}
