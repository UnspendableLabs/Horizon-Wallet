import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/common/cbor.dart';

Uint8List h(String s) => Uint8List.fromList(hex.decode(s));

String roundTrip(String encoded) =>
    hex.encode(cborEncode(cborDecode(h(encoded))));

void main() {
  // RFC 8949 appendix A examples that serde_cbor re-encodes unchanged
  final examples = <String, Object?>{
    "00": 0,
    "17": 23,
    "1818": 24,
    "18ff": 255,
    "190100": 256,
    "1a00010000": 65536,
    "1b0000000100000000": 4294967296,
    "1bffffffffffffffff": BigInt.parse("18446744073709551615"),
    "3bffffffffffffffff": BigInt.parse("-18446744073709551616"),
    "20": -1,
    "3863": -100,
    "3903e7": -1000,
    "f4": false,
    "f5": true,
    "f6": null,
    "60": "",
    "6161": "a",
    "6449455446": "IETF",
    "62c3bc": "ü",
    "40": Uint8List(0),
    "4401020304": Uint8List.fromList([1, 2, 3, 4]),
    "80": <Object?>[],
    "83010203": <Object?>[1, 2, 3],
    "8301820203820405": <Object?>[
      1,
      [2, 3],
      [4, 5]
    ],
    "fb3ff199999999999a": const CborFloat(1.1),
    "f93c00": const CborFloat(1.0),
    "f97bff": const CborFloat(65504.0),
    "fa47c35000": const CborFloat(100000.0),
  };

  test("decodes and re-encodes the RFC 8949 examples byte for byte", () {
    examples.forEach((encoded, value) {
      final decoded = cborDecode(h(encoded));
      expect(decoded, equals(value), reason: encoded);
      expect(hex.encode(cborEncode(decoded)), encoded, reason: encoded);
    });
  });

  test("keeps floats apart from integers", () {
    expect(cborDecode(h("f93c00")), isA<CborFloat>());
    expect(cborDecode(h("01")), isA<int>());
    expect(roundTrip("82f93c0001"), "82f93c0001");
  });

  test("packs floats into the shortest exact width, like serde_cbor", () {
    expect(hex.encode(cborEncode(const CborFloat(1.5))), "f93e00");
    expect(hex.encode(cborEncode(const CborFloat(-0.0))), "f98000");
    expect(hex.encode(cborEncode(const CborFloat(5.960464477539063e-8))),
        "f90001"); // smallest half subnormal
    expect(hex.encode(cborEncode(const CborFloat(100000.0))), "fa47c35000");
    expect(hex.encode(cborEncode(const CborFloat(3.4028234663852886e38))),
        "fa7f7fffff");
    expect(hex.encode(cborEncode(const CborFloat(0.1))), "fb3fb999999999999a");
    expect(
        hex.encode(cborEncode(const CborFloat(1e300))), "fb7e37e43c8800759c");
    expect(hex.encode(cborEncode(const CborFloat(double.infinity))), "f97c00");
    expect(hex.encode(cborEncode(const CborFloat(double.negativeInfinity))),
        "f9fc00");
    expect(hex.encode(cborEncode(const CborFloat(double.nan))), "f97e00");
    // a double precision encoding of a value half precision holds shrinks
    expect(roundTrip("fb3ff8000000000000"), "f93e00");
  });

  test("drops tags and reads undefined as null", () {
    expect(cborDecode(h("c11a514b67b0")), 1363896240);
    expect(roundTrip("d9d9f783010203"), "83010203");
    expect(cborDecode(h("f7")), isNull);
    expect(roundTrip("82f7f6"), "82f6f6");
  });

  test("accepts indefinite lengths and re-encodes them definite", () {
    expect(roundTrip("9f0102ff"), "820102");
    expect(roundTrip("5f42010243030405ff"), "450102030405");
    expect(roundTrip("7f657374726561646d696e67ff"), "6973747265616d696e67");
    expect(roundTrip("bf61610161629f0203ffff"), "a26161016162820203");
    expect(roundTrip("9fff"), "80");
  });

  test("re-encodes integers in their shortest form", () {
    expect(roundTrip("1800"), "00");
    expect(roundTrip("190017"), "17");
    expect(roundTrip("1b00000000000000ff"), "18ff");
    expect(roundTrip("3a00000000"), "20");
  });

  test("sorts and deduplicates maps like a BTreeMap<Value, Value>", () {
    // smaller major type first, integers by magnitude, strings by length
    // then bytes, anything else by its encoding; the last duplicate wins
    expect(
        roundTrip("a6"
            "626262"
            "01" // "bb": 1
            "6161"
            "02" // "a": 2
            "0a"
            "03" // 10: 3
            "20"
            "04" // -1: 4
            "01"
            "05" // 1: 5
            "6161"
            "07"), // "a": 7
        "a5"
        "0105"
        "0a03"
        "2004"
        "616107"
        "62626201");
    final map = cborDecode(h("a2616101616102")) as CborMap;
    expect(map.length, 1);
    expect(map["a"], 2);
    expect(map["b"], isNull);
  });

  test("orders values like serde_cbor", () {
    expect(cborCompare(1, 10), lessThan(0));
    expect(cborCompare(10, -1), lessThan(0)); // major type 0 before 1
    expect(cborCompare(-1, -100), lessThan(0)); // magnitude
    expect(cborCompare(Uint8List.fromList([9]), "a"), lessThan(0));
    expect(cborCompare("b", "aa"), lessThan(0)); // length first
    expect(cborCompare("ab", "aa"), greaterThan(0));
    expect(cborCompare(true, null), lessThan(0)); // f5 before f6
    expect(cborCompare(null, const CborFloat(1.5)), lessThan(0));
    expect(
        cborCompare(BigInt.parse("18446744073709551615"), 1), greaterThan(0));
    expect(cborCompare(<Object?>[1], <Object?>[1]), 0);
  });

  test("rejects what serde_cbor rejects", () {
    for (final bad in [
      "83010203ff", // trailing break
      "8301", // truncated array
      "1b00", // truncated argument
      "1c", "3f", "5c", "df", // unassigned additional information
      "f8", "f820", "e0", "fc", "ff", // reserved simple values, stray break
      "62c328", // invalid UTF-8
      "63eda080", // UTF-8 encoded surrogate
      "5f4101f6ff", // a non-string chunk in an indefinite string
      "5f5f4101ffff", // a nested indefinite chunk
      "7f4101ff", // a byte string chunk in a text string
      "0000", // trailing bytes
    ]) {
      expect(() => cborDecode(h(bad)), throwsA(isA<CborException>()),
          reason: bad);
    }
  });

  test("limits nesting to 127 levels", () {
    String nested(int depth) => "${"81" * depth}00";
    expect(cborDecode(h(nested(127))), isA<List>());
    expect(() => cborDecode(h(nested(128))), throwsA(isA<CborException>()));
    // tags count as a level too
    expect(() => cborDecode(h("${"81" * 127}c100")),
        throwsA(isA<CborException>()));
  });

  test("encodes a Counterparty issuance array like serde_cbor", () {
    // [asset_id, quantity, divisible, lock, reset, mime, description]
    final value = <Object?>[
      BigInt.parse("18446744073709551615"),
      100000000000,
      true,
      false,
      false,
      "text/plain",
      Uint8List.fromList("hello".codeUnits),
    ];
    expect(
        hex.encode(cborEncode(value)),
        "87" // array(7)
        "1bffffffffffffffff"
        "1b000000174876e800"
        "f5"
        "f4"
        "f4"
        "6a746578742f706c61696e"
        "4568656c6c6f");
  });
}
