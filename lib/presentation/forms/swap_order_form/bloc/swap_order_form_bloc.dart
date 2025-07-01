import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/order.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
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
  final AssetQuantity userBalance;

  ReceiveQuantityInput.pure({
    required this.userBalance,
  }) : super.pure(AssetQuantity(divisible: true, quantity: BigInt.zero));

  const ReceiveQuantityInput.dirty({
    required AssetQuantity value,
    required this.userBalance,
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
  final String giveAsset;
  final String receiveAsset;

  final RemoteData<List<Order>> buyOrders;
  final RemoteData<List<Order>> sellOrders;

  final AmountType amountType;
  final PriceType priceType;

  final AmountInput amountInput;

  const SwapOrderFormModel({
    required this.amountInput,
    required this.amountType,
    required this.giveAsset,
    required this.receiveAsset,
    required this.buyOrders,
    required this.sellOrders,
    required this.priceType,
  });

  @override
  List<FormzInput> get inputs => [amountInput];

  SwapOrderFormModel copyWith({
    AmountInput? amountInput,
    String? giveAsset,
    String? receiveAsset,
    RemoteData<List<Order>>? buyOrders,
    RemoteData<List<Order>>? sellOrders,
    AmountType? amountType,
    PriceType? priceType,
  }) {
    return SwapOrderFormModel(
      amountInput: amountInput ?? this.amountInput,
      priceType: priceType ?? this.priceType,
      amountType: amountType ?? this.amountType,
      giveAsset: giveAsset ?? this.giveAsset,
      receiveAsset: receiveAsset ?? this.receiveAsset,
      buyOrders: buyOrders ?? this.buyOrders,
      sellOrders: sellOrders ?? this.sellOrders,
    );
  }

  RemoteData<ViewModel> get viewModel {
    return buyOrders.combine(
        sellOrders,
        (buy, sell) => ViewModel(
              priceString: priceType == PriceType.give
                  ? "${giveAsset} / ${receiveAsset}"
                  : "${receiveAsset} / ${giveAsset}",
              priceAsset:
                  priceType == PriceType.give ? giveAsset : receiveAsset,
              amountAsset:
                  amountType == AmountType.give ? giveAsset : receiveAsset,
              sellOrders: sell
                  .map((el) => el.toViewModel(side: OrderViewModelSide.sell))
                  .toList()
                ..sort((a, b) =>
                    a.price.quantity.compareTo(b.price.quantity)), // ascending

              buyOrders: buy
                  .map((el) => el.toViewModel(side: OrderViewModelSide.buy))
                  .toList()
                ..sort((a, b) =>
                    b.price.quantity.compareTo(a.price.quantity)), // descending
            ));
  }
}

enum AmountType {
  give,
  get,
}

enum PriceType { give, get }

class ViewModel {
  final String amountAsset;
  final String priceAsset;

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

class SwapOrderFormInitialized extends SwapOrderFormEvent {}

class AmountTypeClicked extends SwapOrderFormEvent {}

class PriceTypeClicked extends SwapOrderFormEvent {}

class AmountInputChanged extends SwapOrderFormEvent {
  final String value;
  const AmountInputChanged({required this.value});
}

class SwapOrderFormBloc extends Bloc<SwapOrderFormEvent, SwapOrderFormModel> {
  final HttpConfig httpConfig;
  final OrderRepository _orderRepository;

  final AddressV2 address;
  final String receiveAsset;
  final String giveAsset;

  SwapOrderFormBloc({
    required this.address,
    required this.httpConfig,
    required this.receiveAsset,
    required this.giveAsset,
    OrderRepository? orderRepository,
  })  : _orderRepository = orderRepository ?? GetIt.I<OrderRepository>(),
        super(SwapOrderFormModel(
          amountInput: AmountInput.pure(),
          amountType: AmountType.get,
          priceType: PriceType.give,
          giveAsset: giveAsset,
          receiveAsset: receiveAsset,
          buyOrders: const Initial(),
          sellOrders: const Initial(),
        )) {
    on<SwapOrderFormInitialized>(_handleSwapSliderFormInitialized);
    on<AmountTypeClicked>(_handleAmountTypeClicked);
    on<PriceTypeClicked>(_handlePriceTypeClicked);
    on<AmountInputChanged>(_handleAmountInputChanged);
    add(SwapOrderFormInitialized());
  }

  _handleAmountInputChanged(
    AmountInputChanged event,
    Emitter<SwapOrderFormModel> emit,
  ) {

    final amountInput = AmountInput.dirty(
      value: AssetQuantity.fromNormalizedString(
          divisible: true, input: event.value),
    );


    print(amountInput.value.quantity);

    emit(state.copyWith(
      amountInput: amountInput,
    ));
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
      ),
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

  _handleSwapSliderFormInitialized(
    SwapOrderFormInitialized event,
    Emitter<SwapOrderFormModel> emit,
  ) async {
    emit(state.copyWith(
      buyOrders: const Loading(),
      sellOrders: const Loading(),
    ));

    final task = TaskEither<String, AsyncData>.Do(($) async {
      final sequence = await $(TaskEither.sequenceList([
        _orderRepository.getByPairTE(
          status: "open",
          address: address.address,
          giveAsset: receiveAsset,
          getAsset: giveAsset,
          httpConfig: httpConfig,
        ),
        _orderRepository.getByPairTE(
          address: address.address,
          giveAsset: giveAsset,
          getAsset: receiveAsset,
          status: "open",
          httpConfig: httpConfig,
        )
      ]));

      return AsyncData(
        buyOrders: sequence[0],
        sellOrders: sequence[1],
      );
    });

    final result = await task.run();

    result.fold(
      (error) => emit(
        state.copyWith(
          buyOrders: Failure(error.toString()),
          sellOrders: Failure(error.toString()),
        ),
      ),
      (response) => emit(
        state.copyWith(
          buyOrders: Success(response.buyOrders),
          sellOrders: Success(response.sellOrders),
        ),
      ),
    );

    // Initialize the form or perform any necessary setup
  }
}
