import 'package:horizon/common/constants.dart';

class AssetQuantity {
  final bool divisible;
  final BigInt quantity;

  const AssetQuantity({
    required this.divisible,
    required this.quantity,
  });

// chat can this getter take decimal precision optionallyn?
  String normalized({int precision = 8}) {
    if (divisible) {
      return (quantity / TenToTheEigth.bigIntValue).toStringAsFixed(precision);
    }
    return quantity.toString();
  }

// chat can this getter take decimal precision optionallyn?
  String normalizedPretty({int precision = 8}) {
    return normalized(precision: precision).replaceFirst(RegExp(r'\.?0*$'), '');
  }
}

extension AssetQuantityOperators on AssetQuantity {
  AssetQuantity operator +(AssetQuantity other) {
    if (divisible != other.divisible) {
      throw ArgumentError(
          'Cannot add AssetQuantity with different divisibility.');
    }

    return AssetQuantity(
      divisible: divisible,
      quantity: quantity + other.quantity,
    );
  }
}
