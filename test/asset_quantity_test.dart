// test/asset_quantity_price_test.dart
import 'package:test/test.dart';
import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';

import 'package:horizon/domain/entities/asset_quantity.dart';

void main() {
  final BigInt ten8 = BigInt.from(10).pow(8);

  // Small helpers for readability
  AssetQuantity D(int raw) =>
      AssetQuantity(divisible: true, quantity: BigInt.from(raw));
  AssetQuantity DN(BigInt raw) =>
      AssetQuantity(divisible: true, quantity: raw); // raw BigInt version
  AssetQuantity N(int raw) =>
      AssetQuantity(divisible: false, quantity: BigInt.from(raw));
  AssetQuantity Nn(BigInt raw) =>
      AssetQuantity(divisible: false, quantity: raw);

  group('AssetQuantity', () {
    test('construction, empty, equality', () {
      final a = AssetQuantity(divisible: true, quantity: BigInt.one);
      final b = AssetQuantity(divisible: true, quantity: BigInt.one);
      final c = AssetQuantity(divisible: false, quantity: BigInt.one);

      expect(a, equals(b));
      expect(a == c, isFalse);

      final emptyD = AssetQuantity.empty(divisible: true);
      final emptyN = AssetQuantity.empty(divisible: false);
      expect(emptyD.quantity, BigInt.zero);
      expect(emptyN.quantity, BigInt.zero);
    });

    test('toDecimal()', () {
      final a = DN(ten8 * BigInt.from(15) ~/ BigInt.from(10)); // 1.5e8 -> 1.5
      final b = N(3); // 3 -> 3
      expect(a.toDecimal(), Decimal.parse('1.5'));
      expect(b.toDecimal(), Decimal.parse('3'));
    });

    group('fromNormalizedString / fromNormalizedStringSafe', () {
      test('divisible: scales and ceils on remainder by default', () {
        final q = AssetQuantity.fromNormalizedString(
          divisible: true,
          input: '1.234567891', // 123456789.1 -> ceil -> 123456790
        );
        expect(q.divisible, isTrue);
        expect(q.quantity, BigInt.from(123456790));
      });

      test('divisible: can floor instead of ceil', () {
        final q = AssetQuantity.fromNormalizedString(
          divisible: true,
          input: '1.234567891', // -> floor -> 123456789
          ceilOnRemainder: false,
        );
        expect(q.quantity, BigInt.from(123456789));
      });

      test('non-divisible: floors to integer', () {
        final q = AssetQuantity.fromNormalizedString(
          divisible: false,
          input: '3.7',
        );
        expect(q.divisible, isFalse);
        expect(q.quantity, BigInt.from(3));
      });

      test('safe parsing returns Left on invalid input', () {
        final r = AssetQuantity.fromNormalizedStringSafe(
          divisible: true,
          input: 'not-a-number',
        );
        expect(r.isLeft(), isTrue);
      });

      test('safe parsing returns Right on valid input', () {
        final r = AssetQuantity.fromNormalizedStringSafe(
          divisible: false,
          input: '42',
        );
        expect(r.isRight(), isTrue);
        r.match(
          (l) => fail('expected Right'),
          (rq) {
            expect(rq.divisible, isFalse);
            expect(rq.quantity, BigInt.from(42));
          },
        );
      });
    });

    group('normalized / normalizedPretty', () {
      test('divisible normalizes with ceiling at precision', () {
        // raw 150_000_000 -> 1.5 exactly
        final q = DN(BigInt.from(150000000));
        expect(q.normalized(), '1.50000000');

        // pick a number that forces ceil on display (1/3)
        // raw ~ 0.33333333... at 8dp should ceil to 0.33333334
        final rawOneThird =
            (ten8 ~/ BigInt.from(3)); // floor(1e8/3) == 33333333
        final q2 = DN(rawOneThird); // slightly under true third
        expect(
            q2.normalized(), '0.33333333'); // because raw was already floored
        // If we bump 1 raw unit, normalized -> 0.33333334
        final q3 = DN(rawOneThird + BigInt.one);
        expect(q3.normalized(), '0.33333334');
      });

      test('normalizedPretty trims trailing zeros and dot', () {
        final q = DN(BigInt.from(123450000)); // 1.2345
        expect(q.normalizedPretty(), '1.2345');

        final q2 = DN(BigInt.from(300000000)); // 3.00000000 -> "3"
        expect(q2.normalizedPretty(), '3');

        final q3 = N(7);
        expect(q3.normalizedPretty(), '7'); // non-divisible unchanged
      });
    });

    test('map()', () {
      final q = D(5).map((x) => x * BigInt.from(2));
      expect(q.divisible, isTrue);
      expect(q.quantity, BigInt.from(10));
    });

    group('operators + and -', () {
      test('works for same divisibility', () {
        expect(D(2) + D(3), equals(D(5)));
        expect(N(10) - N(7), equals(N(3)));
      });

      test('throws for mixed divisibility', () {
        expect(() => D(1) + N(1), throwsArgumentError);
        expect(() => D(1) - N(1), throwsArgumentError);
      });
    });

    group('operator * (all combinations)', () {
      test('D * D -> D : (A * B) / 1e8', () {
        final left = DN(ten8 * BigInt.from(2)); // 2.0
        final right = DN(ten8 * BigInt.from(3)); // 3.0
        final res = left * right;
        expect(res.divisible, isTrue);
        expect(res.quantity, ten8 * BigInt.from(6)); // 6.0
      });

      test('D * N -> D : (A * B)', () {
        final left = DN(ten8 * BigInt.from(2)); // 2.0
        final right = N(3); // 3
        final res = left * right;
        expect(res.divisible, isTrue);
        expect(res.quantity, ten8 * BigInt.from(6));
      });

      test('N * D -> D : (A * B)', () {
        final left = N(2);
        final right = DN(ten8 * BigInt.from(3));
        final res = left * right;
        expect(res.divisible, isTrue);
        expect(res.quantity, ten8 * BigInt.from(6));
      });

      test('N * N -> N : (A * B)', () {
        final res = N(2) * N(3);
        expect(res.divisible, isFalse);
        expect(res.quantity, BigInt.from(6));
      });
    });

    group('operator / (ceil rules, always divisible)', () {
      test('D / D', () {
        final left = DN(ten8 * BigInt.from(3)); // 3.0
        final right = DN(ten8 * BigInt.from(2)); // 2.0
        final res = left / right;
        expect(res.divisible, isTrue);
        expect(res.quantity, BigInt.from(150000000)); // 1.5e8
        expect(res.normalized(), '1.50000000');
      });

      test('D / N', () {
        final left = DN(ten8 * BigInt.from(3)); // 3.0
        final right = N(2); // 2
        final res = left / right;
        expect(res.divisible, isTrue);
        expect(res.quantity, BigInt.from(150000000)); // ceil(3e8/2)
      });

      test('N / D', () {
        final left = N(3);
        final right = DN(ten8 * BigInt.from(2)); // 2.0
        final res = left / right;
        expect(res.divisible, isTrue);
        expect(res.quantity, BigInt.from(2)); // ceil((3*1e8)/(2e8)) = 2
        expect(res.normalized(), '0.00000002');
      });

      test('N / N', () {
        final left = N(3);
        final right = N(2);
        final res = left / right;
        expect(res.divisible, isTrue);
        expect(res.quantity, BigInt.from(150000000)); // ceil((3*1e8)/2)
      });

      test('division by zero -> 0 (divisible)', () {
        final res1 = D(10) / D(0);
        final res2 = N(5) / N(0);
        expect(res1.divisible, isTrue);
        expect(res2.divisible, isTrue);
        expect(res1.quantity, BigInt.zero);
        expect(res2.quantity, BigInt.zero);
      });
    });
  });

  group('MarketPair', () {
    test('scales reflect divisibility', () {
      final a = MarketPair(baseDivisible: true, quoteDivisible: false);
      final b = MarketPair(baseDivisible: false, quoteDivisible: true);
      final c = MarketPair(baseDivisible: true, quoteDivisible: true);
      final d = MarketPair(baseDivisible: false, quoteDivisible: false);

      expect(a.baseScale, ten8);
      expect(a.quoteScale, BigInt.one);

      expect(b.baseScale, BigInt.one);
      expect(b.quoteScale, ten8);

      expect(c.baseScale, ten8);
      expect(c.quoteScale, ten8);

      expect(d.baseScale, BigInt.one);
      expect(d.quoteScale, BigInt.one);
    });
  });

  group('Price', () {
    final dd = MarketPair(baseDivisible: true, quoteDivisible: true);
    final dn = MarketPair(baseDivisible: true, quoteDivisible: false);
    final nd = MarketPair(baseDivisible: false, quoteDivisible: true);
    final nn = MarketPair(baseDivisible: false, quoteDivisible: false);
    test('fromNormalized reduces exactly (no drift) across pair types', () {
      // dd: both divisible
      final pDD = Price.fromNormalized(
        pair: dd,
        quotePerBaseNormalized: Decimal.parse('1.5'), // 3/2
      );
      expect(pDD.numer, BigInt.from(3));
      expect(pDD.denom, BigInt.from(2));
      expect(pDD.normalized(), '1.50000000');

      // dn: base divisible, quote non-divisible
      final pDN = Price.fromNormalized(
        pair: dn,
        quotePerBaseNormalized: Decimal.parse('1.5'),
      );
      // n = 3 * 1 = 3, d = 2 * 1e8; gcd = 1 → unchanged
      expect(pDN.numer, BigInt.from(3));
      expect(pDN.denom, ten8 * BigInt.from(2));
      expect(pDN.normalized(), '1.50000000');

      // nd: base non-divisible, quote divisible
      final pND = Price.fromNormalized(
        pair: nd,
        quotePerBaseNormalized: Decimal.parse('1.5'),
      );
      // n = 3 * 1e8, d = 2 * 1 → gcd = 2 → (1.5e8 / 1)
      expect(pND.numer, ten8 * BigInt.from(3) ~/ BigInt.from(2)); // 150,000,000
      expect(pND.denom, BigInt.one);
      expect(pND.normalized(), '1.50000000');

      // nn: both non-divisible
      final pNN = Price.fromNormalized(
        pair: nn,
        quotePerBaseNormalized: Decimal.parse('1.5'),
      );
      // n = 3 * 1, d = 2 * 1; gcd = 1 → unchanged
      expect(pNN.numer, BigInt.from(3));
      expect(pNN.denom, BigInt.from(2));
      expect(pNN.normalized(), '1.50000000');
    });

    test('normalized uses ceiling at precision (e.g., 1/3)', () {
      final p = Price.fromNormalized(
        pair: dd,
        quotePerBaseNormalized: Decimal.parse('0.3333333333333333'),
      );
      // At 8 dp, should ceil to 0.33333334
      expect(p.normalized(), '0.33333334');
    });

    test('compareNormalized', () {
      final p1 = Price.fromNormalized(
          pair: dd, quotePerBaseNormalized: Decimal.parse('1.5'));
      final p2 = Price.fromNormalized(
          pair: dd, quotePerBaseNormalized: Decimal.parse('1.25'));
      expect(p1.compareNormalized(p2), greaterThan(0));
      expect(p2.compareNormalized(p1), lessThan(0));
      expect(p1.compareNormalized(p1), 0);
    });

    group('costForBase (quote for base)', () {
      test('happy path (ceil on remainder by default)', () {
        // Price = 3/2 quote per base (normalized 1.5)
        final price = Price.fromNormalized(
            pair: dd, quotePerBaseNormalized: Decimal.parse('1.5'));
        final baseAmt = DN(ten8 * BigInt.from(2)); // 2.0 base
        final quote = price.costForBase(baseAmt); // = 3.0 quote
        expect(quote.divisible, isTrue);
        expect(quote.quantity, ten8 * BigInt.from(3));
      });

      test('zero base -> zero quote', () {
        final price = Price.fromNormalized(
            pair: dn, quotePerBaseNormalized: Decimal.parse('2'));
        final baseAmt = DN(BigInt.zero); // base divisible
        final quote = price.costForBase(baseAmt);
        expect(quote.quantity, BigInt.zero);
        expect(quote.divisible, isFalse); // quoteDivisible=false in dn
      });

      test('throws if base divisibility mismatches pair', () {
        final price =
            Price.fromNormalized(pair: dn, quotePerBaseNormalized: Decimal.one);
        expect(() => price.costForBase(N(1)), throwsArgumentError);
      });

      test('floor mode (do not ceil)', () {
        // 1.5 * 1 raw base unit -> 1.5 -> floor = 1
        final price = Price.fromNormalized(
            pair: dd, quotePerBaseNormalized: Decimal.parse('1.5'));
        final baseAmt = DN(BigInt.one); // tiny base in raw units
        final quote = price.costForBase(baseAmt, ceilOnRemainder: false);
        expect(quote.quantity, BigInt.one); // floor(1.5) == 1 raw quote unit
      });
    });

    group('baseForQuote (base for quote budget)', () {
      test('happy path (floor by default)', () {
        // Price 3/2; 3 quote buys 2 base
        final price = Price.fromNormalized(
            pair: dd, quotePerBaseNormalized: Decimal.parse('1.5'));
        final budget = DN(ten8 * BigInt.from(3)); // 3.0 quote
        final base = price.baseForQuote(budget);
        expect(base.divisible, isTrue);
        expect(base.quantity, ten8 * BigInt.from(2)); // 2.0 base
      });

      test('zero quote -> zero base', () {
        final price = Price.fromNormalized(
            pair: nd, quotePerBaseNormalized: Decimal.parse('2'));
        final budget = DN(BigInt.zero); // quote divisible in nd
        final base = price.baseForQuote(budget);
        expect(base.quantity, BigInt.zero);
        expect(base.divisible, isFalse); // baseDivisible=false in nd
      });

      test('throws if quote divisibility mismatches pair', () {
        final price =
            Price.fromNormalized(pair: nd, quotePerBaseNormalized: Decimal.one);
        expect(() => price.baseForQuote(N(1)), throwsArgumentError);
      });

      test('ceil mode (ask for max base with rounding up)', () {
        // With small numerators/denominators, turning off floor yields >= floor
        final price = Price.fromNormalized(
            pair: dd, quotePerBaseNormalized: Decimal.parse('1.5'));
        final budget = DN(BigInt.from(1)); // 1 raw quote
        final baseFloor = price.baseForQuote(budget, floorResult: true);
        final baseCeil = price.baseForQuote(budget, floorResult: false);
        expect(baseCeil.quantity >= baseFloor.quantity, isTrue);
      });
    });

    test('invert swaps pair & flips fraction; normalized reciprocates', () {
      final p = Price.fromNormalized(
          pair: dd, quotePerBaseNormalized: Decimal.parse('2.5'));
      final inv = p.invert();

      // p = 2.5 -> inv normalized should be 0.4 (with ceiling at 8dp)
      expect(inv.pair.baseDivisible, dd.quoteDivisible);
      expect(inv.pair.quoteDivisible, dd.baseDivisible);
      expect(inv.normalized(), '0.40000000');

      // normalizedRational * inverse == 1 (within exact Rational arithmetic)
      final r = p.normalizedRational * inv.normalizedRational;
      expect(r, equals(Rational.one));
    });
  });
}
