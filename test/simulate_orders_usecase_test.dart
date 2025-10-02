// test/simulate_orders_usecase_test.dart
import 'package:test/test.dart';
import 'package:decimal/decimal.dart';

import 'package:horizon/domain/usecases/simulate_orders.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/order.dart';
import 'package:horizon/domain/entities/simulated_order.dart';

/// ---------- helpers ----------
final BigInt _ten8 = BigInt.from(10).pow(8);

int _rawFromNorm(String norm, {required bool divisible}) {
  final Decimal d = Decimal.parse(norm);
  if (!divisible) return d.floor().toBigInt().toInt();
  return (d * Decimal.fromBigInt(_ten8)).toBigInt().toInt();
}

/// Build an Order from *normalized* values + divisibility flags.
/// Order rule: if an asset is divisible, raw quantity = normalized * 1e8.
Order _mkOrderNorm({
  required bool baseDivisible, // order.give
  required bool quoteDivisible, // order.get
  required String baseGiveN, // normalized base give total
  required String baseRemainN, // normalized base give remaining
  required String quoteGetN, // normalized quote get total
  String quoteRemainN = '0',
}) {
  return Order(
    txHash: '0xASK',
    source: 'SRC',
    giveAsset: 'BASE',
    giveQuantity: _rawFromNorm(baseGiveN, divisible: baseDivisible),
    giveRemaining: _rawFromNorm(baseRemainN, divisible: baseDivisible),
    getAsset: 'QUOTE',
    getQuantity: _rawFromNorm(quoteGetN, divisible: quoteDivisible),
    getRemaining: _rawFromNorm(quoteRemainN, divisible: quoteDivisible),
    expiration: 0,
    expireIndex: 0,
    feeRequired: 0,
    feeRequiredRemaining: 0,
    feeProvided: 0,
    feeProvidedRemaining: 0,
    status: 'open',
    givePrice: 0,
    getPrice: 0,
    confirmed: true,
    giveQuantityNormalized: baseGiveN,
    getQuantityNormalized: quoteGetN,
    getRemainingNormalized: quoteRemainN,
    giveRemainingNormalized: baseRemainN,
    feeProvidedNormalized: '0',
    feeRequiredNormalized: '0',
    feeRequiredRemainingNormalized: '0',
    feeProvidedRemainingNormalized: '0',
    givePriceNormalized: '0',
    getPriceNormalized: '0',
  );
}

AssetQuantity _aqFromNorm(String norm, {required bool divisible}) {
  final Decimal d = Decimal.parse(norm);
  if (!divisible) {
    return AssetQuantity(divisible: false, quantity: d.floor().toBigInt());
  }
  return AssetQuantity(
    divisible: true,
    quantity: (d * Decimal.fromBigInt(_ten8)).toBigInt(),
  );
}

BigInt _sumGive(Iterable<SimulatedOrder> xs) =>
    xs.fold<BigInt>(BigInt.zero, (a, x) => a + x.give.quantity);
BigInt _sumGet(Iterable<SimulatedOrder> xs) =>
    xs.fold<BigInt>(BigInt.zero, (a, x) => a + x.get.quantity);

String _label(bool baseD, bool quoteD) =>
    'base ${baseD ? "D" : "N"}, quote ${quoteD ? "D" : "N"}';

/// ---------- tests ----------
void main() {
  final useCase = SimulateOrdersUseCase();

  // Permutations: (baseDivisible, quoteDivisible)
  final perms = <(bool, bool)>[
    (true, true), // dd
    (true, false), // dn
    (false, true), // nd
    (false, false), // nn
  ];

  group('SimulateOrdersUseCase — permutation matrix', () {
    for (final (baseD, quoteD) in perms) {
      test('Exact fill @ price=2.0 — ${_label(baseD, quoteD)}', () {
        // Ask price = 2 quote/base. Give 10 base; get 20 quote.
        final ask = _mkOrderNorm(
          baseDivisible: baseD,
          quoteDivisible: quoteD,
          baseGiveN: '10',
          baseRemainN: '10',
          quoteGetN: '20',
        );

        // Taker: wants 10 base, has 20 quote.
        final takerGive = _aqFromNorm('20', divisible: quoteD);
        final takerGet = _aqFromNorm('10', divisible: baseD);

        final out = useCase(SimulateOrdersParams(
          asks: [ask],
          giveQuantity: takerGive,
          getQuantity: takerGet,
        ));

        expect(out.length, 1);
        expect(out.first, isA<SimulatedOrderMatch>());
        final m = out.first as SimulatedOrderMatch;

        // Raw conservation
        expect(m.give.quantity, takerGive.quantity);
        expect(m.get.quantity, takerGet.quantity);

        // Output flags mirror taker flags
        expect(m.give.divisible, quoteD);
        expect(m.get.divisible, baseD);
      });

      test(
          'Partial fill (escrow leftover) @ price=2.0 — ${_label(baseD, quoteD)}',
          () {
        // Ask has only 6 base remaining at price 2.0 → can sell 6 base for 12 quote
        final ask = _mkOrderNorm(
          baseDivisible: baseD,
          quoteDivisible: quoteD,
          baseGiveN: '6',
          baseRemainN: '6',
          quoteGetN: '12',
        );

        // Taker target 10 base, budget 20 quote
        final takerGive = _aqFromNorm('20', divisible: quoteD);
        final takerGet = _aqFromNorm('10', divisible: baseD);

        final out = useCase(SimulateOrdersParams(
          asks: [ask],
          giveQuantity: takerGive,
          getQuantity: takerGet,
        ));

        expect(out.length, 2);
        expect(out[0], isA<SimulatedOrderMatch>());
        expect(out[1], isA<SimulatedOrderCreate>());
        final m = out[0] as SimulatedOrderMatch;
        final c = out[1] as SimulatedOrderCreate;

        final sixBase = _aqFromNorm('6', divisible: baseD).quantity;
        final twelveQ = _aqFromNorm('12', divisible: quoteD).quantity;

        expect(m.get.quantity, sixBase);
        expect(m.give.quantity, twelveQ);

        // Escrow holds leftover give
        final leftover = takerGive.quantity - twelveQ;
        expect(c.give.quantity, leftover);
        expect(c.get.quantity, BigInt.zero);

        // Flags mirror taker flags
        expect(m.get.divisible, baseD);
        expect(m.give.divisible, quoteD);
        expect(c.get.divisible, baseD);
        expect(c.give.divisible, quoteD);

        // Invariants
        final matchedGive = _sumGive(out.whereType<SimulatedOrderMatch>());
        final escrowGive = _sumGive(out.whereType<SimulatedOrderCreate>());
        expect(matchedGive + escrowGive, takerGive.quantity);
        final matchedGet = _sumGet(out.whereType<SimulatedOrderMatch>());
        expect(matchedGet <= takerGet.quantity, isTrue);
      });

      test(
          'Price gate reject when tx0Price > tx1InversePrice — ${_label(baseD, quoteD)}',
          () {
        // Ask price = 3 quote/base (get 3 for give 1 base)
        final ask = _mkOrderNorm(
          baseDivisible: baseD,
          quoteDivisible: quoteD,
          baseGiveN: '10',
          baseRemainN: '10',
          quoteGetN: '30',
        );

        // Taker inverse price = give/get = 20/10 = 2 → ask is too expensive
        final takerGive = _aqFromNorm('20', divisible: quoteD);
        final takerGet = _aqFromNorm('10', divisible: baseD);

        final out = useCase(SimulateOrdersParams(
          asks: [ask],
          giveQuantity: takerGive,
          getQuantity: takerGet,
        ));

        // No matches; entire budget goes to escrow
        expect(out.length, 1);
        expect(out.first, isA<SimulatedOrderCreate>());
        final c = out.first as SimulatedOrderCreate;
        expect(c.give.quantity, takerGive.quantity);
        expect(c.get.quantity, BigInt.zero);
      });

      test(
          'Boundary: tx0Price == tx1InversePrice is accepted — ${_label(baseD, quoteD)}',
          () {
        // Price = 2.0; taker inverse also = 2.0 (give/get = 20/10)
        final ask = _mkOrderNorm(
          baseDivisible: baseD,
          quoteDivisible: quoteD,
          baseGiveN: '10',
          baseRemainN: '10',
          quoteGetN: '20',
        );
        final takerGive = _aqFromNorm('20', divisible: quoteD);
        final takerGet = _aqFromNorm('10', divisible: baseD);

        final out = useCase(SimulateOrdersParams(
          asks: [ask],
          giveQuantity: takerGive,
          getQuantity: takerGet,
        ));

        expect(out.length, 1);
        expect(out.first, isA<SimulatedOrderMatch>());
      });
    }
  });

  group('SimulateOrdersUseCase — multi-ask & sequencing', () {
    test('Accumulates across multiple asks until target reached', () {
      // Two asks at price 2.0: 4 base (→ 8 quote), then 10 base (→ 20 quote)
      final ask1 = _mkOrderNorm(
        baseDivisible: true,
        quoteDivisible: true,
        baseGiveN: '4',
        baseRemainN: '4',
        quoteGetN: '8',
      );
      final ask2 = _mkOrderNorm(
        baseDivisible: true,
        quoteDivisible: true,
        baseGiveN: '10',
        baseRemainN: '10',
        quoteGetN: '20',
      );

      final takerGive = _aqFromNorm('20', divisible: true); // quote
      final takerGet = _aqFromNorm('10', divisible: true); // base

      final out = useCase(SimulateOrdersParams(
        asks: [ask1, ask2],
        giveQuantity: takerGive,
        getQuantity: takerGet,
      ));

      // Fills 4 base from ask1 (8 quote), then 6 base from ask2 (12 quote)
      expect(out.length, 2);
      final m1 = out[0] as SimulatedOrderMatch;
      final m2 = out[1] as SimulatedOrderMatch;

      expect(m1.get.quantity, _aqFromNorm('4', divisible: true).quantity);
      expect(m1.give.quantity, _aqFromNorm('8', divisible: true).quantity);
      expect(m2.get.quantity, _aqFromNorm('6', divisible: true).quantity);
      expect(m2.give.quantity, _aqFromNorm('12', divisible: true).quantity);

      // Invariants
      final matchedGive = _sumGive(out);
      final matchedGet = _sumGet(out);
      expect(matchedGive, takerGive.quantity);
      expect(matchedGet, takerGet.quantity);
    });

    test('Sequencing: earlier ask too expensive, later ask acceptable', () {
      // First ask @ price 3.0 (rejected), second @ 2.0 (accepted)
      final expensive = _mkOrderNorm(
        baseDivisible: true,
        quoteDivisible: true,
        baseGiveN: '10',
        baseRemainN: '10',
        quoteGetN: '30',
      );
      final fair = _mkOrderNorm(
        baseDivisible: true,
        quoteDivisible: true,
        baseGiveN: '10',
        baseRemainN: '10',
        quoteGetN: '20',
      );

      final takerGive = _aqFromNorm('20', divisible: true);
      final takerGet = _aqFromNorm('10', divisible: true);

      final out = useCase(SimulateOrdersParams(
        asks: [expensive, fair],
        giveQuantity: takerGive,
        getQuantity: takerGet,
      ));

      expect(out.length, 1);
      final m = out.first as SimulatedOrderMatch;
      expect(m.give.quantity, takerGive.quantity);
      expect(m.get.quantity, takerGet.quantity);
    });
  });

  group('SimulateOrdersUseCase — rounding & edge cases', () {
    test(
        'Rational flooring: tiny budget at price=1.5 spends floor and escrows remainder',
        () {
      // Price = 1.5 quote/base (3/2). Budget 5 quote, target 3 base.
      final ask = _mkOrderNorm(
        baseDivisible: true, quoteDivisible: true,
        baseGiveN: '10', baseRemainN: '10',
        quoteGetN: '15', // 10 base ↔ 15 quote
      );

      final takerGive = _aqFromNorm('5', divisible: true);
      final takerGet = _aqFromNorm('3', divisible: true);

      final out = SimulateOrdersUseCase()(SimulateOrdersParams(
        asks: [ask],
        giveQuantity: takerGive,
        getQuantity: takerGet,
      ));

      // forward = min(10, floor(5 / 1.5)) = 3 base
      // backward = floor(3 * 1.5) = 4 quote
      expect(out.length, 2);
      final m = out[0] as SimulatedOrderMatch;
      final c = out[1] as SimulatedOrderCreate;

      expect(
          m.get.quantity, _aqFromNorm('3.33333333', divisible: true).quantity);
      expect(
          m.give.quantity, _aqFromNorm('4.99999999', divisible: true).quantity);
      expect(c.give.quantity, BigInt.one);
      expect(c.get.quantity, BigInt.zero);

      // Invariants
      final matchedGive = _sumGive(out.whereType<SimulatedOrderMatch>());
      final escrowGive = _sumGive(out.whereType<SimulatedOrderCreate>());
      expect(matchedGive + escrowGive, takerGive.quantity);
    });

    test('Ask with zero remaining is ignored', () {
      final zeroRemain = _mkOrderNorm(
        baseDivisible: true,
        quoteDivisible: true,
        baseGiveN: '10',
        baseRemainN: '0',
        quoteGetN: '20',
      );
      final usable = _mkOrderNorm(
        baseDivisible: true,
        quoteDivisible: true,
        baseGiveN: '5',
        baseRemainN: '5',
        quoteGetN: '10',
      );

      final takerGive = _aqFromNorm('10', divisible: true);
      final takerGet = _aqFromNorm('5', divisible: true);

      final out = SimulateOrdersUseCase()(SimulateOrdersParams(
        asks: [zeroRemain, usable],
        giveQuantity: takerGive,
        getQuantity: takerGet,
      ));

      expect(out.length, 1);
      final m = out.first as SimulatedOrderMatch;
      expect(m.get.quantity, _aqFromNorm('5', divisible: true).quantity);
      expect(m.give.quantity, _aqFromNorm('10', divisible: true).quantity);
    });

    test(
        'Conservation invariants hold under mixed rounding and multiple matches',
        () {
      // A mix of asks at 1.5 and 2.0
      final p15 = _mkOrderNorm(
        baseDivisible: true,
        quoteDivisible: true,
        baseGiveN: '3',
        baseRemainN: '3',
        quoteGetN: '4.5',
      );
      final p20 = _mkOrderNorm(
        baseDivisible: true,
        quoteDivisible: true,
        baseGiveN: '10',
        baseRemainN: '10',
        quoteGetN: '20',
      );

      final takerGive = _aqFromNorm('9', divisible: true);
      final takerGet = _aqFromNorm('7', divisible: true);

      final out = SimulateOrdersUseCase()(SimulateOrdersParams(
        asks: [p15, p20],
        giveQuantity: takerGive,
        getQuantity: takerGet,
      ));

      // Sum give (matches + escrow) equals initial give
      final matchedGive = _sumGive(out.whereType<SimulatedOrderMatch>());
      final escrowGive = _sumGive(out.whereType<SimulatedOrderCreate>());
      expect(matchedGive + escrowGive, takerGive.quantity);

      // Never exceed target get
      final matchedGet = _sumGet(out.whereType<SimulatedOrderMatch>());
      expect(matchedGet <= takerGet.quantity, isTrue);
    });
  });
}
