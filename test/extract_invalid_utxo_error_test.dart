import 'package:test/test.dart';
import 'package:horizon/data/sources/repositories/compose_repository_impl.dart';


void main() {
  group('extractInvalidUtxoError', () {
    test('should extract valid UTXO error', () {
      final errorMessage =
          "invalid UTXO: f2acdf930aba15a10bc8bf4d92d6ac67291744e100f59d7486fc9fe45f9e714b:2";
      final result = extractInvalidUtxoError(errorMessage);

      result.fold(() {
        fail('Expected None, but got Some');
      }, (value) {
        expect(value.txHash,
            'f2acdf930aba15a10bc8bf4d92d6ac67291744e100f59d7486fc9fe45f9e714b');
        expect(value.outputIndex, 2);
      });
    });

    test('should handle error message with different output index', () {
      final errorMessage =
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
      final errorMessage = "Some other error message";
      final result = extractInvalidUtxoError(errorMessage);

      expect(result.isNone(), true);
    });

    test('should return None for partially matching error message', () {
      final errorMessage = "invalid UTXO: not_a_valid_hash:2";
      final result = extractInvalidUtxoError(errorMessage);

      expect(result.isNone(), true);
    });

  });
}

