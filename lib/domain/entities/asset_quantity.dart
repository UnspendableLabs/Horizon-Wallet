import 'package:horizon/common/constants.dart';
import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';
import 'package:equatable/equatable.dart';
import "package:fpdart/fpdart.dart" hide Order;

import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import "package:fpdart/fpdart.dart" hide Order;

final BigInt kTen8 = TenToTheEigth.bigIntValue;

class AssetQuantity extends Equatable {
  final bool divisible;

  final BigInt quantity;

  const AssetQuantity({
    required this.divisible,
    required this.quantity,
  });

  @override
  List<Object> get props => [divisible, quantity];

  factory AssetQuantity.fromNormalizedString({
    required bool divisible,
    required String input,
    bool ceilOnRemainder = true,
  }) {
    final Decimal d = Decimal.parse(input.trim());

    if (divisible) {
      final Decimal scaled = d * Decimal.fromBigInt(kTen8);
      final BigInt floor = scaled.floor().toBigInt();
      final bool hasFrac = scaled != Decimal.fromBigInt(floor);
      final BigInt raw =
          hasFrac && ceilOnRemainder ? (floor + BigInt.one) : floor;
      return AssetQuantity(divisible: true, quantity: raw);
    } else {
      final BigInt intVal = Decimal.parse(input).floor().toBigInt();
      return AssetQuantity(divisible: false, quantity: intVal);
    }
  }

  static Either<String, AssetQuantity> fromNormalizedStringSafe({
    required bool divisible,
    required String input,
    bool ceilOnRemainder = true,
  }) {
    return Either<String, AssetQuantity>.tryCatch(
      () => AssetQuantity.fromNormalizedString(
        divisible: divisible,
        input: input,
        ceilOnRemainder: ceilOnRemainder,
      ),
      (e, stack) {
        return e.toString();
      },
    );
  }

  String normalized({int precision = 8}) {
    if (!divisible) return quantity.toString();
    final Rational out =
        Decimal.fromBigInt(quantity) / Decimal.fromBigInt(kTen8);
    return out
        .toDecimal(scaleOnInfinitePrecision: precision + 1)
        .ceil(scale: precision)
        .toString();
  }

  String normalizedPretty({int precision = 8}) {
    return normalized(precision: precision).replaceFirst(RegExp(r'\.?0*$'), '');
  }

  AssetQuantity map(BigInt Function(BigInt) f) =>
      AssetQuantity(divisible: divisible, quantity: f(quantity));
}

extension AssetQuantityOperators on AssetQuantity {
  AssetQuantity operator +(AssetQuantity other) {
    _checkSameDiv(other, 'add');
    return AssetQuantity(
        divisible: divisible, quantity: quantity + other.quantity);
  }

  AssetQuantity operator -(AssetQuantity other) {
    _checkSameDiv(other, 'subtract');
    return AssetQuantity(
        divisible: divisible, quantity: quantity - other.quantity);
  }

  /// Multiplication rules (resulting divisibility):
  /// - D * D -> D : (A * B) / 1e8
  /// - D * N -> D : (A * B)
  /// - N * D -> D : (A * B)
  /// - N * N -> N : (A * B)
  AssetQuantity operator *(AssetQuantity other) {
    return switch ((divisible, other.divisible)) {
      (true, true) => AssetQuantity(
          divisible: true,
          quantity: (quantity * other.quantity) ~/ kTen8,
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

  /// Division rules (always returns a **divisible** quantity with 8dp granularity),
  /// rounding **up** to avoid shortfall:
  /// - D / D -> D : ceil( (A * 1e8) / B )
  /// - D / N -> D : ceil( A / B )
  /// - N / D -> D : ceil( (A * 1e8) / B )
  /// - N / N -> D : ceil( (A * 1e8) / B )
  AssetQuantity operator /(AssetQuantity other) {
    if (other.quantity == BigInt.zero) {
      return AssetQuantity(divisible: true, quantity: BigInt.zero);
    }

    final bool aD = divisible;
    final bool bD = other.divisible;

    BigInt numer;
    BigInt denom;

    if (aD && bD) {
      numer = quantity * kTen8;
      denom = other.quantity;
    } else if (aD && !bD) {
      numer = quantity;
      denom = other.quantity;
    } else if (!aD && bD) {
      numer = quantity * kTen8;
      denom = other.quantity;
    } else {
      numer = quantity * kTen8;
      denom = other.quantity;
    }

    final BigInt q = _ceilDiv(numer, denom);
    return AssetQuantity(divisible: true, quantity: q);
  }

  // ---- helpers ----
  void _checkSameDiv(AssetQuantity other, String op) {
    if (divisible != other.divisible) {
      throw ArgumentError(
          'Cannot $op AssetQuantity with different divisibility.');
    }
  }

  /// Integer ceil(numer/denom), assumes denom > 0.
  BigInt _ceilDiv(BigInt numer, BigInt denom) {
    if (numer == BigInt.zero) return BigInt.zero;
    return (numer + denom - BigInt.one) ~/ denom;
  }
}

// -------------------------
// Markets & Prices
// -------------------------

/// A market pair: BASE/QUOTE (read “how many QUOTE for 1 BASE”).
class MarketPair extends Equatable {
  final bool baseDivisible;
  final bool quoteDivisible;

  const MarketPair({
    required this.baseDivisible,
    required this.quoteDivisible,
  });

  @override
  List<Object?> get props => [baseDivisible, quoteDivisible];

  BigInt get baseScale => baseDivisible ? kTen8 : BigInt.one;
  BigInt get quoteScale => quoteDivisible ? kTen8 : BigInt.one;
}

/// Price is QUOTE per BASE, measured in **raw units per raw unit**, as an exact rational.
/// i.e., quotePerBaseRaw = numer / denom = (raw quote) / (raw base)
class Price extends Equatable {
  final MarketPair pair;
  final BigInt numer; // raw quote units
  final BigInt denom; // raw base units (always > 0)

  Price({
    required this.pair,
    required this.numer,
    required this.denom,
  }) : assert(denom > BigInt.zero, 'denom must be > 0');

  @override
  List<Object?> get props => [pair, numer, denom];
  Rational get normalizedRational =>
      Rational(numer, denom) * Rational(pair.baseScale, pair.quoteScale);

  int compareNormalized(Price other) =>
      normalizedRational.compareTo(other.normalizedRational);

  /// Build a price from a normalized UI value:
  /// `quotePerBaseNormalized` = (normalized QUOTE) per 1 normalized BASE
  ///
  /// Conversion:
  /// raw ratio = (quotePerBaseNormalized * quoteScale) / baseScale
  /// Store as exact rational (numer/denom) by flooring numerator to integer raw units.
  factory Price.fromNormalized({
    required MarketPair pair,
    required Decimal quotePerBaseNormalized,
  }) {
    // Translate to raw-per-raw:
    // numerRaw = floor(quotePerBaseNormalized * quoteScale)
    final Decimal scaledQuote =
        quotePerBaseNormalized * Decimal.fromBigInt(pair.quoteScale);
    final BigInt numer = scaledQuote.floor().toBigInt();
    final BigInt denom =
        pair.baseScale; // per 1 normalized base -> divide by base scale
    // Reduce fraction (optional). We can leave unreduced to keep it cheap.
    return Price(pair: pair, numer: numer, denom: denom);
  }

  String normalized({int precision = 8}) {
    final Rational r =
        Rational(numer, denom) * Rational(pair.baseScale, pair.quoteScale);

    return r
        .toDecimal(scaleOnInfinitePrecision: precision + 1)
        .ceil(scale: precision)
        .toString();
  }

  /// Compute QUOTE amount for a given BASE amount (both raw).
  /// Rounds **up** to avoid underpay (esp. divisible quotes).
  AssetQuantity costForBase(AssetQuantity baseAmount,
      {bool ceilOnRemainder = true}) {
    if (baseAmount.divisible != pair.baseDivisible) {
      throw ArgumentError('baseAmount.kind must match pair.base kind.');
    }
    if (baseAmount.quantity == BigInt.zero) {
      return AssetQuantity(
          divisible: pair.quoteDivisible, quantity: BigInt.zero);
    }
    final BigInt numerFull = baseAmount.quantity * numer; // (raw base) * numer
    final BigInt qRaw =
        ceilOnRemainder ? _ceilDiv(numerFull, denom) : (numerFull ~/ denom);
    return AssetQuantity(divisible: pair.quoteDivisible, quantity: qRaw);
  }

  /// Compute BASE amount you can buy for a QUOTE budget.
  /// Rounds **down** by default (conservative).
  AssetQuantity baseForQuote(AssetQuantity quoteBudget,
      {bool floorResult = true}) {
    if (quoteBudget.divisible != pair.quoteDivisible) {
      throw ArgumentError('quoteBudget.kind must match pair.quote kind.');
    }
    if (quoteBudget.quantity == BigInt.zero) {
      return AssetQuantity(
          divisible: pair.baseDivisible, quantity: BigInt.zero);
    }
    // baseRaw = (quoteRaw * denom) / numer
    final BigInt numerFull = quoteBudget.quantity * denom;
    final BigInt bRaw =
        floorResult ? (numerFull ~/ numer) : _ceilDiv(numerFull, numer);
    return AssetQuantity(divisible: pair.baseDivisible, quantity: bRaw);
  }

  /// Invert price to get BASE per QUOTE (swap pair and flip fraction).
  Price invert() => Price(
        pair: MarketPair(
          baseDivisible: pair.quoteDivisible,
          quoteDivisible: pair.baseDivisible,
        ),
        numer: denom,
        denom: numer,
      );

  // helper
  static BigInt _ceilDiv(BigInt numer, BigInt denom) {
    if (numer == BigInt.zero) return BigInt.zero;
    return (numer + denom - BigInt.one) ~/ denom;
  }
}
