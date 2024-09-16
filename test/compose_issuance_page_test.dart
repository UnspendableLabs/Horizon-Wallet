import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/presentation/screens/compose_issuance/view/compose_issuance_page.dart';

void main() {
  test('generateNumericAssetName produces valid numeric asset names', () {
    final min = BigInt.from(26).pow(12) + BigInt.one;
    final max = BigInt.from(256).pow(8);

    for (int i = 0; i < 50; i++) {
      final assetName = generateNumericAssetName();

      // Check if the asset name starts with 'A'
      expect(assetName.startsWith('A'), true);

      // Extract the numeric part and convert it to BigInt
      final numericPart = BigInt.parse(assetName.substring(1));

      // Check if the numeric part is within the valid range
      expect(numericPart >= min, true);
      expect(numericPart <= max, true);

      // Check if the numeric part is an integer (no decimal point)
      expect(assetName.contains('.'), false);
    }
  });

  test('generateNumericAssetName produces unique names', () {
    final nameSet = <String>{};
    for (int i = 0; i < 50; i++) {
      final assetName = generateNumericAssetName();
      nameSet.add(assetName);
    }

    // Check if all 50 generated names are unique
    expect(nameSet.length, 50);
  });

  group('DecimalTextInputFormatter', () {
    late DecimalTextInputFormatter formatter;

    setUp(() {
      formatter = DecimalTextInputFormatter(decimalRange: 8);
    });

    test('should allow input with less than or equal to 8 decimal places', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: ''),
        const TextEditingValue(text: '123.45678'),
      );
      expect(result.text, '123.45678');
    });

    test('should truncate input with more than 8 decimal places', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: ''),
        const TextEditingValue(text: '123.123456789012345'),
      );
      expect(result.text, '123.12345678');
    });

    test('should allow input without decimal point', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: ''),
        const TextEditingValue(text: '12345'),
      );
      expect(result.text, '12345');
    });

    test('should allow adding decimal point', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: '123'),
        const TextEditingValue(text: '123.'),
      );
      expect(result.text, '123.');
    });

    test('should handle multiple decimal points correctly', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: '123.45'),
        const TextEditingValue(text: '123.45.'),
      );
      expect(result.text, '123.45');
    });

    test('should not change input when removing characters', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: '123.45678'),
        const TextEditingValue(text: '123.4567'),
      );
      expect(result.text, '123.4567');
    });

    test('should throw assertion error when decimalRange is 0 or negative', () {
      expect(() => DecimalTextInputFormatter(decimalRange: 0),
          throwsAssertionError);
      expect(() => DecimalTextInputFormatter(decimalRange: -1),
          throwsAssertionError);
    });

    test('should not allow letters', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: '123.45'),
        const TextEditingValue(text: '123.45a'),
      );
      expect(result.text, '123.45');
    });

    test('should not allow symbols other than decimal point', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: '123.45'),
        const TextEditingValue(text: '123.45+'),
      );
      expect(result.text, '123.45');
    });

    test('should allow only one decimal point', () {
      var result = formatter.formatEditUpdate(
        const TextEditingValue(text: '123.45'),
        const TextEditingValue(text: '123.45.6'),
      );
      expect(result.text, '123.45');
    });

    test('should allow valid numeric input', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: ''),
        const TextEditingValue(text: '123.45'),
      );
      expect(result.text, '123.45');
    });

    test('should allow input to start with decimal point', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: ''),
        const TextEditingValue(text: '.5'),
      );
      expect(result.text, '.5');
    });
  });
}
