import "package:decimal/decimal.dart";
import 'package:intl/intl.dart';

Decimal satoshisToBtc(int satoshis) {
  // Conversion factor
  final Decimal btcFactor = Decimal.fromInt(100000000);

  // Perform conversion
  final btcValue = Decimal.fromInt(satoshis) / btcFactor;

  // Round to 8 decimal places
  return btcValue.toDecimal().round(scale: 8);
}

final numberWithCommas = NumberFormat('#,###');

Decimal quantityToQuantityNormalized(int quantity, bool divisible) {
  if (divisible) {
    final rational = Decimal.fromInt(quantity) / Decimal.fromInt(100000000);
    return rational.toDecimal().round(scale: 8);
  } else {
    return Decimal.fromInt(quantity);
  }
}
