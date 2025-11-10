// scure_base.dart
// MIT License - Port of scure-base core utilities to Dart
// Original: (c) 2022 Paul Miller (paulmillr.com) — Port by ChatGPT for Dart

import 'dart:convert' show utf8, base64, base64Url;
import 'dart:typed_data';

/// Generic coder interface: encode(from) -> to, decode(to) -> from
abstract class Coder<F, T> {
  T encode(F from);
  F decode(T to);
}

abstract class BytesCoder extends Coder<Uint8List, String> {}

/// --- Type guards / assertions (runtime) ---

bool _isBytes(Object? a) => a is Uint8List;

Never _throw(String msg) => throw StateError(msg);

void _abytes(Uint8List? b) {
  if (!_isBytes(b)) _throw('Uint8List expected');
}

void _afn(Function? f) {
  if (f == null) _throw('function expected');
}

void _astr(String label, Object? s) {
  if (s is! String) _throw('$label: string expected');
}

void _anumber(num? n) {
  if (n == null || n is! int) _throw('invalid integer: $n');
}

void _aArr(List? a) {
  if (a is! List) _throw('array expected');
}

void _astrArr(String label, List<String>? a) {
  if (a == null || a.any((e) => e is! String))
    _throw('$label: array of strings expected');
}

void _anumArr(String label, List<int>? a) {
  if (a == null || a.any((e) => e is! int))
    _throw('$label: array of numbers expected');
}

/// --- chain(...) composition ---

class _ChainCoder<A, B> implements Coder<A, B> {
  final B Function(A) _enc;
  final A Function(B) _dec;
  _ChainCoder(this._enc, this._dec);
  @override
  B encode(A from) => _enc(from);
  @override
  A decode(B to) => _dec(to);
}

/// Compose coders left→right for decode, right→left for encode.
/// Example: chain([radix2(4), alphabet(...), join('')])
Coder<F, T> chain<F, T>(List<Coder<dynamic, dynamic>> coders) {
  // encode: last.encode(... first.encode(x))
  T enc(F input) {
    dynamic v = input;
    for (var i = coders.length - 1; i >= 0; i--) {
      v = coders[i].encode(v);
    }
    return v as T;
  }

  // decode: first.decode(... last.decode(x))
  F dec(T input) {
    dynamic v = input;
    for (var i = 0; i < coders.length; i++) {
      v = coders[i].decode(v);
    }
    return v as F;
  }

  return _ChainCoder<F, T>(enc, dec);
}

/// Varargs convenience.
Coder<F, T> chainArgs<F, T>(List<Coder<dynamic, dynamic>> coders) =>
    chain<F, T>(coders);

/// --- alphabet: int[] <-> string[] (mapping digits to letters) ---

Coder<List<int>, List<String>> alphabet(Object letters) {
  late final List<String> lettersA;
  if (letters is String) {
    lettersA = letters.split('');
  } else if (letters is List<String>) {
    lettersA = letters;
  } else {
    _throw('alphabet: string or List<String> expected');
  }
  _astrArr('alphabet', lettersA);
  final len = lettersA.length;
  final indexes = <String, int>{};
  for (var i = 0; i < len; i++) {
    indexes[lettersA[i]] = i;
  }
  return _ChainCoder<List<int>, List<String>>(
    (digits) {
      _aArr(digits);
      return digits.map((i) {
        if (i is! int || i < 0 || i >= len) {
          _throw(
              'alphabet.encode: digit index outside alphabet "$i". Allowed: $letters');
        }
        return lettersA[i];
      }).toList(growable: false);
    },
    (input) {
      _aArr(input);
      return input.map((s) {
        _astr('alphabet.decode', s);
        final idx = indexes[s]!;
        return idx;
      }).toList(growable: false);
    },
  );
}

/// --- join: string[] <-> string with separator ---

Coder<List<String>, String> join([String separator = '']) {
  _astr('join', separator);
  return _ChainCoder<List<String>, String>(
    (from) {
      _astrArr('join.encode', from);
      return from.join(separator);
    },
    (to) {
      _astr('join.decode', to);
      return to.split(separator);
    },
  );
}

/// --- padding for arrays of symbols (e.g. base32 words) ---

Coder<List<String>, List<String>> padding(int bits, [String chr = '=']) {
  _anumber(bits);
  _astr('padding', chr);
  return _ChainCoder<List<String>, List<String>>(
    (data) {
      _astrArr('padding.encode', data);
      final res = List<String>.from(data);
      while ((res.length * bits) % 8 != 0) res.add(chr);
      return res;
    },
    (input) {
      _astrArr('padding.decode', input);
      var end = input.length;
      if ((end * bits) % 8 != 0) {
        _throw('padding: invalid, string should have whole number of bytes');
      }
      for (; end > 0 && input[end - 1] == chr; end--) {
        final last = end - 1;
        final byte = last * bits;
        if (byte % 8 == 0)
          _throw('padding: invalid, string has too much padding');
      }
      return input.sublist(0, end);
    },
  );
}

/// --- normalize: pass-through encode, normalized decode ---

Coder<T, T> normalize<T>(T Function(T) fn) {
  _afn(fn);
  return _ChainCoder<T, T>((from) => from, (to) => fn(to));
}

/// --- convertRadix (O(n^2)) between arbitrary digit bases ---

List<int> convertRadix(List<int> data, int from, int to) {
  if (from < 2)
    _throw('convertRadix: invalid from=$from, base cannot be less than 2');
  if (to < 2)
    _throw('convertRadix: invalid to=$to, base cannot be less than 2');
  _aArr(data);
  if (data.isEmpty) return <int>[];
  var pos = 0;
  final res = <int>[];
  final digits = data.map((d) {
    _anumber(d);
    if (d < 0 || d >= from) _throw('invalid integer: $d');
    return d;
  }).toList();
  final dlen = digits.length;
  while (true) {
    var carry = 0;
    var done = true;
    for (var i = pos; i < dlen; i++) {
      final digit = digits[i];
      final digitBase = from * carry + digit;
      final div = digitBase ~/ to;
      carry = digitBase % to;
      digits[i] = div;
      if (!done) continue;
      if (div == 0) {
        pos = i;
      } else {
        done = false;
      }
    }
    res.add(carry);
    if (done) break;
  }
  for (var i = 0; i < data.length - 1 && data[i] == 0; i++) res.add(0);
  return res.reversed.toList(growable: false);
}

/// Helpers for power-of-two radix conversion
int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);
int _radix2carry(int from, int to) => from + (to - _gcd(from, to));

final List<int> _powers = List<int>.generate(40, (i) => 1 << i);

List<int> convertRadix2(List<int> data, int from, int to, bool padding) {
  _aArr(data);
  if (from <= 0 || from > 32) _throw('convertRadix2: wrong from=$from');
  if (to <= 0 || to > 32) _throw('convertRadix2: wrong to=$to');
  if (_radix2carry(from, to) > 32) {
    _throw(
        'convertRadix2: carry overflow from=$from to=$to carryBits=${_radix2carry(from, to)}');
  }
  var carry = 0;
  var pos = 0;
  final max = _powers[from];
  final mask = _powers[to] - 1;
  final res = <int>[];
  for (final n in data) {
    _anumber(n);
    if (n >= max) _throw('convertRadix2: invalid data word=$n from=$from');
    carry = (carry << from) | n;
    if (pos + from > 32)
      _throw('convertRadix2: carry overflow pos=$pos from=$from');
    pos += from;
    for (; pos >= to; pos -= to) {
      res.add((carry >> (pos - to)) & mask);
    }
    final pow = _powers[pos];
    if (pow == 0 && pos != 0) _throw('invalid carry');
    carry &= pow - 1;
  }
  carry = (carry << (to - pos)) & mask;
  if (!padding && pos >= from) _throw('Excess padding');
  if (!padding && carry > 0) _throw('Non-zero padding: $carry');
  if (padding && pos > 0) res.add(carry);
  return res;
}

/// --- radix: bytes <-> digits (arbitrary base) ---

Coder<Uint8List, List<int>> radix(int num) {
  _anumber(num);
  const _256 = 1 << 8;
  return _ChainCoder<Uint8List, List<int>>(
    (bytes) {
      if (!_isBytes(bytes)) _throw('radix.encode input should be Uint8List');
      return convertRadix(bytes.toList(growable: false), _256, num);
    },
    (digits) {
      _anumArr('radix.decode', digits);
      return Uint8List.fromList(convertRadix(digits, num, _256));
    },
  );
}

/// --- radix2: power-of-two base converter using convertRadix2 ---

Coder<Uint8List, List<int>> radix2(int bits, [bool revPadding = false]) {
  _anumber(bits);
  if (bits <= 0 || bits > 32) _throw('radix2: bits should be in (0..32]');
  if (_radix2carry(8, bits) > 32 || _radix2carry(bits, 8) > 32)
    _throw('radix2: carry overflow');
  return _ChainCoder<Uint8List, List<int>>(
    (bytes) {
      if (!_isBytes(bytes)) _throw('radix2.encode input should be Uint8List');
      return convertRadix2(bytes.toList(growable: false), 8, bits, !revPadding);
    },
    (digits) {
      _anumArr('radix2.decode', digits);
      return Uint8List.fromList(convertRadix2(digits, bits, 8, revPadding));
    },
  );
}

/// --- checksum wrapper (double-hash for Base58Check, etc.) ---

Coder<Uint8List, Uint8List> checksum(
    int len, Uint8List Function(Uint8List) fn) {
  _anumber(len);
  _afn(fn);
  return _ChainCoder<Uint8List, Uint8List>(
    (data) {
      if (!_isBytes(data)) _throw('checksum.encode: input should be Uint8List');
      final sum = fn(data).sublist(0, len);
      final out = Uint8List(data.length + len);
      out.setRange(0, data.length, data);
      out.setRange(data.length, data.length + len, sum);
      return out;
    },
    (data) {
      if (!_isBytes(data)) _throw('checksum.decode: input should be Uint8List');
      final payload = data.sublist(0, data.length - len);
      final oldChecksum = data.sublist(data.length - len);
      final newChecksum = fn(payload).sublist(0, len);
      for (var i = 0; i < len; i++) {
        if (newChecksum[i] != oldChecksum[i]) _throw('Invalid checksum');
      }
      return payload;
    },
  );
}

/// --- Built coders: Base16/32/64, Base58, Base58Check, Bech32/Bech32m, utf8, hex ---

// Base16 (RFC 4648)
final BytesCoder base16 = chain<Uint8List, String>([
  radix2(4),
  alphabet('0123456789ABCDEF'),
  join(''),
]) as BytesCoder;

// Base32 (RFC 4648, padded)
final BytesCoder base32 = chain<Uint8List, String>([
  radix2(5),
  alphabet('ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'),
  padding(5),
  join(''),
]) as BytesCoder;

// Base32 no pad
final BytesCoder base32nopad = chain<Uint8List, String>([
  radix2(5),
  alphabet('ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'),
  join(''),
]) as BytesCoder;

// Base32hex (padded)
final BytesCoder base32hex = chain<Uint8List, String>([
  radix2(5),
  alphabet('0123456789ABCDEFGHIJKLMNOPQRSTUV'),
  padding(5),
  join(''),
]) as BytesCoder;

// Base32hex no pad
final BytesCoder base32hexnopad = chain<Uint8List, String>([
  radix2(5),
  alphabet('0123456789ABCDEFGHIJKLMNOPQRSTUV'),
  join(''),
]) as BytesCoder;

// Base32 Crockford (upper, I/L -> 1, O -> 0)
final BytesCoder base32crockford = chain<Uint8List, String>([
  radix2(5),
  alphabet('0123456789ABCDEFGHJKMNPQRSTVWXYZ'),
  join(''),
  normalize<String>((s) =>
      s.toUpperCase().replaceAll('O', '0').replaceAll(RegExp(r'[IL]'), '1')),
]) as BytesCoder;

// Base64 (RFC 4648, padded)
final BytesCoder base64Std = _Base64(true, false);
final BytesCoder base64nopad = chain<Uint8List, String>([
  radix2(6),
  alphabet('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'),
  join(''),
]) as BytesCoder;

// Base64URL (padded)
final BytesCoder base64url = _Base64(true, true);
// Base64URL no pad
final BytesCoder base64urlnopad = chain<Uint8List, String>([
  radix2(6),
  alphabet('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'),
  join(''),
]) as BytesCoder;

/// Small adapter for built-in Base64
class _Base64 implements BytesCoder {
  final bool padded;
  final bool url;
  _Base64(this.padded, this.url);
  @override
  String encode(Uint8List from) {
    _abytes(from);
    final s = url ? base64Url.encode(from) : base64.encode(from);
    if (padded) return s;
    return s.replaceAll('=', '');
  }

  @override
  Uint8List decode(String to) {
    _astr('base64', to);
    try {
      if (url) {
        // Add padding if needed
        final pad = to.length % 4;
        final fixed = pad == 0 ? to : to + '=' * (4 - pad);
        return Uint8List.fromList(base64Url.decode(fixed));
      } else {
        return Uint8List.fromList(base64.decode(to));
      }
    } catch (_) {
      _throw('invalid base64');
    }
  }
}

/// Base58 family via radix(58) + alphabet + join
Coder<Uint8List, String> _genBase58(String abc) =>
    chain<Uint8List, String>([radix(58), alphabet(abc), join('')]);

final BytesCoder base58 =
    _genBase58('123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz')
        as BytesCoder;
final BytesCoder base58flickr =
    _genBase58('123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ')
        as BytesCoder;
final BytesCoder base58xrp =
    _genBase58('rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz')
        as BytesCoder;

/// Base58 XMR block coder
final BytesCoder base58xmr = _Base58Xmr();

class _Base58Xmr implements BytesCoder {
  static const _blockLen = [0, 2, 3, 5, 6, 7, 9, 10, 11];

  @override
  String encode(Uint8List data) {
    var res = StringBuffer();
    for (var i = 0; i < data.length; i += 8) {
      final block = data.sublist(i, (i + 8).clamp(0, data.length));
      final enc = base58.encode(block);
      res.write(enc.padLeft(_blockLen[block.length], '1'));
    }
    return res.toString();
  }

  @override
  Uint8List decode(String s) {
    var out = <int>[];
    for (var i = 0; i < s.length; i += 11) {
      final slice = s.substring(i, (i + 11).clamp(0, s.length));
      final blockLen = _blockLen.indexOf(slice.length);
      final block = base58.decode(slice);
      for (var j = 0; j < block.length - blockLen; j++) {
        if (block[j] != 0) _throw('base58xmr: wrong padding');
      }
      out.addAll(block.sublist(block.length - blockLen));
    }
    return Uint8List.fromList(out);
  }
}

/// Base58Check (supply sha256 function)
BytesCoder createBase58check(Uint8List Function(Uint8List) sha256) =>
    chain<Uint8List, String>([checksum(4, (d) => sha256(sha256(d))), base58])
        as BytesCoder;

/// --- Bech32 / Bech32m ---

class Bech32Decoded {
  final String prefix;
  final List<int> words;
  Bech32Decoded(this.prefix, this.words);
}

class Bech32DecodedWithArray extends Bech32Decoded {
  final Uint8List bytes;
  Bech32DecodedWithArray(String prefix, List<int> words, this.bytes)
      : super(prefix, words);
}

abstract class Bech32 {
  String encode(String prefix, List<int> words, {int? limit});
  Bech32Decoded decode(String str, {int? limit});
  String encodeFromBytes(String prefix, Uint8List bytes);
  Bech32DecodedWithArray decodeToBytes(String str);
  Bech32Decoded? decodeUnsafe(String str, {int? limit});
  Uint8List fromWords(List<int> words);
  Uint8List? fromWordsUnsafe(List<int> words);
  List<int> toWords(Uint8List bytes);
}

final _BECH_ALPHABET = chain<List<int>, String>([
  alphabet('qpzry9x8gf2tvdw0s3jn54khce6mua7l'),
  join(''),
]);

const _POLYMOD_GENERATORS = [
  0x3b6a57b2,
  0x26508e6d,
  0x1ea119fa,
  0x3d4233dd,
  0x2a1462b3
];

int _bech32Polymod(int pre) {
  final b = pre >> 25;
  var chk = (pre & 0x1ffffff) << 5;
  for (var i = 0; i < _POLYMOD_GENERATORS.length; i++) {
    if (((b >> i) & 1) == 1) chk ^= _POLYMOD_GENERATORS[i];
  }
  return chk;
}

String _bechChecksum(String prefix, List<int> words, int encodingConst) {
  final len = prefix.length;
  var chk = 1;
  for (var i = 0; i < len; i++) {
    final c = prefix.codeUnitAt(i);
    if (c < 33 || c > 126) _throw('Invalid prefix ($prefix)');
    chk = _bech32Polymod(chk) ^ (c >> 5);
  }
  chk = _bech32Polymod(chk);
  for (var i = 0; i < len; i++)
    chk = _bech32Polymod(chk) ^ (prefix.codeUnitAt(i) & 0x1f);
  for (final v in words) chk = _bech32Polymod(chk) ^ v;
  for (var i = 0; i < 6; i++) chk = _bech32Polymod(chk);
  chk ^= encodingConst;
  final sum = convertRadix2([chk % _powers[30]], 30, 5, false);
  return _BECH_ALPHABET.encode(sum);
}

Bech32 _genBech32(String encoding) {
  final encodingConst = encoding == 'bech32' ? 1 : 0x2bc830a3;
  final _words = radix2(5);
  Uint8List fromWords(List<int> w) => _words.decode(w);
  List<int> toWords(Uint8List b) => _words.encode(b);

  String encode(String prefix, List<int> words, {int? limit}) {
    _astr('bech32.encode prefix', prefix);
    _anumArr('bech32.encode', words);
    final plen = prefix.length;
    if (plen == 0) _throw('Invalid prefix length $plen');
    final actualLength = plen + 7 + words.length;
    final lim = limit ?? 90;
    if (lim != false && actualLength > lim) {
      _throw('Length $actualLength exceeds limit $lim');
    }
    final lowered = prefix.toLowerCase();
    final sum = _bechChecksum(lowered, words, encodingConst);
    return '$lowered${'1'}${_BECH_ALPHABET.encode(words)}$sum';
  }

  Bech32Decoded decode(String s, {int? limit}) {
    _astr('bech32.decode input', s);
    final slen = s.length;
    final lim = limit ?? 90;
    if (slen < 8 || (lim != false && slen > lim)) {
      _throw('invalid string length: $slen ($s). Expected (8..$lim)');
    }
    final lowered = s.toLowerCase();
    if (s != lowered && s != s.toUpperCase())
      _throw('String must be lowercase or uppercase');
    final sepIndex = lowered.lastIndexOf('1');
    if (sepIndex == 0 || sepIndex == -1)
      _throw('Letter "1" must be present between prefix and data only');
    final prefix = lowered.substring(0, sepIndex);
    final data = lowered.substring(sepIndex + 1);
    if (data.length < 6) _throw('Data must be at least 6 characters long');
    final words = (chain<String, List<int>>([
      // decode via BECH_ALPHABET (string->int[])
      _ReverseCoder<List<int>, String>(_BECH_ALPHABET)
    ]).encode(data) as List<int>)
        .sublist(0, data.length - 6);
    final sum = _bechChecksum(prefix, words, encodingConst);
    if (!data.endsWith(sum)) _throw('Invalid checksum in $s: expected "$sum"');
    return Bech32Decoded(prefix, words);
  }

  Bech32Decoded? decodeUnsafe(String s, {int? limit}) {
    try {
      return decode(s, limit: limit);
    } catch (_) {
      return null;
    }
  }

  Bech32DecodedWithArray decodeToBytes(String s) {
    final r = decode(s, limit: false);
    return Bech32DecodedWithArray(r.prefix, r.words, fromWords(r.words));
  }

  String encodeFromBytes(String prefix, Uint8List bytes) =>
      encode(prefix, toWords(bytes));

  return _Bech32Impl(
    encode: encode,
    decode: decode,
    decodeUnsafe: decodeUnsafe,
    decodeToBytes: decodeToBytes,
    encodeFromBytes: encodeFromBytes,
    fromWords: fromWords,
    fromWordsUnsafe: (w) {
      try {
        return fromWords(w);
      } catch (_) {
        return null;
      }
    },
    toWords: toWords,
  );
}

class _Bech32Impl implements Bech32 {
  final String Function(String, List<int>, {int? limit}) encode;
  final Bech32Decoded Function(String, {int? limit}) decode;
  final Bech32Decoded? Function(String, {int? limit}) decodeUnsafe;
  final Bech32DecodedWithArray Function(String) decodeToBytes;
  final String Function(String, Uint8List) encodeFromBytes;
  final Uint8List Function(List<int>) fromWords;
  final Uint8List? Function(List<int>) fromWordsUnsafe;
  final List<int> Function(Uint8List) toWords;
  _Bech32Impl({
    required this.encode,
    required this.decode,
    required this.decodeUnsafe,
    required this.decodeToBytes,
    required this.encodeFromBytes,
    required this.fromWords,
    required this.fromWordsUnsafe,
    required this.toWords,
  });
}

class _ReverseCoder<F, T> implements Coder<T, F> {
  final Coder<F, T> inner;
  _ReverseCoder(this.inner);
  @override
  F encode(T from) => inner.decode(from);
  @override
  T decode(F to) => inner.encode(to);
}

final Bech32 bech32 = _genBech32('bech32');
final Bech32 bech32m = _genBech32('bech32m');

/// --- utf8 coder (bytes<->string) ---

final BytesCoder utf8Coder = _Utf8Coder();

class _Utf8Coder implements BytesCoder {
  @override
  String encode(Uint8List data) => utf8.decode(data);
  @override
  Uint8List decode(String str) => Uint8List.fromList(utf8.encode(str));
}

/// --- hex coder (bytes<->lowercase hex string, strict even length) ---

final BytesCoder hex = _HexCoder();

class _HexCoder implements BytesCoder {
  static const _hexAlphabet = '0123456789abcdef';
  @override
  String encode(Uint8List data) {
    _abytes(data);
    final sb = StringBuffer();
    for (final b in data) {
      sb
        ..write(_hexAlphabet[(b >> 4) & 0xF])
        ..write(_hexAlphabet[b & 0xF]);
    }
    return sb.toString();
  }

  @override
  Uint8List decode(String s) {
    _astr('hex', s);
    if (s.length % 2 != 0) {
      throw ArgumentError(
          'hex.decode: expected even-length string, got ${s.length}');
    }
    final out = Uint8List(s.length ~/ 2);
    for (var i = 0; i < out.length; i++) {
      final hi = _hexValue(s.codeUnitAt(2 * i));
      final lo = _hexValue(s.codeUnitAt(2 * i + 1));
      out[i] = (hi << 4) | lo;
    }
    return out;
  }

  int _hexValue(int code) {
    if (code >= 0x30 && code <= 0x39) return code - 0x30; // 0-9
    if (code >= 0x41 && code <= 0x46) return code - 0x41 + 10; // A-F
    if (code >= 0x61 && code <= 0x66) return code - 0x61 + 10; // a-f
    throw ArgumentError('hex.decode: invalid char code $code');
  }
}

/// --- Convenience map (subset like original SomeCoders) ---

class SomeCoders {
  final BytesCoder utf8;
  final BytesCoder hex;
  final BytesCoder base16;
  final BytesCoder base32;
  final BytesCoder base64;
  final BytesCoder base64url;
  final BytesCoder base58;
  final BytesCoder base58xmr;
  const SomeCoders({
    required this.utf8,
    required this.hex,
    required this.base16,
    required this.base32,
    required this.base64,
    required this.base64url,
    required this.base58,
    required this.base58xmr,
  });
}

const _coderTypeError =
    'Invalid encoding type. Available: utf8, hex, base16, base32, base64, base64url, base58, base58xmr';

final CODERS = SomeCoders(
  utf8: utf8Coder,
  hex: hex,
  base16: base16,
  base32: base32,
  base64: base64Std,
  base64url: base64url,
  base58: base58,
  base58xmr: base58xmr,
);

/// --- (Optional) deprecated-style helpers like the TS version ---

String bytesToString(String type, Uint8List bytes) {
  final map = <String, BytesCoder>{
    'utf8': CODERS.utf8,
    'hex': CODERS.hex,
    'base16': CODERS.base16,
    'base32': CODERS.base32,
    'base64': CODERS.base64,
    'base64url': CODERS.base64url,
    'base58': CODERS.base58,
    'base58xmr': CODERS.base58xmr,
  };
  final coder = map[type];
  if (coder == null) _throw(_coderTypeError);
  if (!_isBytes(bytes)) _throw('bytesToString() expects Uint8List');
  return coder.encode(bytes);
}

Uint8List stringToBytes(String type, String s) {
  final map = <String, BytesCoder>{
    'utf8': CODERS.utf8,
    'hex': CODERS.hex,
    'base16': CODERS.base16,
    'base32': CODERS.base32,
    'base64': CODERS.base64,
    'base64url': CODERS.base64,
    'base58': CODERS.base58,
    'base58xmr': CODERS.base58xmr,
  };
  final coder = map[type];
  if (coder == null) _throw(_coderTypeError);
  if (s is! String) _throw('stringToBytes() expects string');
  return coder.decode(s);
}
