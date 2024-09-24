import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/common/constants.dart';

void main() {
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
