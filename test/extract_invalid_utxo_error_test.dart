import 'package:test/test.dart';
import 'package:horizon/data/sources/repositories/compose_repository_impl.dart';

void main() {
  group('extractInvalidUtxoError', () {
    test('should extract valid UTXO error', () {
      const errorMessage =
          "invalid UTXO: f2acdf930aba15a10bc8bf4d92d6ac67291744e100f59d7486fc9fe45f9e714b:2";
      final result = extractInvalidUtxoError(errorMessage);

      result.fold(() {
        fail('Expected Some, but got None');
      }, (value) {
        expect(value.txHash,
            'f2acdf930aba15a10bc8bf4d92d6ac67291744e100f59d7486fc9fe45f9e714b');
        expect(value.outputIndex, 2);
      });
    });

    test('should handle error message with different output index', () {
      const errorMessage =
          "invalid UTXO: abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789:10";
      final result = extractInvalidUtxoError(errorMessage);

      expect(result.isSome(), true);
      result.fold(
        () => fail('Expected Some, but got None'),
        (value) {
          expect(value.txHash,
              'abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789');
          expect(value.outputIndex, 10);
        },
      );
    });

    test('should return None for non-matching error message', () {
      const errorMessage = "Some other error message";
      final result = extractInvalidUtxoError(errorMessage);

      expect(result.isNone(), true);
    });

    test('should return None for partially matching error message', () {
      const errorMessage = "invalid UTXO: not_a_valid_hash:2";
      final result = extractInvalidUtxoError(errorMessage);

      expect(result.isNone(), true);
    });
  });

  group('extractInvalidUtxoErrors', () {
    test('should extract single UTXO from new format', () {
      const errorMessage =
          'invalid UTXOs: 08077c3907cf14e037738d3d8a4d940e8366f8243799cb2838e577a727b4155e:0';
      final result = extractInvalidUtxoErrors(errorMessage);

      expect(result.isSome(), true);
      result.fold(
        () => fail('Expected Some, but got None'),
        (list) {
          expect(list.length, 1);
          expect(
            list[0].txHash,
            "08077c3907cf14e037738d3d8a4d940e8366f8243799cb2838e577a727b4155e",
          );
          expect(list[0].outputIndex, 0);
        },
      );
    });
    test('should extract multiple UTXOs from new format', () {
      const errorMessage =
          'invalid UTXOs: 08077c3907cf14e037738d3d8a4d940e8366f8243799cb2838e577a727b4155e:0, ' +
              '3f3417a5f6de20a1a14c32ca6989761c2b4be3196979de4ae990c09c3c41953d:0, ' +
              '3f4e1647673ef1cd77b50e7ac539137ced917c0b8a5b7d9f2c1a6f35b4890a59:1, ' +
              'b9e879d99e5aea8f1d414adf49bca6cbe3582c5d974eb40ef0e8074935548441:0';
      final result = extractInvalidUtxoErrors(errorMessage);

      expect(result.isSome(), true);
      result.fold(
        () => fail('Expected Some, but got None'),
        (list) {
          expect(list.length, 4);
          expect(
            list[0].txHash,
            "08077c3907cf14e037738d3d8a4d940e8366f8243799cb2838e577a727b4155e",
          );
          expect(list[0].outputIndex, 0);
          expect(
            list[1].txHash,
            "3f3417a5f6de20a1a14c32ca6989761c2b4be3196979de4ae990c09c3c41953d",
          );
          expect(list[1].outputIndex, 0);
          expect(list[2].txHash,
              "3f4e1647673ef1cd77b50e7ac539137ced917c0b8a5b7d9f2c1a6f35b4890a59");
          expect(list[2].outputIndex, 1);
          expect(list[3].txHash,
              "b9e879d99e5aea8f1d414adf49bca6cbe3582c5d974eb40ef0e8074935548441");
          expect(list[3].outputIndex, 0);
        },
      );
    });

    test('should fall back to single UTXO extraction on old format', () {
      const errorMessage =
          "invalid UTXO: f2acdf930aba15a10bc8bf4d92d6ac67291744e100f59d7486fc9fe45f9e714b:2";
      final result = extractInvalidUtxoErrors(errorMessage);

      expect(result.isSome(), true);
      result.fold(
        () => fail('Expected Some, but got None'),
        (list) {
          expect(list.length, 1);
          expect(list[0].txHash,
              'f2acdf930aba15a10bc8bf4d92d6ac67291744e100f59d7486fc9fe45f9e714b');
          expect(list[0].outputIndex, 2);
        },
      );
    });

    test('should return None for unrelated error message', () {
      const errorMessage = "Some unrelated error";
      final result = extractInvalidUtxoErrors(errorMessage);

      expect(result.isNone(), true);
    });

    test('should return None for invalid string in new format', () {
      const errorMessage = 'invalid UTXOs: INVALID';
      final result = extractInvalidUtxoErrors(errorMessage);

      expect(result.isNone(), true);
    });
  });
}
