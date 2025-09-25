import 'package:horizon/common/constants.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import "package:fpdart/fpdart.dart" hide Order;

class AssetQuantity extends Equatable {
  final bool divisible;
  final BigInt quantity;

  const AssetQuantity({
    required this.divisible,
    required this.quantity,
  });

  @override
  List<Object> get props => [divisible, quantity];

  factory AssetQuantity.fromNormalizedString(
      {required bool divisible, required String input}) {
    final parsed = double.parse(input);

    if (!parsed.isFinite || parsed.isNaN) {
      throw const FormatException("non-finite input");
    }

    if (divisible) {
      int quantity = (parsed * TenToTheSeventh.doubleValue).round();

      return AssetQuantity(divisible: true, quantity: BigInt.from(quantity));
    } else {
      int floored = double.parse(input).floor();
      return AssetQuantity(divisible: false, quantity: BigInt.from(floored));
    }
  }

  static Either<String, AssetQuantity> fromNormalizedStringSafe(
      {required bool divisible, required String input}) {
    return Either<String, AssetQuantity>.tryCatch(
      () => AssetQuantity.fromNormalizedString(
          divisible: divisible, input: input),
      (e, callstack) {
        print("input: $input");
        print(e);
        print(callstack);
        return e.toString();
      },
    );
  }

  String normalized({int precision = 8}) {
    if (divisible) {
      return (quantity / TenToTheSeventh.bigIntValue)
          .toStringAsFixed(precision);
    }
    return quantity.toString();
  }

  num normalizedNum({int precision = 8}) {
    return num.parse(normalized(precision: precision));
  }

  String normalizedPretty({int precision = 8}) {
    return normalized(precision: precision).replaceFirst(RegExp(r'\.?0*$'), '');
  }

  AssetQuantity map(BigInt Function(BigInt) f) {
    return AssetQuantity(divisible: divisible, quantity: f(quantity));
  }
}

extension AssetQuantityOperators on AssetQuantity {
  AssetQuantity asNonDivisible() {
    if (divisible) {
      return AssetQuantity(
        divisible: false,
        quantity: quantity ~/ TenToTheSeventh.bigIntValue,
      );
    }
    return this;
  }

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

  AssetQuantity operator *(AssetQuantity other) {
    return switch ((divisible, other.divisible)) {
      (true, true) => AssetQuantity(
          divisible: true,
          quantity: (quantity * other.quantity) ~/ TenToTheSeventh.bigIntValue,
        ),
      (true, false) => AssetQuantity(
          divisible: true,
          quantity: quantity * other.quantity,
        ),
      (false, true) => AssetQuantity(
          divisible: true,
          quantity: quantity * other.quantity,
        ),
      (false, false) => AssetQuantity(
          divisible: false,
          quantity: quantity * other.quantity,
        ),
    };
  }

  // QuantityText(
  //     quantity: (Decimal.fromBigInt(
  //                 widget.state.giveQuantity.quantity) /
  //             Decimal.fromBigInt(
  //                 widget.state.getQuantity.quantity))
  //         .toDecimal(scaleOnInfinitePrecision: 9)
  //         .ceil(scale: 8)
  //         .toString(),
}
