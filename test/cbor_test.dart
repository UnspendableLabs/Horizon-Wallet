import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/common/cbor.dart';

Uint8List h(String s) => Uint8List.fromList(hex.decode(s));

void main() {
  // RFC 8949 appendix A examples
  final examples = <String, Object?>{
    "00": 0,
    "17": 23,
    "1818": 24,
    "18ff": 255,
    "190100": 256,
    "1a00010000": 65536,
    "1b0000000100000000": 4294967296,
    "1bffffffffffffffff": BigInt.parse("18446744073709551615"),
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
    "a201020304": <Object?, Object?>{1: 2, 3: 4},
    "a26161016162820203": <Object?, Object?>{
      "a": 1,
      "b": [2, 3]
    },
    "fb3ff199999999999a": 1.1,
  };

  test("decodes and re-encodes the RFC 8949 examples byte for byte", () {
    examples.forEach((encoded, value) {
      final decoded = cborDecode(h(encoded));
      expect(decoded, equals(value), reason: encoded);
      expect(hex.encode(cborEncode(decoded)), encoded);
    });
  });

  test("decodes half and single precision floats", () {
    expect(cborDecode(h("f93e00")), 1.5);
    expect(cborDecode(h("f90000")), 0.0);
    expect(cborDecode(h("fa47c35000")), 100000.0);
  });

  test("keeps tags", () {
    final v = cborDecode(h("c11a514b67b0")) as CborTag;
    expect(v.tag, 1);
    expect(v.value, 1363896240);
    expect(hex.encode(cborEncode(v)), "c11a514b67b0");
  });

  test("rejects truncated, indefinite and trailing input", () {
    expect(() => cborDecode(h("83010203ff")), throwsA(isA<CborException>()));
    expect(() => cborDecode(h("8301")), throwsA(isA<CborException>()));
    expect(() => cborDecode(h("9f01ff")), throwsA(isA<CborException>()));
    expect(() => cborDecode(h("1b00")), throwsA(isA<CborException>()));
  });

  test("encodes a Counterparty issuance array like cbor2", () {
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
