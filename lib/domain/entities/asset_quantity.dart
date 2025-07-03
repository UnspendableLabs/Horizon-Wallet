import 'package:horizon/common/constants.dart';

class AssetQuantity {
  final bool divisible;
  final BigInt quantity;

  const AssetQuantity({
    required this.divisible,
    required this.quantity,
  });

  factory AssetQuantity.fromNormalizedString(
      {required bool divisible, required String input}) {





    try {
      if (divisible) {
        int quantity =
            (double.parse(input) * TenToTheEigth.doubleValue).round();


        print("input: $input");
        print("quantity: $quantity\n\n");

        return AssetQuantity(divisible: true, quantity: BigInt.from(quantity));
      } else {
        return AssetQuantity(divisible: false, quantity: BigInt.parse(input));
      }
    } catch (e) {
      print("has there been an error?");
      print(e);
      return AssetQuantity(divisible: divisible, quantity: BigInt.zero);
    }
  }

  String normalized({int precision = 8}) {
    if (divisible) {
      return (quantity / TenToTheEigth.bigIntValue).toStringAsFixed(precision);
    }
    return quantity.toString();
  }

  num normalizedNum({int precision = 8}) {
      return num.parse(normalized(precision: precision));
  }

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

  AssetQuantity operator -(AssetQuantity other) {
    if (divisible != other.divisible) {
      throw ArgumentError(
          'Cannot subtract AssetQuantity with different divisibility.');
    }
    return AssetQuantity(
      divisible: divisible,
      quantity: quantity - other.quantity,
    );
  }

  AssetQuantity operator *(BigInt multiplier) {
    return AssetQuantity(
      divisible: divisible,
      quantity: quantity * multiplier,
    );
  }
}
