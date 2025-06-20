import 'package:horizon/common/constants.dart';

class AssetQuantity {
  final bool divisible;
  final BigInt quantity;

  const AssetQuantity({
    required this.divisible,
    required this.quantity,
  });

// chat can this getter take decimal precision optionallyn?
  String normalized({ int precision = 8 }) {
    if (divisible) {
      return (quantity / TenToTheEigth.bigIntValue).toStringAsFixed(precision);
    }
    return quantity.toString();
  }
}
