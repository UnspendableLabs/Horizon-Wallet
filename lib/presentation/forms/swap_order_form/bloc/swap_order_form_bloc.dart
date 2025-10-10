import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:formz/formz.dart';
import 'package:decimal/decimal.dart';
import 'package:horizon/domain/entities/balance_v2.dart';
import 'package:rational/rational.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/order.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/simulated_order.dart';
import 'package:horizon/domain/usecases/simulate_orders.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/order_repository.dart';

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
    final bool baseIsGive = (side == OrderViewModelSide.buy);

    final bool giveAssetDivisible = inferDivisible(
        raw: BigInt.from(giveQuantity), normalized: giveQuantityNormalized);

    final bool getAssetDivisible = inferDivisible(
        raw: BigInt.from(getQuantity), normalized: getQuantityNormalized);

    final bool baseAssetDivisible =
        baseIsGive ? giveAssetDivisible : getAssetDivisible;

    final bool quoteAssetDivisible =
        baseIsGive ? getAssetDivisible : giveAssetDivisible;

    final MarketPair displayedPair = MarketPair(
      baseDivisible: baseAssetDivisible,
      quoteDivisible: quoteAssetDivisible,
    );

    final Rational normRatio = baseIsGive
        ? (Decimal.parse(getQuantityNormalized) /
            Decimal.parse(giveQuantityNormalized))
        : (Decimal.parse(giveQuantityNormalized) /
            Decimal.parse(getQuantityNormalized));

    final Price price = Price.fromNormalized(
      pair: displayedPair,
      quotePerBaseNormalized: normRatio.toDecimal(scaleOnInfinitePrecision: 20),
    );

    final Price inverted = price.invert();

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

class SwapOrderFormModel with FormzMixin {
  final RemoteData<SimulatedOrders> simulatedOrders;

  final AddressBalance giveAssetBalance;

  final Asset giveAsset;
  final Asset getAsset;

  final List<Order> asks;
  final List<Order> bids;

  final AmountType amountType;
  final PriceType priceType;

  final AmountInput amountInput;
  final PriceInput priceInput;

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
    final s = priceInput.value.trim();
    if (s.isEmpty) return null;
    Decimal? d;
    try {
      d = Decimal.parse(s);
    } catch (_) {
      return null;
    }
    if (d == Decimal.zero) return null;

    final pair = priceType == PriceType.give
        ? MarketPair(
            baseDivisible: getAsset.divisible,
            quoteDivisible: giveAsset.divisible) // GET/GIVE
        : MarketPair(
            baseDivisible: giveAsset.divisible,
            quoteDivisible: getAsset.divisible); // GIVE/GET

    return Price.fromNormalized(pair: pair, quotePerBaseNormalized: d);
  }

  GiveQuantityInput get giveQuantityInput {
    final userBalance = giveAssetBalance.quantity;

    return simulatedOrders.fold3(
        onNone: () => GiveQuantityInput.pure(userBalance: userBalance),
        onFailure: (_) => GiveQuantityInput.pure(userBalance: userBalance),
        onReplete: (summary) {
          return GiveQuantityInput.dirty(
              value: summary.summary.totalGive, userBalance: userBalance);
        });
  }

  AssetQuantity _giveForTypedGet() {
    final p = _currentPriceOrNull;
    if (p == null) {
      return AssetQuantity(
          divisible: giveAsset.divisible, quantity: BigInt.zero);
    }

    final desiredGet = AssetQuantity.fromNormalizedStringSafe(
      divisible: getAsset.divisible,
      input: amountInput.value.isEmpty ? "0" : amountInput.value,
    ).getOrElse(
      (_) =>
          AssetQuantity(divisible: getAsset.divisible, quantity: BigInt.zero),
    );

    if (desiredGet.quantity == BigInt.zero) {
      return AssetQuantity(
          divisible: giveAsset.divisible, quantity: BigInt.zero);
    }

    // Always ceil: never underpay GIVE for the requested GET
    if (priceType == PriceType.give) {
      // pair base=GET, quote=GIVE
      return p.costForBase(desiredGet, ceilOnRemainder: true);
    } else {
      // pair base=GIVE, quote=GET → invert so GET is base, then costForBase
      return p.invert().costForBase(desiredGet, ceilOnRemainder: true);
    }
  }

  GiveQuantityInput get maxGiveQuantityInput {
    final userBalance = giveAssetBalance.quantity;

    final value = (amountType == AmountType.give)
        ? AssetQuantity.fromNormalizedStringSafe(
            divisible: giveAsset.divisible,
            input: amountInput.value,
          ).getOrElse(
            (_) => AssetQuantity(
                divisible: giveAsset.divisible, quantity: BigInt.zero),
          )
        : _giveForTypedGet();

    return GiveQuantityInput.dirty(value: value, userBalance: userBalance);
  }

  GetQuantityInput get getQuantityInput {
    final p = _currentPriceOrNull;
    if (p == null) {
      return GetQuantityInput.pure(divisible: getAsset.divisible);
    }

    final isGiveSide = amountType == AmountType.give;

    // parse the amount field into the correct side’s raw units
    final typed = AssetQuantity.fromNormalizedStringSafe(
      divisible: isGiveSide ? giveAsset.divisible : getAsset.divisible,
      input: amountInput.value.isEmpty ? "0" : amountInput.value,
    ).getOrElse(
      (_) => AssetQuantity(
          divisible: isGiveSide ? giveAsset.divisible : getAsset.divisible,
          quantity: BigInt.zero),
    );

    AssetQuantity out;
    if (!isGiveSide) {
      // amountType == get → echo
      out = AssetQuantity(
          divisible: getAsset.divisible, quantity: typed.quantity);
    } else {
      // amountType == give → compute GET
      if (priceType == PriceType.give) {
        // pair base=GET, quote=GIVE → have quote budget → baseForQuote(floor)
        out = p.baseForQuote(
          AssetQuantity(
              divisible: giveAsset.divisible, quantity: typed.quantity),
          floorResult: true,
        );
      } else {
        // pair base=GIVE, quote=GET → have base → costForBase(floor) [no over-promise of GET]
        out = p.costForBase(
          AssetQuantity(
              divisible: giveAsset.divisible, quantity: typed.quantity),
          ceilOnRemainder: false,
        );
      }
    }

    if (out.divisible != getAsset.divisible) {
      assert(false, 'getQuantity.kind mismatch');
    }
    return GetQuantityInput.dirty(value: out);
  }

  @override
  List<FormzInput> get inputs => [
        amountInput,
        priceInput,
        getQuantityInput,
        giveQuantityInput,
      ];

  SwapOrderFormModel copyWith({
    AddressBalance? giveAssetBalance,
    AmountInput? amountInput,
    PriceInput? priceInput,
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
      ..sort((a, b) => b.price.compareNormalized(a.price)); // ascending
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
    required AddressBalance giveAssetBalance,
    OrderRepository? orderRepository,
  })  : _orderRepository = orderRepository ?? GetIt.I<OrderRepository>(),
        super(SwapOrderFormModel(
            expiry: none(),
            giveAssetBalance: giveAssetBalance,
            amountInput: const AmountInput.dirty(value: ""),
            priceInput: const PriceInput.dirty(value: ""),
            amountType: AmountType.give,
            priceType: PriceType.get,
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
            value: state.giveAssetBalance.quantity.normalized())));

    add(SimulatedOrdersRequested());
  }

  void _handleRelativePriceValueClicked(
    RelativePriceButtonClicked event,
    Emitter<SwapOrderFormModel> emit,
  ) {
    // pick the floor ask (best price to buy against)
    final floorOrders = [...state.asks]
      ..sort((a, b) => b.getPriceNormalized.compareTo(a.getPriceNormalized));
    final floorOrder = floorOrders.firstOrNull;
    if (floorOrder == null) return;

    // displayed orientation: when PriceType.give we show GET/GIVE, else GIVE/GET
    final bool showGetOverGive = (state.priceType == PriceType.give);

    // compute the *normalized* displayed price from the floor order
    final Rational baseDisplayPrice = showGetOverGive
        ? (Rational.parse(floorOrder.getQuantityNormalized) /
            Rational.parse(floorOrder.giveQuantityNormalized))
        : (Rational.parse(floorOrder.giveQuantityNormalized) /
            Rational.parse(floorOrder.getQuantityNormalized));

    // apply the selected relative adjustment

    final Rational factor = switch ((event.value, state.priceType)) {
      (RelativePriceValue.floor, _) => Rational.one,
      (RelativePriceValue.plus5, PriceType.give) =>
        Rational(BigInt.from(21), BigInt.from(20)), // 1.05
      (RelativePriceValue.plus10, PriceType.give) =>
        Rational(BigInt.from(11), BigInt.from(10)), // 1.10
      (RelativePriceValue.plus15, PriceType.give) =>
        Rational(BigInt.from(23), BigInt.from(20)), // 1.15
      (RelativePriceValue.plus5, PriceType.get) =>
        Rational(BigInt.from(19), BigInt.from(20)), // 0.95
      (RelativePriceValue.plus10, PriceType.get) =>
        Rational(BigInt.from(9), BigInt.from(10)), // 0.90
      (RelativePriceValue.plus15, PriceType.get) =>
        Rational(BigInt.from(17), BigInt.from(20)), // 0.85
    };

    final Rational adjusted = baseDisplayPrice * factor;

    final priceInput = PriceInput.dirty(
      value: adjusted
          .toDecimal(scaleOnInfinitePrecision: 9)
          .ceil(scale: 8)
          .toString(),
    );

    emit(state.copyWith(priceInput: priceInput));
    add(SimulatedOrdersRequested());
  }

  void _handleExpiryChanged(
    ExpiryChanged event,
    Emitter<SwapOrderFormModel> emit,
  ) {
    Option<DateTime> expiry =
        event.value != null ? Option.of(event.value!) : const Option.none();

    emit(state.copyWith(expiry: expiry));
  }

  void _handlePriceTypeClicked(
    PriceTypeClicked event,
    Emitter<SwapOrderFormModel> emit,
  ) {
    final newType =
        state.priceType == PriceType.give ? PriceType.get : PriceType.give;

    final String s = state.priceInput.value.trim();
    Rational r;
    try {
      r = Rational.parse(s);
    } catch (_) {
      r = Rational.zero;
    }

    final Rational inv =
        (r == Rational.zero) ? Rational.zero : (Rational.one / r);

    final String newStr = (inv == Rational.zero)
        ? '0'
        : inv.toDecimal(scaleOnInfinitePrecision: 9).ceil(scale: 8).toString();

    emit(state.copyWith(
      simulatedOrders: const Initial(),
      priceType: newType,
      priceInput: PriceInput.dirty(value: newStr),
    ));

    add(SimulatedOrdersRequested());
  }

  void _handlePriceInputChanged(
    PriceInputChanged event,
    Emitter<SwapOrderFormModel> emit,
  ) {
    final priceInput = PriceInput.dirty(value: event.value);

    emit(state.copyWith(
      simulatedOrders: const Initial(),
      priceInput: priceInput,
    ));

    add(SimulatedOrdersRequested());
  }

  void _handleAmountInputChanged(
    AmountInputChanged event,
    Emitter<SwapOrderFormModel> emit,
  ) {
    if (event.value.isEmpty) {
      return;
    }

    final amountInput = AmountInput.dirty(
      value: event.value,
    );

    emit(state.copyWith(
      amountInput: amountInput,
      simulatedOrders: const Initial(),
    ));

    add(SimulatedOrdersRequested());
  }

  void _handleAmountTypeClicked(
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
