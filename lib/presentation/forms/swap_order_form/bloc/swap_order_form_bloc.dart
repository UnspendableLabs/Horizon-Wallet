import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:formz/formz.dart';
import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/order.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/simulated_order.dart';
import 'package:horizon/domain/usecases/simulate_orders.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/order_repository.dart';
import 'package:horizon/common/constants.dart';

bool inferDivisible({required BigInt raw, required String normalized}) {
  final Decimal dNorm = Decimal.parse(normalized.trim());
  final Decimal dRaw = Decimal.fromBigInt(raw);
  return dNorm != dRaw;
}

MarketPair pairFor({required Asset base, required Asset quote}) =>
    MarketPair(baseDivisible: base.divisible, quoteDivisible: quote.divisible);

Price priceFromNormalized({
  required MarketPair pair,
  required Decimal quotePerBaseNormalized,
}) =>
    Price.fromNormalized(
        pair: pair, quotePerBaseNormalized: quotePerBaseNormalized);

String rationalCeilToString(Rational r, {int precision = 8}) => r
    .toDecimal(scaleOnInfinitePrecision: precision + 1)
    .ceil(scale: precision)
    .toString();

Rational rationalDiv(String a, String b) =>
    (Decimal.parse(a) / Decimal.parse(b)) as Rational;

Rational adjustForDivisibility(Rational amount,
    {required bool fromDivisible, required bool toDivisible}) {
  if (fromDivisible && !toDivisible) {
    return amount / TenToTheEigth.rational;
  } else if (!fromDivisible && toDivisible) {
    return amount * TenToTheEigth.rational;
  } else {
    return amount;
  }
}

Rational rationalMinList(List<Rational> values) {
  if (values.isEmpty) throw ArgumentError('List cannot be empty');
  return values.reduce((a, b) => a < b ? a : b);
}

Rational toRawUnits(Rational quantity, bool divisible) =>
    divisible ? quantity * Rational(TenToTheEigth.bigIntValue) : quantity;

enum AmountInputError { required }

class AmountInput extends FormzInput<String, AmountInputError> {
  const AmountInput.pure() : super.pure("");
  const AmountInput.dirty({
    required String value,
  }) : super.dirty(value);
  @override
  AmountInputError? validator(String value) {
    return value.isEmpty ? AmountInputError.required : null;
  }
}

enum PriceInputError { required }

class PriceInput extends FormzInput<String, PriceInputError> {
  const PriceInput.pure() : super.pure("");
  const PriceInput.dirty({
    required String value,
  }) : super.dirty(value);
  @override
  PriceInputError? validator(String value) {
    return value.isEmpty ? PriceInputError.required : null;
  }
}

enum PriceInputAsRationalError { isZero, isNegative }

class PriceInputAsRational
    extends FormzInput<Rational, PriceInputAsRationalError> {
  PriceInputAsRational.pure() : super.pure(Rational.zero);
  const PriceInputAsRational.dirty({
    required Rational value,
  }) : super.dirty(value);
  @override
  PriceInputAsRationalError? validator(Rational value) {
    if (value == Rational.zero) {
      return PriceInputAsRationalError.isZero;
    }
    if (value < Rational.zero) {
      return PriceInputAsRationalError.isNegative;
    }
    return null;
  }
}

enum GiveQuantityInputError { required, insufficientBalance }

class GiveQuantityInput
    extends FormzInput<AssetQuantity, GiveQuantityInputError> {
  final AssetQuantity userBalance;

  GiveQuantityInput.pure({
    required this.userBalance,
  }) : super.pure(AssetQuantity(divisible: true, quantity: BigInt.zero));

  const GiveQuantityInput.dirty({
    required AssetQuantity value,
    required this.userBalance,
  }) : super.dirty(value);

  @override
  GiveQuantityInputError? validator(AssetQuantity value) {
    return value.quantity > userBalance.quantity
        ? GiveQuantityInputError.insufficientBalance
        : value.quantity == BigInt.zero
            ? GiveQuantityInputError.required
            : null;
  }
}

enum GetQuantityAsRationalError { mustBeInt }

class GetQuantityAsRationalInput
    extends FormzInput<Rational, GetQuantityAsRationalError> {
  final bool divisible;
  // Use const only if FormzInput.pure is const in your Formz version.
  GetQuantityAsRationalInput.pure({required this.divisible})
      : super.pure(Rational.zero);

  // Use const only if FormzInput.dirty is const in your Formz version.
  const GetQuantityAsRationalInput.dirty({
    required Rational value,
    required this.divisible,
  }) : super.dirty(value);

  @override
  GetQuantityAsRationalError? validator(Rational value) {
    // If non-divisible, the value must be an integer.
    if (!divisible && !value.isInteger) {
      return GetQuantityAsRationalError.mustBeInt;
    }
    return null;
  }
}

enum GetQuantityInputError { required }

class GetQuantityInput
    extends FormzInput<AssetQuantity, GetQuantityInputError> {
  GetQuantityInput.pure({required bool divisible})
      : super.pure(AssetQuantity(divisible: divisible, quantity: BigInt.zero));

  const GetQuantityInput.dirty({
    required AssetQuantity value,
  }) : super.dirty(value);

  @override
  GetQuantityInputError? validator(AssetQuantity value) {
    if (value.quantity == BigInt.zero) {
      return GetQuantityInputError.required;
    }
    return null;
  }
}

enum OrderViewModelSide { buy, sell }

class SimulatedOrders {
  Asset getAsset;
  Asset giveAsset;
  List<SimulatedOrder> orders;

  SimulatedOrders(
      {required this.orders, required this.getAsset, required this.giveAsset});

  @override
  String toString() {
    return 'SimulatedOrders(orders: $orders)';
  }

  SimulatedOrderSummary get summary {
    final totalGive = orders.fold(
      AssetQuantity(divisible: giveAsset.divisible, quantity: BigInt.zero),
      (prev, order) => prev + order.give,
    );

    final giveNow = orders.whereType<SimulatedOrderMatch>().fold(
          AssetQuantity(divisible: giveAsset.divisible, quantity: BigInt.zero),
          (prev, order) => prev + order.give,
        );

    final giveEscrow = orders.whereType<SimulatedOrderCreate>().fold(
        AssetQuantity(divisible: giveAsset.divisible, quantity: BigInt.zero),
        (prev, order) => prev + order.give);

    final getNow = orders.whereType<SimulatedOrderMatch>().fold(
          AssetQuantity(divisible: getAsset.divisible, quantity: BigInt.zero),
          (prev, order) => prev + order.get,
        );

    return SimulatedOrderSummary(
      totalGive: totalGive,
      giveNow: giveNow,
      giveEscrow: giveEscrow,
      getNow: getNow,
    );
  }
}

// 2 * 1 = 2
// 3 * 1.25 =  3.75
// escrowed = .5

class OrderViewModel {
  final OrderViewModelSide side;
  final AssetQuantity quantity;
  final Price price;
  final Price invertedPrice;
  OrderViewModel(
      {required this.invertedPrice,
      required this.side,
      required this.quantity,
      required this.price});
}

extension OrderViewModelExtension on Order {
  OrderViewModel toViewModel({required OrderViewModelSide side}) {
    // Your existing rule:
    // - BUY row displays price as get / give
    // - SELL row displays price as give / get
    final bool baseIsGive = (side == OrderViewModelSide.buy);

    final String baseAsset = baseIsGive ? giveAsset : getAsset;
    final String quoteAsset = baseIsGive ? getAsset : giveAsset;

    final bool giveAssetDivisible = inferDivisible(
        raw: BigInt.from(giveQuantity), normalized: giveQuantityNormalized);

    final bool getAssetDivisible = inferDivisible(
        raw: BigInt.from(getQuantity), normalized: giveQuantityNormalized);

    final bool baseAssetDivisible =
        baseIsGive ? giveAssetDivisible : getAssetDivisible;

    final bool quoteAssetDivisible =
        baseIsGive ? getAssetDivisible : giveAssetDivisible;

// Infer divisibility from the order’s own quantities
    final MarketPair displayedPair = MarketPair(
      baseDivisible: baseAssetDivisible,
      quoteDivisible: quoteAssetDivisible,
    );

    // exact normalized ratio as Rational
    final Rational normRatio = baseIsGive
        ? (Decimal.parse(getQuantityNormalized) /
            Decimal.parse(giveQuantityNormalized))
        : (Decimal.parse(giveQuantityNormalized) /
            Decimal.parse(getQuantityNormalized));

    // Build Price from normalized value
    final Price price = Price.fromNormalized(
      pair: displayedPair,
      quotePerBaseNormalized: normRatio.toDecimal(scaleOnInfinitePrecision: 20),
    );

    final Price inverted = price.invert();

    // keep your existing remaining quantity on the "give" side
    final AssetQuantity qty = AssetQuantity(
      divisible: giveAssetDivisible,
      quantity: BigInt.from(giveRemaining),
    );

    return OrderViewModel(
      side: side,
      quantity: qty,
      price: price,
      invertedPrice: inverted,
    );
  }
}

// extension OrderViewModelExtension on Order {
//   OrderViewModel toViewModel({
//     required OrderViewModelSide side,
//   }) {
//     final divisible = giveQuantity != double.parse(giveQuantityNormalized);
//
//     int price = side == OrderViewModelSide.buy
//         ? (double.parse(getQuantityNormalized) /
//                 double.parse(giveQuantityNormalized) *
//                 TenToTheEigth.doubleValue)
//             .round()
//         : (double.parse(giveQuantityNormalized) /
//                 double.parse(getQuantityNormalized) *
//                 TenToTheEigth.doubleValue)
//             .round();
//
//     int invertedPrice = side == OrderViewModelSide.buy
//         ? (double.parse(giveQuantityNormalized) /
//                 double.parse(getQuantityNormalized) *
//                 TenToTheEigth.doubleValue)
//             .round()
//         : (double.parse(getQuantityNormalized) /
//                 double.parse(giveQuantityNormalized) *
//                 TenToTheEigth.doubleValue)
//             .round();
//
//     return OrderViewModel(
//       side: side,
//       quantity: AssetQuantity(
//           divisible: divisible, quantity: BigInt.from(giveRemaining)),
//       invertedPrice: AssetQuantity(
//         divisible: divisible,
//         quantity: BigInt.from(invertedPrice),
//       ),
//       price: AssetQuantity(
//         divisible: true,
//         quantity: BigInt.from(price),
//       ),
//     );
//   }
// }

class SwapOrderFormModel with FormzMixin {
  final RemoteData<SimulatedOrders> simulatedOrders;

  final MultiAddressBalanceEntry giveAssetBalance;

  final Asset giveAsset;
  final Asset getAsset;

  final List<Order> asks;
  final List<Order> bids;

  final AmountType amountType;
  final PriceType priceType;

  final AmountInput amountInput;
  final PriceInput priceInput;
  final PriceInputAsRational priceInputAsRational;

  final Option<DateTime> expiry;

  const SwapOrderFormModel({
    required this.expiry,
    required this.simulatedOrders,
    required this.giveAssetBalance,
    required this.amountInput,
    required this.priceInput,
    required this.amountType,
    required this.giveAsset,
    required this.getAsset,
    required this.asks,
    required this.bids,
    required this.priceType,
    required this.priceInputAsRational,
  });

  bool get hasBuyOrders => asks.isNotEmpty;
  MarketPair get _displayedPair => priceType == PriceType.give
      ? MarketPair(
          baseDivisible: getAsset.divisible,
          quoteDivisible: giveAsset.divisible,
        )
      : MarketPair(
          baseDivisible: giveAsset.divisible,
          quoteDivisible: getAsset.divisible,
        );

  Price? get _currentPriceOrNull {
    final r = priceInputAsRational.value;
    if (r == Rational.zero) return null;
    return Price.fromNormalized(
      pair: _displayedPair,
      // carry high precision, UI formatting happens elsewhere
      quotePerBaseNormalized: r.toDecimal(scaleOnInfinitePrecision: 30),
    );
  }

  AssetQuantity _parseAmountFieldAsQuantity() {
    final isDiv = amountType == AmountType.give
        ? giveAsset.divisible
        : getAsset.divisible;

    final parsed = AssetQuantity.fromNormalizedStringSafe(
      divisible: isDiv,
      input: amountInput.value.isEmpty ? "0" : amountInput.value,
    ).getOrElse((_) => AssetQuantity(divisible: isDiv, quantity: BigInt.zero));

    return parsed;
  }

  AssetQuantity giveAssetQuantityWhenAmountGet({required Rational price}) {
    final desiredGetAmount = toRawUnits(
      Rational.tryParse(amountInput.value) ?? Rational.zero,
      getAsset.divisible,
    );

    Rational rational = adjustForDivisibility(desiredGetAmount * price,
        fromDivisible: getAsset.divisible, toDivisible: giveAsset.divisible);

    if (giveAsset.divisible) {
      return AssetQuantity(
          divisible: giveAsset.divisible, quantity: rational.toBigInt());
    } else {
      return AssetQuantity(
          divisible: giveAsset.divisible, quantity: rational.ceil());
    }
  }

  GiveQuantityInput get giveQuantityInput {
    final userBalance = AssetQuantity(
        divisible: giveAsset.divisible,
        quantity: BigInt.from(giveAssetBalance.quantity));

    return simulatedOrders.fold3(
        onNone: () => GiveQuantityInput.pure(userBalance: userBalance),
        onFailure: (_) => GiveQuantityInput.pure(userBalance: userBalance),
        onReplete: (summary) {
          // for (var order in summary.orders) {
          //   print("simulated order: $order");
          // }
          // print(
          //     "giveQuantityInput: totalGive = ${summary.summary.totalGive}, userBalance = $userBalance");
          return GiveQuantityInput.dirty(
              value: summary.summary.totalGive, userBalance: userBalance);
        });
  }

  GetQuantityAsRationalInput get getQuantityInputRational {
    final give = giveQuantityInput.value;

    final price = priceInputAsRational.value;

    if (price == Rational.zero) {
      return GetQuantityAsRationalInput.pure(divisible: getAsset.divisible);
    }

    Rational price_ = priceType == PriceType.give ? price.inverse : price;

    Rational quantity = Rational(give.quantity) * price_;

    // print("give quantity ${give.quantity}");
    // print("price: $price_");
    // print("quantity: $quantity");

    return GetQuantityAsRationalInput.dirty(
        value: quantity, divisible: getAsset.divisible);
  }

  // GetQuantityInput get getQuantityInput_ {
  //   final give = giveQuantityInput.value;
  //
  //   final price = priceInputAsRational.value;
  //
  //   print("give: $give");
  //   print("price: $price");
  //   if (price == Rational.zero) {
  //     return GetQuantityInput.pure(divisible: getAsset.divisible);
  //   }
  //
  //   Rational price_ = priceType == PriceType.give ? price.inverse : price;
  //
  //   Rational quantity =
  //       toRawUnits(Rational(give.quantity) * price_, getAsset.divisible);
  //
  //   // print("give quantity ${give.quantity}");
  //   // print("price: $price_");
  //   // print("quantity: $quantity");
  //
  //   return GetQuantityInput.dirty(
  //       value: AssetQuantity(
  //           quantity: quantity.toBigInt(), divisible: getAsset.divisible));
  // }

  GiveQuantityInput get maxGiveQuantityInput {
    final userBalance = AssetQuantity(
      divisible: giveAsset.divisible,
      quantity: BigInt.from(giveAssetBalance.quantity),
    );

    if (amountType == AmountType.give) {
      // User typed a GIVE amount directly → parse it to raw
      final giveParsed = AssetQuantity.fromNormalizedStringSafe(
        divisible: giveAsset.divisible,
        input: amountInput.value,
      ).getOrElse(
        (_) => AssetQuantity(
            divisible: giveAsset.divisible, quantity: BigInt.zero),
      );

      return GiveQuantityInput.dirty(
          value: giveParsed, userBalance: userBalance);
    }

    // amountType == AmountType.get → compute how much GIVE is required for the desired GET
    final priceOrNull =
        _currentPriceOrNull; // built from priceInputAsRational + priceType
    final giveNeeded = (priceOrNull == null)
        ? AssetQuantity(divisible: giveAsset.divisible, quantity: BigInt.zero)
        : giveAssetQuantityWhenAmountGet(price: priceInputAsRational.value);

    return GiveQuantityInput.dirty(value: giveNeeded, userBalance: userBalance);
  }

  // GiveQuantityInput get maxGiveQuantityInput =>
  //     switch ((amountType, priceType)) {
  //       ((AmountType.give, _)) => GiveQuantityInput.dirty(
  //           value: AssetQuantity.fromNormalizedStringSafe(
  //                   divisible: giveAsset.divisible, input: amountInput.value)
  //               .getOrElse((error) {
  //             return AssetQuantity(
  //                 divisible: giveAsset.divisible, quantity: BigInt.zero);
  //           }),
  //           userBalance: AssetQuantity(
  //               divisible: giveAsset.divisible,
  //               quantity: BigInt.from(giveAssetBalance.quantity))),
  //       ((AmountType.get, PriceType.give)) => GiveQuantityInput.dirty(
  //           value: giveAssetQuantityWhenAmountGet(
  //             price: priceInputAsRational.value,
  //           ),
  //           userBalance: AssetQuantity(
  //               divisible: giveAsset.divisible,
  //               quantity: BigInt.from(giveAssetBalance.quantity))),
  //       ((AmountType.get, PriceType.get)) => GiveQuantityInput.dirty(
  //           // TODO: rename
  //           value: giveAssetQuantityWhenAmountGet(
  //               price: priceInputAsRational.value.inverse),
  //           userBalance: AssetQuantity(
  //             divisible: giveAsset.divisible,
  //             quantity: BigInt.from(giveAssetBalance.quantity),
  //           ),
  //         ),
  //     };

  GetQuantityInput get getQuantityInput {
    final price = _currentPriceOrNull;
    if (price == null) {
      return GetQuantityInput.pure(divisible: getAsset.divisible);
    }

    // Amount typed in the field, normalized -> raw
    final typed = _parseAmountFieldAsQuantity();

    // We want the resulting "get" quantity.
    AssetQuantity result;

    if (amountType == AmountType.get) {
      // The user already typed "get" amount; just echo it (rounded to raw already).
      result = AssetQuantity(
          divisible: getAsset.divisible, quantity: typed.quantity);
    } else {
      // amountType == give: user typed a GIVE amount; compute GET via the displayed price
      if (priceType == PriceType.give) {
        // PriceType.give: pair base=get, quote=give
        // We have a give (quote) budget -> need baseForQuote to get "get" amount
        result = price.baseForQuote(
          AssetQuantity(
              divisible: giveAsset.divisible, quantity: typed.quantity),
          floorResult: true, // conservative: how much GET you can buy
        );
      } else {
        // PriceType.get: pair base=give, quote=get
        // We have a base (give) amount -> costForBase returns "get" (ceil to avoid under-get? usually floor is safer)
        result = price.costForBase(
          AssetQuantity(
              divisible: giveAsset.divisible, quantity: typed.quantity),
          // For GET received, most UIs prefer floor (never over-promise).
          // If you want "ceil" semantics, flip this to true.
          ceilOnRemainder: false,
        );
      }
    }

    return GetQuantityInput.dirty(value: result);
  }

  // GetQuantityInput get getQuantityInput => switch ((amountType, priceType)) {
  //       ((AmountType.get, PriceType.give)) => GetQuantityInput.dirty(
  //           value: getAssetQuantityWhenAmountGetAndPriceGive),
  //       ((AmountType.get, PriceType.get)) => GetQuantityInput.dirty(
  //           value: getAssetQuantityWhenAmountGetAndPriceGet),
  //       ((AmountType.give, PriceType.give)) => GetQuantityInput.dirty(
  //           value: getAssetQuantityWhenAmountGiveAndPriceGive),
  //       ((AmountType.give, PriceType.get)) => GetQuantityInput.dirty(
  //           value: getAssetQuantityWhenAmountGiveAndPriceGet),
  //     };

  // AssetQuantity get getAssetQuantityWhenAmountGetAndPriceGive {
  //   Rational price =
  //       toRawUnits(priceInputAsRational.value, giveAsset.divisible);
  //
  //   if (price == Rational.zero) {
  //     return AssetQuantity(
  //         divisible: getAsset.divisible, quantity: BigInt.zero);
  //   }
  //
  //   final getAmount = toRawUnits(
  //     Rational.tryParse(amountInput.value) ?? Rational.zero,
  //     getAsset.divisible,
  //   );
  //
  //   return AssetQuantity(
  //       quantity: getAmount.toBigInt(), divisible: getAsset.divisible);
  // }

  // AssetQuantity get getAssetQuantityWhenAmountGetAndPriceGet {
  //   // when get amount is specified explicitly, it needs to be rounded to price
  //
  //   Rational price = toRawUnits(priceInputAsRational.value, getAsset.divisible);
  //
  //   if (price == Rational.zero) {
  //     return AssetQuantity(
  //         divisible: getAsset.divisible, quantity: BigInt.zero);
  //   }
  //
  //   final getAmount = toRawUnits(
  //     Rational.tryParse(amountInput.value) ?? Rational.zero,
  //     getAsset.divisible,
  //   );
  //
  //   return AssetQuantity(
  //       quantity: getAmount.toBigInt(), divisible: getAsset.divisible);
  // }

  // AssetQuantity get getAssetQuantityWhenAmountGiveAndPriceGive {
  //   Rational price =
  //       toRawUnits(priceInputAsRational.value, giveAsset.divisible);
  //
  //   if (price == Rational.zero) {
  //     return AssetQuantity(
  //         divisible: getAsset.divisible, quantity: BigInt.zero);
  //   }
  //
  //   final giveAmount = toRawUnits(
  //     Rational.tryParse(amountInput.value) ?? Rational.zero,
  //     giveAsset.divisible,
  //   );
  //
  //   final quantity = toRawUnits(giveAmount / price, getAsset.divisible);
  //
  //   return AssetQuantity(
  //       quantity: quantity.toBigInt(), divisible: getAsset.divisible);
  // }
  //
  // AssetQuantity get getAssetQuantityWhenAmountGiveAndPriceGet {
  //   Rational price = toRawUnits(priceInputAsRational.value, getAsset.divisible);
  //   print('Parsed price: $price');
  //
  //   if (price == Rational.zero) {
  //     print('Price is zero, returning zero quantity.');
  //     return AssetQuantity(
  //         divisible: getAsset.divisible, quantity: BigInt.zero);
  //   }
  //
  //   final giveAmount = toRawUnits(
  //     Rational.tryParse(amountInput.value) ?? Rational.zero,
  //     giveAsset.divisible,
  //   );
  //   print('Parsed giveAmount: $giveAmount');
  //
  //   final quantity = toRawUnits(giveAmount * price, getAsset.divisible);
  //   print('Computed quantity: ${quantity.toBigInt()}');
  //
  //   return AssetQuantity(
  //       quantity: quantity.toBigInt(), divisible: getAsset.divisible);
  // }
  //
  // AssetQuantity get getAssetQuantityWhenAmountGiveAndPriceGet {
  //
  //   Rational price = toRawUnits(priceInputAsRational.value, getAsset.divisible);
  //
  //
  //   if (price == Rational.zero) {
  //     return AssetQuantity(
  //         divisible: getAsset.divisible, quantity: BigInt.zero);
  //   }
  //
  //   final giveAmount = toRawUnits(
  //     Rational.tryParse(amountInput.value) ?? Rational.zero,
  //     giveAsset.divisible,
  //   );
  //
  //   final quantity = toRawUnits(giveAmount * price, getAsset.divisible);
  //
  //   return AssetQuantity(
  //       quantity: quantity.toBigInt(), divisible: getAsset.divisible);
  // }

  @override
  List<FormzInput> get inputs => [
        amountInput,
        priceInput,
        priceInputAsRational,
        getQuantityInput,
        giveQuantityInput,
        getQuantityInputRational
      ];

  SwapOrderFormModel copyWith({
    MultiAddressBalanceEntry? giveAssetBalance,
    AmountInput? amountInput,
    PriceInput? priceInput,
    PriceInputAsRational? priceInputAsRational,
    Asset? giveAsset,
    Asset? getAsset,
    List<Order>? asks,
    List<Order>? bids,
    AmountType? amountType,
    PriceType? priceType,
    GetQuantityInput? getQuantityInput,
    RemoteData<SimulatedOrders>? simulatedOrders,
    Option<DateTime>? expiry,
  }) {
    return SwapOrderFormModel(
      expiry: expiry ?? this.expiry,
      simulatedOrders: simulatedOrders ?? this.simulatedOrders,
      giveAssetBalance: giveAssetBalance ?? this.giveAssetBalance,
      priceInputAsRational: priceInputAsRational ?? this.priceInputAsRational,
      priceInput: priceInput ?? this.priceInput,
      amountInput: amountInput ?? this.amountInput,
      priceType: priceType ?? this.priceType,
      amountType: amountType ?? this.amountType,
      giveAsset: giveAsset ?? this.giveAsset,
      getAsset: getAsset ?? this.getAsset,
      asks: asks ?? this.asks,
      bids: bids ?? this.bids,
    );
  }

  String get priceString {
    return priceType == PriceType.give
        ? "${giveAsset.displayName} / ${getAsset.displayName}"
        : "${getAsset.displayName} / ${giveAsset.displayName}";
  }

  List<OrderViewModel> get buyOrdersView {
    return asks
        .map((el) => el.toViewModel(side: OrderViewModelSide.buy))
        .toList()
      ..sort((a, b) => b.price.compareNormalized(a.price)); // descending
  }

  List<OrderViewModel> get sellOrdersView {
    return bids
        .map((el) => el.toViewModel(side: OrderViewModelSide.sell))
        .toList()
      ..sort((a, b) => a.price.compareNormalized(b.price)); // ascending
  }

  Asset get amountAsset {
    return amountType == AmountType.give ? giveAsset : getAsset;
  }

  Asset get priceAsset {
    return priceType == PriceType.give ? giveAsset : getAsset;
  }

  Asset get priceNumeratorAsset {
    return priceType == PriceType.give ? giveAsset : getAsset;
  }

  Asset get priceDenominatorAsset {
    return priceType == PriceType.give ? getAsset : giveAsset;
  }

  Option<String> get amountInputError {
    if (amountInput.isPure) {
      return none();
    }

    final error = amountType == AmountType.give
        ? maxGiveQuantityInput.error
        : getQuantityInput.error;

    return Option.fromNullable(error?.toString());
  }

  bool get amountInputDivisibility =>
      amountType == AmountType.give ? giveAsset.divisible : getAsset.divisible;
}

enum AmountType {
  give,
  get,
}

enum PriceType { give, get }

class ViewModel {
  final Asset amountAsset;
  final Asset priceAsset;

  final List<OrderViewModel> sellOrders;
  final List<OrderViewModel> buyOrders;

  final String priceString;

  ViewModel({
    required this.priceAsset,
    required this.amountAsset,
    required this.sellOrders,
    required this.buyOrders,
    required this.priceString,
  });
}

class AsyncData {
  final List<Order> sellOrders;
  final List<Order> buyOrders;
  AsyncData({
    required this.sellOrders,
    required this.buyOrders,
  });
}

sealed class SwapOrderFormEvent extends Equatable {
  const SwapOrderFormEvent();

  @override
  List<Object?> get props => [];
}

class MaxButtonClicked extends SwapOrderFormEvent {}

class AmountTypeClicked extends SwapOrderFormEvent {}

class PriceTypeClicked extends SwapOrderFormEvent {}

enum RelativePriceValue {
  floor,
  plus5,
  plus10,
  plus15,
}

class RelativePriceButtonClicked extends SwapOrderFormEvent {
  final RelativePriceValue value;

  const RelativePriceButtonClicked({required this.value});
}

class AmountInputChanged extends SwapOrderFormEvent {
  final String value;
  const AmountInputChanged({required this.value});
}

class PriceInputChanged extends SwapOrderFormEvent {
  final String value;
  const PriceInputChanged({required this.value});
}

class ExpiryChanged extends SwapOrderFormEvent {
  final DateTime? value;

  const ExpiryChanged({this.value});
}

class SimulatedOrdersRequested extends SwapOrderFormEvent {}

class SwapOrderFormBloc extends Bloc<SwapOrderFormEvent, SwapOrderFormModel> {
  final HttpConfig httpConfig;

  final AddressV2 address;

  final OrderRepository _orderRepository;

  SwapOrderFormBloc({
    required this.address,
    required this.httpConfig,
    required Asset getAsset,
    required Asset giveAsset,
    required List<Order> buyOrders,
    required List<Order> sellOrders,
    required MultiAddressBalanceEntry giveAssetBalance,
    OrderRepository? orderRepository,
  })  : _orderRepository = orderRepository ?? GetIt.I<OrderRepository>(),
        super(SwapOrderFormModel(
            expiry: none(),
            giveAssetBalance: giveAssetBalance,
            amountInput: const AmountInput.dirty(value: "0"),
            priceInput: const PriceInput.pure(),
            priceInputAsRational: PriceInputAsRational.pure(),
            amountType: AmountType.get,
            priceType: PriceType.give,
            giveAsset: giveAsset,
            getAsset: getAsset,
            asks: buyOrders,
            bids: sellOrders,
            simulatedOrders: const Initial())) {
    on<AmountTypeClicked>(_handleAmountTypeClicked);
    on<PriceTypeClicked>(_handlePriceTypeClicked);
    on<AmountInputChanged>(_handleAmountInputChanged);
    on<PriceInputChanged>(_handlePriceInputChanged);
    on<RelativePriceButtonClicked>(_handleRelativePriceValueClicked);
    on<SimulatedOrdersRequested>(
      _handleSimulateOrdersRequested,
    );
    on<ExpiryChanged>(_handleExpiryChanged);
    on<MaxButtonClicked>(_handleMaxButtonClicked);
  }

  void _handleMaxButtonClicked(
    MaxButtonClicked event,
    Emitter<SwapOrderFormModel> emit,
  ) {
    if (state.amountType == AmountType.get) return;

    emit(state.copyWith(
        amountInput: AmountInput.dirty(
            value: state.giveAssetBalance.quantityNormalized)));

    add(SimulatedOrdersRequested());
  }

  void _handleRelativePriceValueClicked(
    RelativePriceButtonClicked event,
    Emitter<SwapOrderFormModel> emit,
  ) {
    final floorOrders = [...state.asks]
      ..sort((a, b) => b.getPriceNormalized.compareTo(a.getPriceNormalized));

    final floorOrder = floorOrders.firstOrNull;
    if (floorOrder == null) return;

    // Determine displayed pair for current price type
    final bool baseIsGive =
        (state.priceType == PriceType.give); // when "give", display get/give
    final Asset baseAsset = baseIsGive ? state.giveAsset : state.getAsset;
    final Asset quoteAsset = baseIsGive ? state.getAsset : state.giveAsset;
    final MarketPair pair = pairFor(base: baseAsset, quote: quoteAsset);

    // Base displayed price from the floor order as Rational
    final Rational baseDisplayPrice = baseIsGive
        ? rationalDiv(
            floorOrder.getQuantityNormalized, floorOrder.giveQuantityNormalized)
        : rationalDiv(floorOrder.giveQuantityNormalized,
            floorOrder.getQuantityNormalized);

    // Adjustment factor (Rational), same semantics as before
    final double factor = switch ((event.value, state.priceType)) {
      (RelativePriceValue.floor, _) => 1.0,
      (RelativePriceValue.plus5, PriceType.give) => 1.05,
      (RelativePriceValue.plus10, PriceType.give) => 1.10,
      (RelativePriceValue.plus15, PriceType.give) => 1.15,
      (RelativePriceValue.plus5, PriceType.get) => 0.95,
      (RelativePriceValue.plus10, PriceType.get) => 0.90,
      (RelativePriceValue.plus15, PriceType.get) => 0.85,
    };
    final Rational adjustment = Rational.parse(factor.toString());

    final Rational adjustedDisplayPrice = baseDisplayPrice * adjustment;

    // Update both the Rational holder and the string input using your "ceil" formatting
    final priceAsRationalInput =
        PriceInputAsRational.dirty(value: adjustedDisplayPrice);

    final priceInput = PriceInput.dirty(
      value: rationalCeilToString(adjustedDisplayPrice, precision: 8),
    );

    emit(state.copyWith(
      priceInput: priceInput,
      priceInputAsRational: priceAsRationalInput,
    ));

    add(SimulatedOrdersRequested());
  }

  // void _handleRelativePriceValueClicked(
  //   RelativePriceButtonClicked event,
  //   Emitter<SwapOrderFormModel> emit,
  // ) {
  //   final floorOrders = state.asks
  //     ..sort((a, b) => b.getPriceNormalized.compareTo(a.getPriceNormalized));
  //
  //   final floorOrder = floorOrders.firstOrNull;
  //
  //   if (floorOrder == null) return;
  //
  //   // Determine how to display the base price (inverted if get-denominated)
  //   final displayPrice = state.priceType == PriceType.give
  //       ? Decimal.parse(floorOrder.getQuantityNormalized) /
  //           Decimal.parse(floorOrder.giveQuantityNormalized)
  //       : Decimal.parse(floorOrder.giveQuantityNormalized) /
  //           Decimal.parse(floorOrder.getQuantityNormalized);
  //
  //   print("displayPrice: $displayPrice");
  //
  //   final adjustmentFactor = switch ((event.value, state.priceType)) {
  //     (RelativePriceValue.floor, _) => 1.0,
  //     (RelativePriceValue.plus5, PriceType.give) => 1.05,
  //     (RelativePriceValue.plus10, PriceType.give) => 1.10,
  //     (RelativePriceValue.plus15, PriceType.give) => 1.15,
  //     (RelativePriceValue.plus5, PriceType.get) => 0.95,
  //     (RelativePriceValue.plus10, PriceType.get) => 0.90,
  //     (RelativePriceValue.plus15, PriceType.get) => 0.85,
  //   };
  //
  //   final adjustmentFactorDecimal = Rational.parse(adjustmentFactor.toString());
  //
  //   final priceAsRationalInput = PriceInputAsRational.dirty(
  //       value: displayPrice * adjustmentFactorDecimal);
  //
  //   final priceInput = PriceInput.dirty(
  //       value: priceAsRationalInput.value
  //           .toDecimal(scaleOnInfinitePrecision: 9)
  //           .ceil(scale: 8)
  //           .toString());
  //
  //   emit(state.copyWith(
  //     priceInput: priceInput,
  //     priceInputAsRational: priceAsRationalInput,
  //   ));
  //
  //   add(SimulatedOrdersRequested());
  // }

  void _handleExpiryChanged(
    ExpiryChanged event,
    Emitter<SwapOrderFormModel> emit,
  ) {
    Option<DateTime> expiry =
        event.value != null ? Option.of(event.value!) : const Option.none();

    emit(state.copyWith(expiry: expiry));
  }

  void _handlePriceInputChanged(
    PriceInputChanged event,
    Emitter<SwapOrderFormModel> emit,
  ) {
    final priceInput = PriceInput.dirty(value: event.value);

    emit(state.copyWith(
      simulatedOrders: const Initial(),
      priceInput: priceInput,
      priceInputAsRational: PriceInputAsRational.dirty(
          value: Rational.tryParse(event.value) ?? Rational.zero),
    ));

    add(SimulatedOrdersRequested());
  }

  _handleAmountInputChanged(
    AmountInputChanged event,
    Emitter<SwapOrderFormModel> emit,
  ) {
    // count trailing zeros
    //

    if (event.value.isEmpty) {
      return;
    }

    final amountInput = AmountInput.dirty(
      value: event.value,
    );
    print("\n\n\n");

    emit(state.copyWith(
      amountInput: amountInput,
      simulatedOrders: const Initial(),
    ));

    add(SimulatedOrdersRequested());
  }

  _handleAmountTypeClicked(
    AmountTypeClicked event,
    Emitter<SwapOrderFormModel> emit,
  ) {
    emit(
      state.copyWith(
          simulatedOrders: const Initial(),
          amountType: state.amountType == AmountType.give
              ? AmountType.get
              : AmountType.give,
          amountInput: const AmountInput.dirty(value: "0")),
    );
  }

  _handlePriceTypeClicked(
    PriceTypeClicked event,
    Emitter<SwapOrderFormModel> emit,
  ) {
    emit(
      state.copyWith(
        simulatedOrders: const Initial(),
        priceInput: const PriceInput.pure(),
        priceInputAsRational: PriceInputAsRational.pure(),
        priceType:
            state.priceType == PriceType.give ? PriceType.get : PriceType.give,
      ),
    );
  }

  Future<void> _handleSimulateOrdersRequested(
    SimulatedOrdersRequested event,
    Emitter<SwapOrderFormModel> emit,
  ) async {
    if (Rational.tryParse(state.priceInput.value) == null ||
        Rational.tryParse(state.amountInput.value) == null) {
      return;
    }

    emit(state.copyWith(simulatedOrders: const Loading()));

    final task =
        TaskEither<String, (List<Order>, List<Order>, List<SimulatedOrder>)>.Do(
      ($) async {
        final result = await $(TaskEither.sequenceList([
          _orderRepository.getByPairTE(
              status: "open",
              giveAsset: state.getAsset.asset,
              getAsset: state.giveAsset.asset,
              httpConfig: httpConfig,
              sort: "give_price"),
          _orderRepository.getByPairTE(
            giveAsset: state.giveAsset.asset,
            getAsset: state.getAsset.asset,
            status: "open",
            httpConfig: httpConfig,
          ),
        ]));

        final asks = result[0];
        final bids = result[1];

        final simulatedOrders = SimulateOrdersUseCase().call(
            SimulateOrdersParams(
                asks: asks,
                giveQuantity: state.maxGiveQuantityInput.value,
                getQuantity: state.getQuantityInput.value));

        return (asks, bids, simulatedOrders);
      },
    );

    final result = await task.run();

    final nextState = result.fold(
      (error) {
        return state.copyWith(simulatedOrders: Failure(error));
      },
      (success) {
        return state.copyWith(
          asks: success.$1,
          bids: success.$2,
          simulatedOrders: Success(SimulatedOrders(
              giveAsset: state.giveAsset,
              getAsset: state.getAsset,
              orders: success.$3)),
        );
      },
    );

    emit(nextState);
  }
}

EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => events
      .debounceTime(duration) // wait until the stream is quiet
      .switchMap(mapper); // then run the handler once
}
