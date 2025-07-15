import 'dart:math';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:formz/formz.dart';
import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/presentation/screens/swap/view/swap_view.dart';
import 'package:rxdart/rxdart.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/order.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/order_repository.dart';
import 'package:horizon/common/constants.dart';

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

sealed class SimulatedOrder extends Equatable {
  final AssetQuantity give;
  final AssetQuantity get;

  const SimulatedOrder({required this.give, required this.get});

  @override
  List<Object?> get props => [runtimeType, give, get];

  @override
  String toString() => '$runtimeType(give: $give, get: $get)';
}

class SimulatedOrderMatch extends SimulatedOrder {
  const SimulatedOrderMatch({required super.give, required super.get});
}

class SimulatedOrderCreate extends SimulatedOrder {
  const SimulatedOrderCreate({required super.give, required super.get});
}

enum AmountInputError { required }

class AmountInput extends FormzInput<String, AmountInputError> {
  AmountInput.pure() : super.pure("");
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
  PriceInput.pure() : super.pure("");
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

class OrderViewModel {
  final OrderViewModelSide side;
  final AssetQuantity quantity;
  final AssetQuantity price;
  final AssetQuantity invertedPrice;
  OrderViewModel(
      {required this.invertedPrice,
      required this.side,
      required this.quantity,
      required this.price});
}

extension OrderViewModelExtension on Order {
  OrderViewModel toViewModel({
    required OrderViewModelSide side,
  }) {
    final divisible = giveQuantity != double.parse(giveRemainingNormalized);

    int price = side == OrderViewModelSide.buy
        ? (double.parse(getQuantityNormalized) /
                double.parse(giveQuantityNormalized) *
                TenToTheEigth.doubleValue)
            .round()
        : (double.parse(giveQuantityNormalized) /
                double.parse(getQuantityNormalized) *
                TenToTheEigth.doubleValue)
            .round();

    int invertedPrice = side == OrderViewModelSide.buy
        ? (double.parse(giveQuantityNormalized) /
                double.parse(getQuantityNormalized) *
                TenToTheEigth.doubleValue)
            .round()
        : (double.parse(getQuantityNormalized) /
                double.parse(giveQuantityNormalized) *
                TenToTheEigth.doubleValue)
            .round();

    return OrderViewModel(
      side: side,
      quantity: AssetQuantity(
          divisible: divisible, quantity: BigInt.from(giveRemaining)),
      invertedPrice: AssetQuantity(
        divisible: divisible,
        quantity: BigInt.from(invertedPrice),
      ),
      price: AssetQuantity(
        divisible: true,
        quantity: BigInt.from(price),
      ),
    );
  }
}

class SwapOrderFormModel with FormzMixin {
  final RemoteData<List<SimulatedOrder>> simulatedOrders;

  final MultiAddressBalanceEntry giveAssetBalance;

  final Asset giveAsset;
  final Asset getAsset;

  final List<Order> buyOrders;
  final List<Order> sellOrders;

  final AmountType amountType;
  final PriceType priceType;

  final AmountInput amountInput;
  final PriceInput priceInput;

  const SwapOrderFormModel({
    required this.simulatedOrders,
    required this.giveAssetBalance,
    required this.amountInput,
    required this.priceInput,
    // required this.giveQuantityInput,
    // required this.receiveQuantityInput,
    required this.amountType,
    required this.giveAsset,
    required this.getAsset,
    required this.buyOrders,
    required this.sellOrders,
    required this.priceType,
  });

  AssetQuantity giveAssetQuantityWhenAmountGet({required Rational price}) {
    // CHAT Help me finish this refactor

    final desiredGetAmount = toRawUnits(
      Rational.tryParse(amountInput.value) ?? Rational.zero,
      getAsset.divisible,
    );

    Rational totalGet = Rational.zero;

    Rational totalGive = Rational.zero;

    for (final order in buyOrders) {
      if (totalGet >= desiredGetAmount) {
        break;
      }
      final matchPrice =
          Rational.fromInt(order.getQuantity, order.giveQuantity);

      final orderGiveRemaining = Rational(BigInt.from(order.giveRemaining));

      final getAmount =
          rationalMinList([orderGiveRemaining, (desiredGetAmount - totalGet)]);

      totalGet += getAmount;

      totalGive += matchPrice * getAmount;
    }

    if (desiredGetAmount - totalGet > Rational.zero) {
      Rational quantity = adjustForDivisibility(desiredGetAmount - totalGet,
          fromDivisible: getAsset.divisible, toDivisible: giveAsset.divisible);

      totalGive += quantity * price;
    }

    return AssetQuantity(
        divisible: giveAsset.divisible, quantity: totalGive.toBigInt());
  }

  GiveQuantityInput get giveQuantityInput => switch ((amountType, priceType)) {
        ((AmountType.give, _)) => GiveQuantityInput.dirty(
            value: AssetQuantity.fromNormalizedStringSafe(
                    divisible: giveAsset.divisible, input: amountInput.value)
                .getOrElse((error) {
              return AssetQuantity(
                  divisible: giveAsset.divisible, quantity: BigInt.zero);
            }),
            userBalance: AssetQuantity(
                divisible: giveAsset.divisible,
                quantity: BigInt.from(giveAssetBalance.quantity))),
        ((AmountType.get, PriceType.give)) => GiveQuantityInput.dirty(
            value: giveAssetQuantityWhenAmountGet(
                price: Rational.parse(priceInput.value)),
            userBalance: AssetQuantity(
                divisible: giveAsset.divisible,
                quantity: BigInt.from(giveAssetBalance.quantity))),
        ((AmountType.get, PriceType.get)) => GiveQuantityInput.dirty(
            // TODO: rename
            value: giveAssetQuantityWhenAmountGet(
                price: Rational.parse(priceInput.value).inverse),
            userBalance: AssetQuantity(
              divisible: giveAsset.divisible,
              quantity: BigInt.from(giveAssetBalance.quantity),
            ),
          ),
      };

  GetQuantityInput get getQuantityInput => switch ((amountType, priceType)) {
        ((AmountType.get, _)) => GetQuantityInput.dirty(
            value: AssetQuantity.fromNormalizedStringSafe(
                    divisible: getAsset.divisible, input: amountInput.value)
                .getOrElse((_) => AssetQuantity(
                    divisible: getAsset.divisible, quantity: BigInt.zero))),
        ((AmountType.give, PriceType.give)) => GetQuantityInput.dirty(
            value: getAssetQuantityWhenAmountGiveAndPriceGive),
        ((AmountType.give, PriceType.get)) => GetQuantityInput.dirty(
            value: getAssetQuantityWhenAmountGiveAndPriceGet),
      };

  AssetQuantity get getAssetQuantityWhenAmountGiveAndPriceGive {
    Rational price = toRawUnits(
        Rational.tryParse(priceInput.value) ?? Rational.zero,
        giveAsset.divisible);

    final giveAmount = toRawUnits(
      Rational.tryParse(amountInput.value) ?? Rational.zero,
      giveAsset.divisible,
    );

    Rational totalGet = Rational.zero;
    Rational totalGive = Rational.zero;

    for (final order in buyOrders) {
      if (totalGive >= giveAmount) break;

      final orderGiveRemaining = Rational.fromInt(order.giveRemaining);
      final matchPrice =
          Rational.fromInt(order.getQuantity, order.giveQuantity);

      // assume sorted
      if (matchPrice > price) {
        break;
      }

      // Max give amount we can take from this order
      final remainingGive = giveAmount - totalGive;

      final orderGive = rationalMinList([
        remainingGive * matchPrice.inverse,
        orderGiveRemaining,
      ]);

      totalGet += orderGive;

      totalGive += orderGive * matchPrice;
    }

    // Handle unmatched give via fallback price
    final unmatchedGive = giveAmount - totalGive;
    if (unmatchedGive > Rational.zero) {
      totalGet += toRawUnits(unmatchedGive / price, getAsset.divisible);
    }

    return AssetQuantity(
        quantity: totalGet.toBigInt(), divisible: getAsset.divisible);
  }

  AssetQuantity get getAssetQuantityWhenAmountGiveAndPriceGet {
    Rational price = Rational.parse(priceInput.value);

    Rational giveAmount = toRawUnits(
        Rational.tryParse(amountInput.value) ?? Rational.zero,
        giveAsset.divisible);

    Rational totalGet = Rational.zero;
    Rational totalGive = Rational.zero;

    for (final order in buyOrders) {
      if (totalGive >= giveAmount) break;

      final orderGiveRemaining = Rational.fromInt(order.giveRemaining);
      final orderGetRemaining = Rational.fromInt(order.getRemaining);
      final matchPrice =
          Rational.fromInt(order.getQuantity, order.giveQuantity);

      // TODO: validate that we don't caer babot price here

      final remainingGive = giveAmount - totalGive;

      final orderGive = rationalMinList([
        remainingGive * matchPrice.inverse,
        orderGiveRemaining,
      ]);

      totalGet += orderGive;

      totalGive += orderGive * matchPrice;
    }

    final unmatchedGive = giveAmount - totalGive;

    if (unmatchedGive > Rational.zero) {
      totalGet += adjustForDivisibility(unmatchedGive * price,
          fromDivisible: giveAsset.divisible, toDivisible: getAsset.divisible);
    }

    return AssetQuantity(
        quantity: totalGet.toBigInt(), divisible: getAsset.divisible);
  }

  @override
  List<FormzInput> get inputs =>
      [amountInput, priceInput, giveQuantityInput, getQuantityInput];

  SwapOrderFormModel copyWith(
      {MultiAddressBalanceEntry? giveAssetBalance,
      AmountInput? amountInput,
      PriceInput? priceInput,
      Asset? giveAsset,
      Asset? getAsset,
      List<Order>? buyOrders,
      List<Order>? sellOrders,
      AmountType? amountType,
      PriceType? priceType,
      GetQuantityInput? getQuantityInput,
      RemoteData<List<SimulatedOrder>>? simulatedOrders}) {
    return SwapOrderFormModel(
      // giveQuantityInput: giveQuantityInput ?? this.giveQuantityInput,
      // receiveQuantityInput: receiveQuantityInput ?? this.receiveQuantityInput,
      simulatedOrders: simulatedOrders ?? this.simulatedOrders,
      giveAssetBalance: giveAssetBalance ?? this.giveAssetBalance,
      priceInput: priceInput ?? this.priceInput,
      amountInput: amountInput ?? this.amountInput,
      priceType: priceType ?? this.priceType,
      amountType: amountType ?? this.amountType,
      giveAsset: giveAsset ?? this.giveAsset,
      getAsset: getAsset ?? this.getAsset,
      buyOrders: buyOrders ?? this.buyOrders,
      sellOrders: sellOrders ?? this.sellOrders,
    );
  }

  String get priceString {
    return priceType == PriceType.give
        ? "${giveAsset.displayName} / ${getAsset.displayName}"
        : "${getAsset.displayName} / ${giveAsset.displayName}";
  }

  List<OrderViewModel> get buyOrdersView {
    return buyOrders
        .map((el) => el.toViewModel(side: OrderViewModelSide.buy))
        .toList()
      ..sort(
          (a, b) => b.price.quantity.compareTo(a.price.quantity)); // descending
  }

  List<OrderViewModel> get sellOrdersView {
    return sellOrders
        .map((el) => el.toViewModel(side: OrderViewModelSide.sell))
        .toList()
      ..sort(
          (a, b) => a.price.quantity.compareTo(b.price.quantity)); // ascending
  }

  Asset get amountAsset {
    return amountType == AmountType.give ? giveAsset : getAsset;
  }

  Asset get priceAsset {
    return priceType == PriceType.give ? giveAsset : getAsset;
  }

  Option<String> get amountInputError {
    if (amountInput.isPure) {
      return none();
    }

    final error = amountType == AmountType.give
        ? giveQuantityInput.error
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

class AmountTypeClicked extends SwapOrderFormEvent {}

class PriceTypeClicked extends SwapOrderFormEvent {}

enum RelativePriceValue {
  floor,
  plus1,
  plus3,
  plus5,
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
    OrderRepository? orderRepository,
  })  : _orderRepository = orderRepository ?? GetIt.I<OrderRepository>(),
        super(SwapOrderFormModel(
            giveAssetBalance: MultiAddressBalanceEntry(
                address: address.address,
                quantity: 100 * TenToTheEigth.value,
                quantityNormalized: "100.00000000"),
            amountInput: AmountInput.pure(),
            priceInput: PriceInput.pure(),
            amountType: AmountType.get,
            priceType: PriceType.give,
            giveAsset: giveAsset,
            getAsset: getAsset,
            buyOrders: buyOrders,
            sellOrders: sellOrders,
            simulatedOrders: const Initial())) {
    on<AmountTypeClicked>(_handleAmountTypeClicked);
    on<PriceTypeClicked>(_handlePriceTypeClicked);
    on<AmountInputChanged>(_handleAmountInputChanged);
    on<PriceInputChanged>(_handlePriceInputChanged);
    on<RelativePriceButtonClicked>(_handleRelativePriceValueClicked);
    on<SimulatedOrdersRequested>(_handleSimulateOrdersRequested,
        transformer: debounce<SimulatedOrdersRequested>(
            const Duration(milliseconds: 300)));
  }

  _handleRelativePriceValueClicked(
    RelativePriceButtonClicked event,
    Emitter<SwapOrderFormModel> emit,
  ) {
    final floorOrder = state.buyOrders.firstOrNull;
    if (floorOrder == null) return;

    final basePrice = floorOrder.giveRemaining / floorOrder.getRemaining;

    // Determine how to display the base price (inverted if get-denominated)
    final displayPrice =
        state.priceType == PriceType.give ? 1 / basePrice : basePrice;

    final adjustmentFactor = switch ((event.value, state.priceType)) {
      (RelativePriceValue.floor, _) => 1.0,
      (RelativePriceValue.plus1, PriceType.give) => 1.01,
      (RelativePriceValue.plus3, PriceType.give) => 1.03,
      (RelativePriceValue.plus5, PriceType.give) => 1.05,
      (RelativePriceValue.plus1, PriceType.get) => 0.99,
      (RelativePriceValue.plus3, PriceType.get) => 0.97,
      (RelativePriceValue.plus5, PriceType.get) => 0.95,
    };
    add(PriceInputChanged(
        value: (displayPrice * adjustmentFactor).toStringAsFixed(8)));

    // floor price
  }

  _handlePriceInputChanged(
    PriceInputChanged event,
    Emitter<SwapOrderFormModel> emit,
  ) {
    final priceInput = PriceInput.dirty(value: event.value);

    emit(state.copyWith(
      priceInput: priceInput,
    ));

    add(SimulatedOrdersRequested());
  }

  _handleAmountInputChanged(
    AmountInputChanged event,
    Emitter<SwapOrderFormModel> emit,
  ) {
    final amountInput = AmountInput.dirty(
      value: event.value,
    );

    emit(state.copyWith(
      amountInput: amountInput,
    ));

    add(SimulatedOrdersRequested());
  }

  _handleAmountTypeClicked(
    AmountTypeClicked event,
    Emitter<SwapOrderFormModel> emit,
  ) {
    emit(
      state.copyWith(
          amountType: state.amountType == AmountType.give
              ? AmountType.get
              : AmountType.give,
          amountInput: AmountInput.pure()),
    );
  }

  _handlePriceTypeClicked(
    PriceTypeClicked event,
    Emitter<SwapOrderFormModel> emit,
  ) {
    emit(
      state.copyWith(
        priceInput: PriceInput.pure(),
        priceType:
            state.priceType == PriceType.give ? PriceType.get : PriceType.give,
      ),
    );
  }

  _handleSimulateOrdersRequested(
    SimulatedOrdersRequested event,
    Emitter<SwapOrderFormModel> emit,
  ) async {
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
        ),
        _orderRepository.getByPairTE(
          giveAsset: state.giveAsset.asset,
          getAsset: state.getAsset.asset,
          status: "open",
          httpConfig: httpConfig,
        ),
      ]));

      final buyOrders_ = result[0];
      final sellOrders = result[1];

      final price = switch (state.priceType) {
        PriceType.give => Rational.parse(state.priceInput.value),
        PriceType.get => Rational.parse(state.priceInput.value).inverse,
      };

      final priceFilter = Rational(
          state.giveAsset.divisible
              ? price.numerator * TenToTheEigth.bigIntValue
              : price.numerator,
          state.getAsset.divisible
              ? price.denominator * TenToTheEigth.bigIntValue
              : price.denominator);

      final buyOrders = buyOrders_
          .where((order) =>
              Rational.fromInt(order.getQuantity, order.giveQuantity) <=
              priceFilter)
          .toList();

      BigInt tx1GiveQuantity = state.giveQuantityInput.value.quantity;
      BigInt tx1GetQuantity = state.getQuantityInput.value.quantity;

      BigInt tx1GiveRemaining = tx1GiveQuantity;
      BigInt tx1GetRemaining = tx1GetQuantity;

      final giveDivisible = state.giveAsset.divisible;
      final getDivisible = state.getAsset.divisible;

      final candidateMatches = buyOrders;
      final simulatedOrders = <SimulatedOrder>[];

      for (final tx0 in candidateMatches) {
        print("\n\nnew loop:");
        print("\t\ttx1GetRemaining: $tx1GetRemaining");
        final tx0GiveRemaining = Rational.fromInt(tx0.giveRemaining);
        final tx0Price = Rational.fromInt(tx0.getQuantity, tx0.giveQuantity);
        final tx1InversePrice = Rational(tx1GiveRemaining, tx1GetRemaining);

        print("\t\t x1GiveRemaining: $tx1GiveRemaining");
        print("\t\t x1InversePrice: $tx1InversePrice");
        print("\t\t x1GiveRemaining: $tx1GiveRemaining");
        print("\t\t x0Price: $tx0Price");
        print("\t\t\t\t x0Price: $tx0Price");

        if (tx0Price > tx1InversePrice) {
          print("\n\nwe are continuing");
          print("\t\ttx1GiveRemaining: $tx1GiveRemaining");
          print("\t\ttx1GetRemaining: $tx1GetRemaining");
          print("\t\ttx0Price: $tx0Price");
          print("\t\ttx1InversePrice: $tx1InversePrice");

          continue;
        }

        print("\n\n\ntx0GiveRemaining: $tx0GiveRemaining");
        print("tx1GiveRemaining: $tx1GiveRemaining");

        print(
            "tx1GiveRemaining / tx0Price: ${(Rational(tx1GiveRemaining) / tx0Price)}");
        print("tx0Price $tx0Price");

        print("tx1GetRemaining: $tx1GetRemaining");

        Rational forwardQuantity = rationalMinList([
          tx0GiveRemaining,
          Rational(tx1GiveRemaining) / tx0Price,
        ]);

        Rational backwardQuantity = (forwardQuantity * tx0Price);

        if (forwardQuantity == Rational.zero) {
          continue;
        }

        if (backwardQuantity == Rational.zero) {
          continue;
        }

        // Rational forwardQuantity = switch ((
        //   state.giveAsset.divisible,
        //   state.getAsset.divisible
        // )) {
        //   (false, true) => forwardQuantity_,
        //   _ => forwardQuantity_
        // };
        //
        // Rational backwardQuantity = switch ((
        //   state.giveAsset.divisible,
        //   state.getAsset.divisible
        // )) {
        //   (true, false) => backwardQuantity_,
        //   _ => backwardQuantity_
        // };

        print("backward_quantity_ $backwardQuantity");
        print("backward_quantity $backwardQuantity");

        print("forward_quantity_ $forwardQuantity");
        print("forward_quantity $forwardQuantity");

        tx1GiveRemaining -= backwardQuantity.toBigInt();
        tx1GetRemaining -= forwardQuantity.toBigInt();

        simulatedOrders.add(SimulatedOrderMatch(
          give: AssetQuantity(
            divisible: giveDivisible,
            quantity: backwardQuantity.toBigInt(),
          ),
          get: AssetQuantity(
            divisible: getDivisible,
            quantity: forwardQuantity.toBigInt(),
          ),
        ));

        print("tx1GiveRemaining $tx1GiveRemaining");
      }

      print("tx1GiveQUantity: $tx1GiveQuantity");
      print("tx1GiveQUantity: $tx1GetQuantity");

      final tx1PriceMax = switch (state.priceType) {
        PriceType.give => Rational(tx1GetQuantity, tx1GiveQuantity),
        PriceType.get => Rational(tx1GiveQuantity, tx1GetQuantity)
      };

      if (state.amountType == AmountType.give &&
          tx1GiveRemaining > BigInt.zero) {
        final getAmount = tx1GetRemaining;

        final getQuantity = switch ((giveDivisible, getDivisible)) {
          (true, true) => getAmount,
          (true, false) => getAmount,
          (false, true) => getAmount,
          (false, false) => getAmount
        };

        print("case 1");
        print("tx1getRemaining: $tx1GetRemaining");
        simulatedOrders.add(SimulatedOrderCreate(
            give: AssetQuantity(
                divisible: giveDivisible, quantity: tx1GiveRemaining),
            get:
                AssetQuantity(divisible: getDivisible, quantity: getQuantity)));
      }

      if (state.amountType == AmountType.get && tx1GetRemaining > BigInt.zero) {
        print("case2");

        simulatedOrders.add(SimulatedOrderCreate(
            give: AssetQuantity(
                divisible: giveDivisible, quantity: tx1GiveRemaining),
            get: AssetQuantity(
                divisible: getDivisible, quantity: tx1GetRemaining)));
      }
      return (buyOrders, sellOrders, simulatedOrders);
    });

    final result = await task.run();

    final nextState = result.fold(
      (error) => state.copyWith(simulatedOrders: Failure(error)),
      (success) => state.copyWith(
        buyOrders: success.$1,
        sellOrders: success.$2,
        simulatedOrders: Success(success.$3),
      ),
    );

    emit(nextState);
  }
}

EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => events
      .debounceTime(duration) // wait until the stream is quiet
      .switchMap(mapper); // then run the handler once
}
