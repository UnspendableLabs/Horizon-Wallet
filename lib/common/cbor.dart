// A small CBOR codec (RFC 8949), enough for the metadata of a Counterparty
// ordinals envelope: definite-length arrays, maps, byte and text strings,
// integers (as int, or BigInt beyond 64-bit signed), booleans, null, floats
// and tags. Integers and lengths are encoded in their shortest form, as cbor2
// and serde_cbor do, so re-encoding a decoded value gives the same bytes.

import 'dart:convert';
import 'dart:typed_data';

class CborException implements Exception {
  final String message;
  const CborException(this.message);

  @override
  String toString() => "CborException: $message";
}

/// A tagged value (major type 6).
class CborTag {
  final int tag;
  final Object? value;
  const CborTag(this.tag, this.value);
}

/// CBOR `undefined` (simple value 23).
class CborUndefined {
  const CborUndefined();
}

Object? cborDecode(Uint8List bytes) {
  final reader = _Reader(bytes);
  final value = reader.readValue();
  if (reader.offset != bytes.length) {
    throw const CborException("trailing bytes after the CBOR value");
  }
  return value;
}

Uint8List cborEncode(Object? value) {
  final out = BytesBuilder();
  _write(out, value);
  return out.toBytes();
}

final BigInt _two64 = BigInt.one << 64;

class _Reader {
  final Uint8List bytes;
  int offset = 0;
  _Reader(this.bytes);

  int _byte() {
    if (offset >= bytes.length) throw const CborException("unexpected end");
    return bytes[offset++];
  }

  Uint8List _take(int n) {
    if (offset + n > bytes.length) throw const CborException("unexpected end");
    final out = Uint8List.fromList(bytes.sublist(offset, offset + n));
    offset += n;
    return out;
  }

  /// The argument of a head byte, as a BigInt to hold 64-bit unsigned values.
  BigInt _argument(int info) {
    if (info < 24) return BigInt.from(info);
    final n = switch (info) {
      24 => 1,
      25 => 2,
      26 => 4,
      27 => 8,
      _ => throw CborException("unsupported additional information $info"),
    };
    var v = BigInt.zero;
    for (var i = 0; i < n; i++) {
      v = (v << 8) | BigInt.from(_byte());
    }
    return v;
  }

  Object? readValue() {
    final head = _byte();
    final major = head >> 5;
    final info = head & 0x1f;
    switch (major) {
      case 0:
        final v = _argument(info);
        return v.isValidInt ? v.toInt() : v;
      case 1:
        final v = -BigInt.one - _argument(info);
        return v.isValidInt ? v.toInt() : v;
      case 2:
        return _take(_length(info));
      case 3:
        return utf8.decode(_take(_length(info)));
      case 4:
        final n = _length(info);
        return [for (var i = 0; i < n; i++) readValue()];
      case 5:
        final n = _length(info);
        final map = <Object?, Object?>{};
        for (var i = 0; i < n; i++) {
          final k = readValue();
          map[k] = readValue();
        }
        return map;
      case 6:
        return CborTag(_argument(info).toInt(), readValue());
      case 7:
        switch (info) {
          case 20:
            return false;
          case 21:
            return true;
          case 22:
            return null;
          case 23:
            return const CborUndefined();
          case 25:
            return _halfToDouble(_take(2));
          case 26:
            return ByteData.sublistView(_take(4)).getFloat32(0);
          case 27:
            return ByteData.sublistView(_take(8)).getFloat64(0);
          default:
            throw CborException("unsupported simple value $info");
        }
    }
    throw CborException("unsupported major type $major");
  }

  int _length(int info) {
    if (info == 31) {
      throw const CborException("indefinite lengths are not supported");
    }
    final v = _argument(info);
    if (!v.isValidInt) throw const CborException("length too large");
    return v.toInt();
  }

  static double _halfToDouble(Uint8List b) {
    final half = (b[0] << 8) | b[1];
    final exp = (half >> 10) & 0x1f;
    final mant = half & 0x3ff;
    double val;
    if (exp == 0) {
      val = mant * (1 / 16777216); // 2^-24
    } else if (exp != 31) {
      val = (mant + 1024) * _pow2(exp - 25);
    } else {
      val = mant == 0 ? double.infinity : double.nan;
    }
    return (half & 0x8000) != 0 ? -val : val;
  }

  static double _pow2(int e) {
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
    case CborUndefined():
      out.addByte(0xf7);
    case bool b:
      out.addByte(b ? 0xf5 : 0xf4);
    case int i:
      _writeInt(out, BigInt.from(i));
    case BigInt i:
      _writeInt(out, i);
    case double d:
      out.addByte(0xfb);
      final data = ByteData(8)..setFloat64(0, d);
      out.add(data.buffer.asUint8List());
    case Uint8List b:
      _writeHead(out, 2, BigInt.from(b.length));
      out.add(b);
    case List<int> b:
      _writeHead(out, 2, BigInt.from(b.length));
      out.add(b);
    case String s:
      final encoded = utf8.encode(s);
      _writeHead(out, 3, BigInt.from(encoded.length));
      out.add(encoded);
    case List<Object?> l:
      _writeHead(out, 4, BigInt.from(l.length));
      for (final e in l) {
        _write(out, e);
      }
    case Map<Object?, Object?> m:
      _writeHead(out, 5, BigInt.from(m.length));
      for (final e in m.entries) {
        _write(out, e.key);
        _write(out, e.value);
      }
    case CborTag t:
      _writeHead(out, 6, BigInt.from(t.tag));
      _write(out, t.value);
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
