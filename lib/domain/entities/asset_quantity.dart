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

class Price extends Equatable {
  final MarketPair pair;

  /// raw quote units per raw base unit (exact fraction)
  final BigInt numer; // raw quote
  final BigInt denom; // raw base  (must be > 0)

  Price({
    required this.pair,
    required this.numer,
    required this.denom,
  }) : assert(denom > BigInt.zero, 'denom must be > 0');

  @override
  List<Object?> get props => [pair, numer, denom];

  /// Exact normalized QUOTE/BASE as a rational
  Rational get normalizedRational =>
      Rational(numer, denom) * Rational(pair.baseScale, pair.quoteScale);

  /// Compare by normalized numeric value
  int compareNormalized(Price other) =>
      normalizedRational.compareTo(other.normalizedRational);

  /// Build a price from a normalized UI value (QUOTE per BASE in normalized units)
  /// WITHOUT truncation: lift to raw units exactly and reduce the fraction.
  factory Price.fromNormalized({
    required MarketPair pair,
    required Decimal quotePerBaseNormalized,
  }) {
    // Parse Decimal → Rational exactly (via string) to avoid binary/scale drift
    final Rational r = Rational.parse(quotePerBaseNormalized.toString());

    // Lift to raw units:
    //   raw = (r.numer / r.denom) * (quoteScale / baseScale)
    BigInt n = r.numerator * pair.quoteScale;
    BigInt d = r.denominator * pair.baseScale;

    // Reduce by gcd (nice to keep numbers small & comparisons fast)
    final BigInt g = n.gcd(d);
    n = n ~/ g;
    d = d ~/ g;

    return Price(pair: pair, numer: n, denom: d);
  }

  /// Normalized UI string (ceil at [precision] so you never under-quote in display)
  String normalized({int precision = 8}) {
    final Rational r =
        Rational(numer, denom) * Rational(pair.baseScale, pair.quoteScale);
    return r
        .toDecimal(scaleOnInfinitePrecision: precision + 1)
        .ceil(scale: precision)
        .toString();
  }

  /// QUOTE needed for a given BASE amount (both in raw units).
  /// Ceil by default to avoid underpaying.
  AssetQuantity costForBase(AssetQuantity baseAmount,
      {bool ceilOnRemainder = true}) {
    if (baseAmount.divisible != pair.baseDivisible) {
      throw ArgumentError('baseAmount.kind must match pair.base kind.');
    }
    if (baseAmount.quantity == BigInt.zero) {
      return AssetQuantity(
          divisible: pair.quoteDivisible, quantity: BigInt.zero);
    }
    final BigInt numerFull = baseAmount.quantity * numer; // base * numer
    final BigInt qRaw =
        ceilOnRemainder ? _ceilDiv(numerFull, denom) : (numerFull ~/ denom);
    return AssetQuantity(divisible: pair.quoteDivisible, quantity: qRaw);
  }

  /// BASE you can buy for a QUOTE budget (both in raw units).
  /// Floor by default (conservative received/base).
  AssetQuantity baseForQuote(AssetQuantity quoteBudget,
      {bool floorResult = true}) {
    if (quoteBudget.divisible != pair.quoteDivisible) {
      throw ArgumentError('quoteBudget.kind must match pair.quote kind.');
    }
    if (quoteBudget.quantity == BigInt.zero) {
      return AssetQuantity(
          divisible: pair.baseDivisible, quantity: BigInt.zero);
    }
    // baseRaw = floor_or_ceil( quoteRaw * denom / numer )
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

  // ---- helpers ----
  static BigInt _ceilDiv(BigInt a, BigInt b) =>
      a == BigInt.zero ? BigInt.zero : (a + b - BigInt.one) ~/ b;
}
