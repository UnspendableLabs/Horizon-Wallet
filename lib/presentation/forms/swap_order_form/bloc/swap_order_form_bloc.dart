import 'dart:math';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:formz/formz.dart';
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

int toRawUnits(int quantity, bool divisible) =>
    divisible ? quantity * TenToTheEigth.value.toInt() : quantity;

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
            value: AssetQuantity.fromNormalizedStringSafe(
                    divisible: giveAsset.divisible,
                    input: (getQuantityInput.value.normalizedNum() *
                            (num.tryParse(priceInput.value) ?? 0))
                        .toString())
                .getOrElse((_) => AssetQuantity(
                    divisible: giveAsset.divisible, quantity: BigInt.zero)),
            userBalance: AssetQuantity(
                divisible: giveAsset.divisible,
                quantity: BigInt.from(giveAssetBalance.quantity))),
        ((AmountType.get, PriceType.get)) => GiveQuantityInput.dirty(
            value: AssetQuantity.fromNormalizedStringSafe(
                    divisible: giveAsset.divisible,
                    input: (AssetQuantity.fromNormalizedString(
                                    divisible: getAsset.divisible,
                                    input: amountInput.value)
                                .normalizedNum() /
                            (num.tryParse(priceInput.value) ?? 0))
                        .toString())
                .getOrElse((error) {
              return AssetQuantity(
                divisible: giveAsset.divisible,
                quantity: BigInt.zero,
              );
            }),
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
            value: AssetQuantity.fromNormalizedString(
                divisible: getAsset.divisible,
                input: (double.parse(amountInput.value) /
                        double.parse(priceInput.value))
                    .toString())),
        ((AmountType.give, PriceType.get)) => GetQuantityInput.dirty(
            value: AssetQuantity.fromNormalizedString(
                divisible: getAsset.divisible,
                input: (double.parse(amountInput.value) *
                        double.parse(priceInput.value))
                    .toString())),
      };

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

        final buyOrders = result[0];
        final sellOrders = result[1];

        AssetQuantity tx1GiveQuantity = state.giveQuantityInput.value;
        AssetQuantity tx1GetQuantity = state.getQuantityInput.value;

        print("tx1GiveQuantity: $tx1GiveQuantity");

        AssetQuantity tx1GiveRemaining = tx1GiveQuantity;
        AssetQuantity tx1GetRemaining = tx1GetQuantity;

        final giveDivisible = state.giveAsset.divisible;
        final getDivisible = state.getAsset.divisible;

        final candidateMatches = buyOrders;
        final simulatedOrders = <SimulatedOrder>[];

        final tx1PriceMax = switch (state.priceType) {
          PriceType.give => tx1GetQuantity / tx1GiveQuantity,
          PriceType.get => tx1GiveQuantity / tx1GetQuantity
        };

        for (final tx0 in candidateMatches) {
          final tx0GiveRemaining = AssetQuantity(
              quantity: BigInt.from(tx0.giveRemaining),
              divisible: getDivisible);
          final tx0Price = AssetQuantity.fromNormalizedString(
              input: (tx0.getQuantity / tx0.giveQuantity).toString(),
              divisible: true);

          final tx1InversePrice = tx1GiveQuantity / tx1GetQuantity;

          if (tx0Price.quantity > tx1InversePrice.quantity) {
            print("skip");
            print("tx0Price: $tx0Price");
            print("tx1InversePrice: $tx1InversePrice");
            continue;
          }

          print("tx1GiveRemaining: $tx1GiveRemaining");
          print("tx0Price: $tx0Price");
          print("divided: ${tx1GiveRemaining / tx0Price}");
          print("divided normalized: ${(tx1GiveRemaining / tx0Price).normalizedNum()}");

          int forwardQuantity = min(tx0GiveRemaining.normalizedNum().toInt(),
              (tx1GiveRemaining / tx0Price).normalizedNum().toInt());

          int backwardQuantity =
              (forwardQuantity * tx0Price.normalizedNum()).round();

          print("forward wquantity $forwardQuantity");
          print("backward wquantity $backwardQuantity");

          if (forwardQuantity == 0) {
            continue;
          }

          if (backwardQuantity == 0) {
            continue;
          }

          int backwardQuantityRaw = toRawUnits(backwardQuantity, giveDivisible);

          int forwardQuantityRaw = toRawUnits(forwardQuantity, getDivisible);

          simulatedOrders.add(SimulatedOrderMatch(
            give: AssetQuantity(
              divisible: giveDivisible,

              // chat
              // this seems to be the issue, and only results when give and get divisibility are distinct
              quantity: BigInt.from(backwardQuantityRaw),
            ),
            get: AssetQuantity(
              divisible: getDivisible,
              quantity: BigInt.from(forwardQuantityRaw),
            ),
          ));

          tx1GiveRemaining -= AssetQuantity.fromNormalizedString(
              input: backwardQuantity.toString(), divisible: giveDivisible);
          tx1GetRemaining -= AssetQuantity.fromNormalizedString(
              input: forwardQuantity.toString(), divisible: getDivisible);
        }

        if (state.amountType == AmountType.give &&
            tx1GiveRemaining.quantity > BigInt.zero) {
          final getAmount = switch (state.priceType) {
            PriceType.give => (tx1GiveRemaining * tx1PriceMax),
            PriceType.get => (tx1GiveRemaining / tx1PriceMax),
          };

          final getQuantity = switch ((giveDivisible, getDivisible)) {
            (true, true) => getAmount.quantity,
            (true, false) =>
              BigInt.from(getAmount.quantity / TenToTheEigth.bigIntValue),
            (false, true) => getAmount.quantity,
            (false, false) =>
              BigInt.from(getAmount.quantity / TenToTheEigth.bigIntValue)
          };

          print("case 1");
          simulatedOrders.add(SimulatedOrderCreate(
              give: tx1GiveRemaining,
              get: AssetQuantity(
                  divisible: getDivisible, quantity: getQuantity)));
        }

        if (state.amountType == AmountType.get &&
            tx1GetRemaining.quantity > BigInt.zero) {
          print("case2");
          simulatedOrders.add(SimulatedOrderCreate(
            give: tx1GiveRemaining,
            get: tx1GetRemaining,
          ));
        }

        return (buyOrders, sellOrders, simulatedOrders);
      },
    );

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
