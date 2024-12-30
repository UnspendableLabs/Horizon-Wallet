import "package:decimal/decimal.dart";
import 'package:intl/intl.dart';

// ignore: constant_identifier_names
const int SATOSHI_RATE = 100000000;

Decimal satoshisToBtc(int satoshis) {
  // Conversion factor
  final Decimal btcFactor = Decimal.fromInt(SATOSHI_RATE);

  // Perform conversion
  final btcValue = Decimal.fromInt(satoshis) / btcFactor;

  // Round to 8 decimal places
  return btcValue.toDecimal().round(scale: 8);
}

final numberWithCommas = NumberFormat('#,###');

Decimal quantityToQuantityNormalized(int quantity, bool divisible) {
  if (divisible) {
    final rational = Decimal.fromInt(quantity) / Decimal.fromInt(SATOSHI_RATE);
    return rational.toDecimal(scaleOnInfinitePrecision: 8);
  } else {
    return Decimal.fromInt(quantity);
  }
}

int getQuantityForDivisibility(bool divisible, String inputQuantity) {
  Decimal input = Decimal.parse(inputQuantity);
  int quantity;
  if (divisible) {
    quantity = (input * Decimal.fromInt(SATOSHI_RATE)).toBigInt().toInt();
  } else {
    quantity = input.toBigInt().toInt();
  }
  return quantity;
}

String quantityToQuantityNormalizedString(int quantity, bool divisible) {
  Decimal quantityNormalized =
      quantityToQuantityNormalized(quantity, divisible);
  if (divisible) {
    return quantityNormalized.toStringAsFixed(8);
  } else {
    return quantityNormalized.toString();
  }
}
