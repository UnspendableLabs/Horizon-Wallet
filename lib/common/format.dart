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
