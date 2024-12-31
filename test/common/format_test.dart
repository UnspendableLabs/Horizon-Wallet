import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/common/format.dart';

void main() {
  group('satoshisToBtc', () {
    test('converts 100000000 satoshis to 1 BTC', () {
      expect(satoshisToBtc(100000000), Decimal.parse('1.0'));
    });

    test('converts 0 satoshis to 0 BTC', () {
      expect(satoshisToBtc(0), Decimal.parse('0.0'));
    });

    test('converts small amount of satoshis correctly', () {
      expect(satoshisToBtc(1), Decimal.parse('0.00000001'));
    });

    test('handles large numbers correctly', () {
      expect(satoshisToBtc(2100000000000000), Decimal.parse('21000000.0'));
    });

    test('rounds to 8 decimal places', () {
      // 1/3 of SATOSHI_RATE should give repeating decimals
      expect(
        satoshisToBtc(SATOSHI_RATE ~/ 3),
        Decimal.parse('0.33333333'),
      );
    });
  });

  group('quantityToQuantityNormalized', () {
    test('handles divisible assets correctly', () {
      expect(
        quantityToQuantityNormalized(
          quantity: 100000000,
          divisible: true,
        ),
        Decimal.parse('1.0'),
      );
    });

    test('handles non-divisible assets correctly', () {
      expect(
        quantityToQuantityNormalized(
          quantity: 100,
          divisible: false,
        ),
        Decimal.parse('100'),
      );
    });

    test('handles zero for both divisible and non-divisible', () {
      expect(
        quantityToQuantityNormalized(quantity: 0, divisible: true),
        Decimal.parse('0.0'),
      );
      expect(
        quantityToQuantityNormalized(quantity: 0, divisible: false),
        Decimal.parse('0'),
      );
    });

    test('handles small divisible quantities correctly', () {
      expect(
        quantityToQuantityNormalized(quantity: 1, divisible: true),
        Decimal.parse('0.00000001'),
      );
    });

    test('handles large quantities correctly', () {
      expect(
        quantityToQuantityNormalized(
          quantity: 1000000000,
          divisible: false,
        ),
        Decimal.parse('1000000000'),
      );
    });
  });

  group('getQuantityForDivisibility', () {
    test('handles divisible assets correctly', () {
      expect(
        getQuantityForDivisibility(
          divisible: true,
          inputQuantity: '1.0',
        ),
        100000000,
      );
      expect(
        getQuantityForDivisibility(
          divisible: true,
          inputQuantity: '0.00000001',
        ),
        1,
      );
    });

    test('handles non-divisible assets correctly', () {
      expect(
        getQuantityForDivisibility(
          divisible: false,
          inputQuantity: '100',
        ),
        100,
      );
      expect(
        getQuantityForDivisibility(
          divisible: false,
          inputQuantity: '1',
        ),
        1,
      );
    });

    test('handles zero for both types', () {
      expect(
        getQuantityForDivisibility(
          divisible: true,
          inputQuantity: '0',
        ),
        0,
      );
      expect(
        getQuantityForDivisibility(
          divisible: false,
          inputQuantity: '0',
        ),
        0,
      );
    });

    test('handles large numbers correctly', () {
      expect(
        getQuantityForDivisibility(
          divisible: true,
          inputQuantity: '21000000',
        ),
        2100000000000000,
      );
      expect(
        getQuantityForDivisibility(
          divisible: false,
          inputQuantity: '1000000',
        ),
        1000000,
      );
    });

    test('throws FormatException for invalid input', () {
      expect(
        () => getQuantityForDivisibility(
          divisible: true,
          inputQuantity: 'invalid',
        ),
        throwsFormatException,
      );
    });

    test('handles decimal string inputs correctly', () {
      expect(
        getQuantityForDivisibility(
          divisible: true,
          inputQuantity: '0.5',
        ),
        50000000,
      );
      expect(
        getQuantityForDivisibility(
          divisible: true,
          inputQuantity: '1.23456789',
        ),
        123456789,
      );
    });
  });

  group('quantityToQuantityNormalizedString', () {
    test('formats divisible assets correctly', () {
      expect(
        quantityToQuantityNormalizedString(
          quantity: 100000000,
          divisible: true,
        ),
        '1.00000000',
      );
    });

    test('formats non-divisible assets correctly', () {
      expect(
        quantityToQuantityNormalizedString(
          quantity: 100,
          divisible: false,
        ),
        '100',
      );
    });

    test('handles zero for both types', () {
      expect(
        quantityToQuantityNormalizedString(
          quantity: 0,
          divisible: true,
        ),
        '0.00000000',
      );
      expect(
        quantityToQuantityNormalizedString(
          quantity: 0,
          divisible: false,
        ),
        '0',
      );
    });

    test('formats small divisible quantities correctly', () {
      expect(
        quantityToQuantityNormalizedString(
          quantity: 1,
          divisible: true,
        ),
        '0.00000001',
      );
    });

    test('formats large quantities correctly', () {
      expect(
        quantityToQuantityNormalizedString(
          quantity: 2100000000000000,
          divisible: true,
        ),
        '21000000.00000000',
      );
      expect(
        quantityToQuantityNormalizedString(
          quantity: 1000000,
          divisible: false,
        ),
        '1000000',
      );
    });

    test('maintains 8 decimal places for divisible assets', () {
      expect(
        quantityToQuantityNormalizedString(
          quantity: SATOSHI_RATE ~/ 3,
          divisible: true,
        ),
        '0.33333333',
      );
    });
  });

  group('numberWithCommas', () {
    test('formats numbers with commas correctly', () {
      expect(numberWithCommas.format(1000), '1,000');
      expect(numberWithCommas.format(1000000), '1,000,000');
      expect(numberWithCommas.format(1234567), '1,234,567');
    });

    test('handles small numbers correctly', () {
      expect(numberWithCommas.format(0), '0');
      expect(numberWithCommas.format(100), '100');
      expect(numberWithCommas.format(999), '999');
    });

    test('handles negative numbers correctly', () {
      expect(numberWithCommas.format(-1000), '-1,000');
      expect(numberWithCommas.format(-1000000), '-1,000,000');
    });
  });
}
