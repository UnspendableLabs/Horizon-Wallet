// A CBOR codec (RFC 8949) that round-trips values the way serde_cbor's
// `Value` does. The Counterparty parser rebuilds the message of an ordinals
// envelope by decoding its CBOR metadata into a `serde_cbor::Value` and
// encoding it again (`counterparty-rs/src/indexer/bitcoin_client.rs`), so the
// wallet must re-encode byte for byte like serde_cbor 0.11 (without the
// `tags` feature) to show the message the network will parse:
//
// * tags are dropped, `undefined` reads as null;
// * indefinite-length strings, arrays and maps are accepted and re-encoded
//   with a definite length;
// * maps are kept sorted and deduplicated by serde_cbor's canonical order
//   (the last duplicate wins), as a `BTreeMap<Value, Value>`;
// * integers are encoded in their shortest form, floats in the shortest
//   width that holds them exactly (half, single, then double precision);
// * nesting is limited to 127 levels, text must be valid UTF-8 and nothing
//   may follow the top-level value.

import 'dart:convert';
import 'dart:typed_data';

class CborException implements Exception {
  final String message;
  const CborException(this.message);

  @override
  String toString() => "CborException: $message";
}

/// A CBOR float, kept apart from integers: on the web a Dart `double` with an
/// integral value is also an `int`, and the two do not encode the same way.
class CborFloat {
  final double value;
  const CborFloat(this.value);

  @override
  bool operator ==(Object other) =>
      other is CborFloat &&
      (other.value == value || (other.value.isNaN && value.isNaN));

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => "CborFloat($value)";
}

/// A CBOR map as serde_cbor holds it: its entries sorted by [cborCompare],
/// one per key.
class CborMap {
  final List<MapEntry<Object?, Object?>> _entries = [];

  CborMap();

  /// The map of `entries`, the last of equal keys winning.
  factory CborMap.from(Iterable<MapEntry<Object?, Object?>> entries) {
    final map = CborMap();
    for (final e in entries) {
      map[e.key] = e.value;
    }
    return map;
  }

  List<MapEntry<Object?, Object?>> get entries => List.unmodifiable(_entries);

  int get length => _entries.length;

  /// The value of the key equal to `key` under [cborCompare], or null.
  Object? operator [](Object? key) {
    final i = _find(key);
    return i < _entries.length && cborCompare(_entries[i].key, key) == 0
        ? _entries[i].value
        : null;
  }

  /// Inserts `key`, or replaces the value of an equal key (keeping that key),
  /// like `BTreeMap::insert`.
  void operator []=(Object? key, Object? value) {
    final i = _find(key);
    if (i < _entries.length && cborCompare(_entries[i].key, key) == 0) {
      _entries[i] = MapEntry(_entries[i].key, value);
    } else {
      _entries.insert(i, MapEntry(key, value));
    }
  }

  /// The index of the first entry whose key is not below `key`.
  int _find(Object? key) {
    var lo = 0;
    var hi = _entries.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (cborCompare(_entries[mid].key, key) < 0) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }
}

/// Decodes one CBOR value, which must span all of `bytes`.
///
/// Integers come out as `int`, or `BigInt` when they do not fit one, floats
/// as [CborFloat], byte strings as `Uint8List`, text as `String`, arrays as
/// `List<Object?>`, maps as [CborMap], and null, `undefined` as null.
Object? cborDecode(Uint8List bytes) {
  final reader = _Reader(bytes);
  final value = reader.readValue();
  if (reader.offset != bytes.length) {
    throw const CborException("trailing bytes after the CBOR value");
  }
  return value;
}

/// Encodes `value` like serde_cbor encodes a `Value`. A `Map` is encoded as
/// the [CborMap] of its entries and a `double` as a [CborFloat].
Uint8List cborEncode(Object? value) {
  final out = BytesBuilder();
  _write(out, value);
  return out.toBytes();
}

/// serde_cbor's `Ord for Value`: the smaller major type first, then integers
/// by magnitude, byte and text strings, arrays and maps by length, strings
/// lexically, and anything else by its encoding.
int cborCompare(Object? a, Object? b) {
  final ma = _majorType(a);
  final mb = _majorType(b);
  if (ma != mb) return ma.compareTo(mb);
  switch ((a, b)) {
    case (int() || BigInt(), int() || BigInt()):
      return _toBigInt(a).abs().compareTo(_toBigInt(b).abs());
    case (Uint8List x, Uint8List y):
      return _compareBytes(x, y);
    case (String x, String y):
      return _compareBytes(Uint8List.fromList(utf8.encode(x)),
          Uint8List.fromList(utf8.encode(y)));
    case (List x, List y) when x.length != y.length:
      return x.length.compareTo(y.length);
    case (CborMap x, CborMap y) when x.length != y.length:
      return x.length.compareTo(y.length);
    case (Map x, Map y) when x.length != y.length:
      return x.length.compareTo(y.length);
  }
  return _compareBytes(cborEncode(a), cborEncode(b));
}

/// Length first, then lexical: the order of serde_cbor for byte and text
/// strings (a Rust slice comparison once the lengths are equal).
int _compareBytes(Uint8List a, Uint8List b) {
  if (a.length != b.length) return a.length.compareTo(b.length);
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return a[i].compareTo(b[i]);
  }
  return 0;
}

// `int` before `double`: on the web an integral double is also an int.
int _majorType(Object? v) => switch (v) {
      null || bool() || CborFloat() => 7,
      int i => i >= 0 ? 0 : 1,
      BigInt i => i >= BigInt.zero ? 0 : 1,
      double() => 7,
      Uint8List() => 2,
      String() => 3,
      List() => 4,
      CborMap() || Map() => 5,
      _ => throw CborException("cannot encode ${v.runtimeType}"),
    };

BigInt _toBigInt(Object? v) => v is BigInt ? v : BigInt.from(v as int);

final BigInt _two64 = BigInt.one << 64;

/// serde_cbor refuses a value nested deeper than this.
const int _maxDepth = 128;

class _Reader {
  final Uint8List bytes;
  int offset = 0;
  int _remainingDepth = _maxDepth;
  _Reader(this.bytes);

  int _byte() {
    if (offset >= bytes.length) throw const CborException("unexpected end");
    return bytes[offset++];
  }

  Uint8List _take(int n) {
    if (n > bytes.length - offset) {
      throw const CborException("unexpected end");
    }
    final out = Uint8List.fromList(bytes.sublist(offset, offset + n));
    offset += n;
    return out;
  }

  /// The argument of a head byte, as a BigInt to hold 64-bit unsigned values.
  /// Additional information 28 to 31 is not a definite argument.
  BigInt _argument(int info) {
    if (info < 24) return BigInt.from(info);
    final n = switch (info) {
      24 => 1,
      25 => 2,
      26 => 4,
      27 => 8,
      _ => throw CborException("unassigned additional information $info"),
    };
    var v = BigInt.zero;
    for (var i = 0; i < n; i++) {
      v = (v << 8) | BigInt.from(_byte());
    }
    return v;
  }

  int _length(int info) {
    final v = _argument(info);
    if (v > BigInt.from(bytes.length)) {
      throw const CborException("unexpected end");
    }
    return v.toInt();
  }

  T _nested<T>(T Function() read) {
    _remainingDepth -= 1;
    if (_remainingDepth == 0) {
      throw const CborException("recursion limit exceeded");
    }
    final v = read();
    _remainingDepth += 1;
    return v;
  }

  /// The chunks of an indefinite-length string of major type `major`, up to
  /// the break byte. Each chunk must be a definite string of the same type.
  Uint8List _indefiniteChunks(int major) {
    final out = BytesBuilder();
    while (true) {
      final head = _byte();
      if (head == 0xff) break;
      if (head >> 5 != major || (head & 0x1f) > 27) {
        throw const CborException("invalid chunk in an indefinite string");
      }
      out.add(_take(_length(head & 0x1f)));
    }
    return out.toBytes();
  }

  static String _utf8(Uint8List b) {
    try {
      return utf8.decode(b);
    } on FormatException {
      throw const CborException("invalid UTF-8 in a text string");
    }
  }

  Object? readValue() {
    final head = _byte();
    final major = head >> 5;
    final info = head & 0x1f;
    switch (major) {
      case 0:
        return _int(_argument(info));
      case 1:
        return _int(-BigInt.one - _argument(info));
      case 2:
        return info == 31 ? _indefiniteChunks(2) : _take(_length(info));
      case 3:
        return _utf8(info == 31 ? _indefiniteChunks(3) : _take(_length(info)));
      case 4:
        return _nested(() {
          final out = <Object?>[];
          if (info == 31) {
            while (!_atBreak()) {
              out.add(readValue());
            }
          } else {
            final n = _length(info);
            for (var i = 0; i < n; i++) {
              out.add(readValue());
            }
          }
          return out;
        });
      case 5:
        return _nested(() {
          final map = CborMap();
          if (info == 31) {
            while (!_atBreak()) {
              final k = readValue();
              map[k] = readValue();
            }
          } else {
            final n = _length(info);
            for (var i = 0; i < n; i++) {
              final k = readValue();
              map[k] = readValue();
            }
          }
          return map;
        });
      case 6:
        _argument(info);
        // serde_cbor without its `tags` feature keeps the tagged value only
        return _nested(readValue);
      default:
        switch (info) {
          case 20:
            return false;
          case 21:
            return true;
          case 22:
          case 23:
            return null;
          case 25:
            return CborFloat(_halfToDouble(_take(2)));
          case 26:
            return CborFloat(ByteData.sublistView(_take(4)).getFloat32(0));
          case 27:
            return CborFloat(ByteData.sublistView(_take(8)).getFloat64(0));
          default:
            throw CborException("unassigned simple value $info");
        }
    }
  }

  /// Consumes the break byte that ends an indefinite-length item, if it is
  /// next.
  bool _atBreak() {
    if (offset >= bytes.length) throw const CborException("unexpected end");
    if (bytes[offset] != 0xff) return false;
    offset += 1;
    return true;
  }

  static Object _int(BigInt v) => v.isValidInt ? v.toInt() : v;

  static double _halfToDouble(Uint8List b) {
    final half = (b[0] << 8) | b[1];
    final exp = (half >> 10) & 0x1f;
    final mant = half & 0x3ff;
    double val;
    if (exp == 0) {
      val = mant * _pow2(-24);
    } else if (exp != 31) {
      val = (mant + 1024) * _pow2(exp - 25);
    } else {
      val = mant == 0 ? double.infinity : double.nan;
    }
    return (half & 0x8000) != 0 ? -val : val;
  }
}

/// 2^e, exactly.
double _pow2(int e) {
  var v = 1.0;
  if (e >= 0) {
    for (var i = 0; i < e; i++) {
      v *= 2;
    }
  } else {
    for (var i = 0; i < -e; i++) {
      v /= 2;
    }
  }
  return v;
}

void _writeHead(BytesBuilder out, int major, BigInt argument) {
  final m = major << 5;
  if (argument < BigInt.from(24)) {
    out.addByte(m | argument.toInt());
  } else if (argument < BigInt.from(0x100)) {
    out.addByte(m | 24);
    out.addByte(argument.toInt());
  } else if (argument < BigInt.from(0x10000)) {
    out.addByte(m | 25);
    final v = argument.toInt();
    out.add([v >> 8, v & 0xff]);
  } else if (argument < BigInt.from(0x100000000)) {
    out.addByte(m | 26);
    final v = argument.toInt();
    out.add([(v >> 24) & 0xff, (v >> 16) & 0xff, (v >> 8) & 0xff, v & 0xff]);
  } else if (argument < _two64) {
    out.addByte(m | 27);
    var v = argument;
    final b = List<int>.filled(8, 0);
    for (var i = 7; i >= 0; i--) {
      b[i] = (v & BigInt.from(0xff)).toInt();
      v = v >> 8;
    }
    out.add(b);
  } else {
    throw const CborException("integer does not fit in 64 bits");
  }
}

void _write(BytesBuilder out, Object? value) {
  switch (value) {
    case null:
      out.addByte(0xf6);
    case bool b:
      out.addByte(b ? 0xf5 : 0xf4);
    case CborFloat f:
      _writeFloat(out, f.value);
    case int i:
      _writeInt(out, BigInt.from(i));
    case BigInt i:
      _writeInt(out, i);
    case double d:
      _writeFloat(out, d);
    case Uint8List b:
      _writeHead(out, 2, BigInt.from(b.length));
      out.add(b);
    case String s:
      final encoded = utf8.encode(s);
      _writeHead(out, 3, BigInt.from(encoded.length));
      out.add(encoded);
    case List l:
      _writeHead(out, 4, BigInt.from(l.length));
      for (final e in l) {
        _write(out, e);
      }
    case CborMap m:
      _writeHead(out, 5, BigInt.from(m.length));
      for (final e in m.entries) {
        _write(out, e.key);
        _write(out, e.value);
      }
    case Map m:
      _write(out, CborMap.from(m.entries));
    default:
      throw CborException("cannot encode ${value.runtimeType}");
  }
}

void _writeInt(BytesBuilder out, BigInt i) {
  if (i >= BigInt.zero) {
    _writeHead(out, 0, i);
  } else {
    _writeHead(out, 1, -BigInt.one - i);
  }
}

/// serde_cbor's `serialize_f64`: single precision when the value survives the
/// conversion, and from there half precision when that is exact too.
void _writeFloat(BytesBuilder out, double d) {
  if (d.isNaN) {
    out.add([0xf9, 0x7e, 0x00]);
    return;
  }
  if (d.isInfinite) {
    out.add(d > 0 ? [0xf9, 0x7c, 0x00] : [0xf9, 0xfc, 0x00]);
    return;
  }
  final single = ByteData(4)..setFloat32(0, d);
  if (single.getFloat32(0) != d) {
    final data = ByteData(8)..setFloat64(0, d);
    out.addByte(0xfb);
    out.add(data.buffer.asUint8List());
    return;
  }
  final half = _halfBits(d);
  if (half != null) {
    out.add([0xf9, half >> 8, half & 0xff]);
    return;
  }
  out.addByte(0xfa);
  out.add(single.buffer.asUint8List());
}

/// The IEEE 754 half precision bits of the finite `d`, or null when `d` is
/// not exactly representable in half precision.
int? _halfBits(double d) {
  final sign = d.isNegative ? 0x8000 : 0;
  final a = d.abs();
  if (a == 0) return sign;
  if (a > 65504) return null;
  if (a < _pow2(-14)) {
    final m = a / _pow2(-24);
    if (m != m.truncateToDouble()) return null;
    return sign | m.toInt();
  }
  var e = 15;
  while (_pow2(e) > a) {
    e -= 1;
  }
  final m = a / _pow2(e - 10);
  if (m != m.truncateToDouble()) return null;
  return sign | ((e + 15) << 10) | (m.toInt() - 1024);
}
