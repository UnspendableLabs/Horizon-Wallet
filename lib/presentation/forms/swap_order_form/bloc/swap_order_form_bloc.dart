import 'dart:math';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/remote_data.dart';
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

sealed class SimulatedOrder extends Equatable {
  final AssetQuantity give;
  final AssetQuantity get;

  const SimulatedOrder({required this.give, required this.get});

  @override
  List<Object?> get props => [];
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
            value: AssetQuantity.fromNormalizedString(
                divisible: giveAsset.divisible, input: amountInput.value),
            userBalance: AssetQuantity(
                divisible: giveAsset.divisible,
                quantity: BigInt.from(giveAssetBalance.quantity))),
        ((AmountType.get, PriceType.give)) => GiveQuantityInput.dirty(

            value: AssetQuantity.fromNormalizedString(
                divisible: giveAsset.divisible,
                input: (getQuantityInput.value.normalizedNum() *
                        (num.tryParse(priceInput.value) ?? 0))
                    .toString()),
            userBalance: AssetQuantity(
                divisible: giveAsset.divisible,
                quantity: BigInt.from(giveAssetBalance.quantity))),
        ((AmountType.get, PriceType.get)) => GiveQuantityInput.dirty(
            value: AssetQuantity.fromNormalizedString(
                divisible: giveAsset.divisible,
                input: (AssetQuantity.fromNormalizedString(
                                divisible: getAsset.divisible,
                                input: amountInput.value)
                            .normalizedNum() /
                        AssetQuantity.fromNormalizedString(
                                divisible: getAsset.divisible,
                                input: priceInput.value)
                            .normalizedNum())
                    .toString()),
            userBalance: AssetQuantity(
                divisible: giveAsset.divisible,
                quantity: BigInt.from(giveAssetBalance.quantity))),
      };

  GetQuantityInput get getQuantityInput => switch ((amountType, priceType)) {
        ((AmountType.get, _)) => GetQuantityInput.dirty(
            value: AssetQuantity.fromNormalizedString(
                divisible: getAsset.divisible, input: amountInput.value)),
        ((AmountType.give, PriceType.give)) => GetQuantityInput.dirty(
            value: AssetQuantity.fromNormalizedString(
                divisible: getAsset.divisible,
                input: (AssetQuantity.fromNormalizedString(
                                divisible: giveAsset.divisible,
                                input: amountInput.value)
                            .normalizedNum() /
                        AssetQuantity.fromNormalizedString(
                                divisible: giveAsset.divisible,
                                input: priceInput.value)
                            .normalizedNum())
                    .toString())),
        ((AmountType.give, PriceType.get)) => GetQuantityInput.dirty(
            value: AssetQuantity.fromNormalizedString(
                divisible: getAsset.divisible,
                input: (AssetQuantity.fromNormalizedString(
                                divisible: giveAsset.divisible,
                                input: amountInput.value)
                            .normalizedNum() *
                        AssetQuantity.fromNormalizedString(
                                divisible: getAsset.divisible,
                                input: priceInput.value)
                            .normalizedNum())
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
    on<SimulatedOrdersRequested>(_handleSimulateOrdersRequested,
        transformer: debounce<SimulatedOrdersRequested>(
            const Duration(milliseconds: 300)));
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
            address: address.address,
            giveAsset: state.getAsset.asset,
            getAsset: state.giveAsset.asset,
            httpConfig: httpConfig,
          ),
          _orderRepository.getByPairTE(
            address: address.address,
            giveAsset: state.giveAsset.asset,
            getAsset: state.getAsset.asset,
            status: "open",
            httpConfig: httpConfig,
          ),
        ]));

        final buyOrders = result[0];
        final sellOrders = result[1];

        int tx1GiveRemaining = state.giveQuantityInput.value.quantity.toInt();
        int tx1GetRemaining = state.getQuantityInput.value.quantity.toInt();

        final giveDivisible = state.giveAsset.divisible;
        final getDivisible = state.getAsset.divisible;

        final candidateMatches = buyOrders;

        final simulatedOrders = <SimulatedOrder>[];

        final tx1Price = state.getQuantityInput.value.normalizedNum() /
            state.giveQuantityInput.value.normalizedNum();
        final tx1InversePrice = state.giveQuantityInput.value.normalizedNum() /
            state.getQuantityInput.value.normalizedNum();

        for (final tx0 in candidateMatches) {
          final tx0GiveRemaining = tx0.giveRemaining;
          final tx0GetRemaining = tx0.getRemaining;
          final tx0Price = tx0.getQuantity / tx0.giveQuantity;

          if (tx0Price > tx1InversePrice) {
            continue;
          }

          int forwardQuantity = min(
            tx0GiveRemaining,
            (tx1GiveRemaining / tx0Price).floor(),
          );
          int backwardQuantity = (forwardQuantity * tx0Price).round();

          if (forwardQuantity == 0 || backwardQuantity == 0) {
            continue;
          }

          simulatedOrders.add(SimulatedOrderMatch(
            give: AssetQuantity(
              divisible: giveDivisible,
              quantity: BigInt.from(backwardQuantity),
            ),
            get: AssetQuantity(
              divisible: getDivisible,
              quantity: BigInt.from(forwardQuantity),
            ),
          ));

          tx1GiveRemaining -= backwardQuantity;
          tx1GetRemaining -= forwardQuantity;
        }

        if (tx1GiveRemaining > 0 && tx1GetRemaining > 0) {
          simulatedOrders.add(SimulatedOrderCreate(
            give: AssetQuantity(
              divisible: giveDivisible,
              quantity: BigInt.from(tx1GiveRemaining),
            ),
            get: AssetQuantity(
              divisible: getDivisible,
              quantity: BigInt.from(tx1GetRemaining),
            ),
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
