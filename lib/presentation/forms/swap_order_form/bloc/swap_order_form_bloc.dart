import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/remote_data.dart';
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

enum AmountInputError { required }

class AmountInput extends FormzInput<AssetQuantity, AmountInputError> {
  AmountInput.pure()
      : super.pure(AssetQuantity(divisible: true, quantity: BigInt.zero));
  const AmountInput.dirty({
    required AssetQuantity value,
  }) : super.dirty(value);
  @override
  AmountInputError? validator(AssetQuantity value) {
    return value.quantity == BigInt.zero ? AmountInputError.required : null;
  }
}

enum PriceInputError { required }

class PriceInput extends FormzInput<AssetQuantity, PriceInputError> {
  final AssetQuantity userBalance;
  PriceInput.pure({
    required this.userBalance,
  }) : super.pure(AssetQuantity(divisible: true, quantity: BigInt.zero));
  const PriceInput.dirty({
    required AssetQuantity value,
    required this.userBalance,
  }) : super.dirty(value);
  @override
  PriceInputError? validator(AssetQuantity value) {
    return value.quantity == BigInt.zero ? PriceInputError.required : null;
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

enum ReceiveQuantityInputError { required }

class ReceiveQuantityInput
    extends FormzInput<AssetQuantity, ReceiveQuantityInputError> {
  ReceiveQuantityInput.pure({required bool divisible})
      : super.pure(AssetQuantity(divisible: divisible, quantity: BigInt.zero));

  const ReceiveQuantityInput.dirty({
    required AssetQuantity value,
  }) : super.dirty(value);

  @override
  ReceiveQuantityInputError? validator(AssetQuantity value) {
    if (value.quantity == BigInt.zero) {
      return ReceiveQuantityInputError.required;
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
  final MultiAddressBalanceEntry giveAssetBalance;

  final Asset giveAsset;
  final Asset receiveAsset;

  final List<Order> buyOrders;
  final List<Order> sellOrders;

  final AmountType amountType;
  final PriceType priceType;

  final AmountInput amountInput;
  final PriceInput priceInput;

  final GiveQuantityInput giveQuantityInput;
  final ReceiveQuantityInput receiveQuantityInput;

  const SwapOrderFormModel({
    required this.giveAssetBalance,
    required this.amountInput,
    required this.priceInput,
    required this.giveQuantityInput,
    required this.receiveQuantityInput,
    required this.amountType,
    required this.giveAsset,
    required this.receiveAsset,
    required this.buyOrders,
    required this.sellOrders,
    required this.priceType,
  });

  @override
  List<FormzInput> get inputs =>
      [amountInput, priceInput, giveQuantityInput, receiveQuantityInput];

  SwapOrderFormModel copyWith(
      {MultiAddressBalanceEntry? giveAssetBalance,
      AmountInput? amountInput,
      PriceInput? priceInput,
      Asset? giveAsset,
      Asset? receiveAsset,
      List<Order>? buyOrders,
      List<Order>? sellOrders,
      AmountType? amountType,
      PriceType? priceType,
      GiveQuantityInput? giveQuantityInput,
      ReceiveQuantityInput? receiveQuantityInput}) {
    return SwapOrderFormModel(
      giveQuantityInput: giveQuantityInput ?? this.giveQuantityInput,
      receiveQuantityInput: receiveQuantityInput ?? this.receiveQuantityInput,
      giveAssetBalance: giveAssetBalance ?? this.giveAssetBalance,
      priceInput: priceInput ?? this.priceInput,
      amountInput: amountInput ?? this.amountInput,
      priceType: priceType ?? this.priceType,
      amountType: amountType ?? this.amountType,
      giveAsset: giveAsset ?? this.giveAsset,
      receiveAsset: receiveAsset ?? this.receiveAsset,
      buyOrders: buyOrders ?? this.buyOrders,
      sellOrders: sellOrders ?? this.sellOrders,
    );
  }

  String get priceString {
    return priceType == PriceType.give
        ? "${giveAsset.displayName} / ${receiveAsset.displayName}"
        : "${receiveAsset.displayName} / ${giveAsset.displayName}";
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
    return amountType == AmountType.give ? giveAsset : receiveAsset;
  }

  Asset get priceAsset {
    return priceType == PriceType.give ? giveAsset : receiveAsset;
  }

  Option<String> get amountInputError {
    if (amountInput.isPure) {
      return none();
    }

    final error = amountType == AmountType.give
        ? giveQuantityInput.error
        : receiveQuantityInput.error;

    return Option.fromNullable(error?.toString());
  }
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

class SwapOrderFormBloc extends Bloc<SwapOrderFormEvent, SwapOrderFormModel> {
  final HttpConfig httpConfig;

  final AddressV2 address;

  SwapOrderFormBloc({
    required this.address,
    required this.httpConfig,
    required Asset receiveAsset,
    required Asset giveAsset,
    required List<Order> buyOrders,
    required List<Order> sellOrders,
    OrderRepository? orderRepository,
  }) : super(SwapOrderFormModel(
          giveAssetBalance: MultiAddressBalanceEntry(
              address: address.address,
              quantity: 100 * TenToTheEigth.value,
              quantityNormalized: "100.00000000"),
          giveQuantityInput: GiveQuantityInput.pure(
              userBalance: AssetQuantity(
                  divisible: giveAsset.divisible,
                  quantity: BigInt.from(100 * TenToTheEigth.value))),
          receiveQuantityInput:
              ReceiveQuantityInput.pure(divisible: receiveAsset.divisible),
          amountInput: AmountInput.pure(),
          priceInput: PriceInput.pure(
            userBalance: AssetQuantity(divisible: true, quantity: BigInt.zero),
          ),
          amountType: AmountType.get,
          priceType: PriceType.give,
          giveAsset: giveAsset,
          receiveAsset: receiveAsset,
          buyOrders: buyOrders,
          sellOrders: sellOrders,
        )) {
    on<AmountTypeClicked>(_handleAmountTypeClicked);
    on<PriceTypeClicked>(_handlePriceTypeClicked);
    on<AmountInputChanged>(_handleAmountInputChanged);
  }

  _handleAmountInputChanged(
    AmountInputChanged event,
    Emitter<SwapOrderFormModel> emit,
  ) {
    final amountInput = AmountInput.dirty(
      value: AssetQuantity.fromNormalizedString(
          divisible: state.amountAsset.divisible, input: event.value),
    );

    final giveQuantityInput = state.amountType == AmountType.give
        ? GiveQuantityInput.dirty(
            value: amountInput.value,
            userBalance: state.giveQuantityInput.userBalance)
        : state.giveQuantityInput;

    final receiveQuantityInput = state.amountType == AmountType.get
        ? ReceiveQuantityInput.dirty(value: amountInput.value)
        : state.receiveQuantityInput;

    emit(state.copyWith(
        amountInput: amountInput,
        giveQuantityInput: giveQuantityInput,
        receiveQuantityInput: receiveQuantityInput));
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
        priceType:
            state.priceType == PriceType.give ? PriceType.get : PriceType.give,
      ),
    );
  }
}
