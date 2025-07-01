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

enum OrderViewModelSide { buy, sell }

class OrderViewModel {
  final OrderViewModelSide side;
  final AssetQuantity quantity;
  final AssetQuantity price;
  OrderViewModel(
      {required this.side, required this.quantity, required this.price});
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

    return OrderViewModel(
      side: side,
      quantity: AssetQuantity(
          divisible: divisible, quantity: BigInt.from(giveRemaining)),
      price: AssetQuantity(divisible: true, quantity: BigInt.from(price)),
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

  const SwapOrderFormModel({
    required this.amountType,
    required this.giveAsset,
    required this.receiveAsset,
    required this.buyOrders,
    required this.sellOrders,
    required this.priceType,
  });

  @override
  List<FormzInput> get inputs => [];

  SwapOrderFormModel copyWith({
    String? giveAsset,
    String? receiveAsset,
    RemoteData<List<Order>>? buyOrders,
    RemoteData<List<Order>>? sellOrders,
    AmountType? amountType,
    PriceType? priceType,
  }) {
    return SwapOrderFormModel(
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

  ViewModel({
    required this.priceAsset,
    required this.amountAsset,
    required this.sellOrders,
    required this.buyOrders,
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
    add(SwapOrderFormInitialized());
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
        priceType: state.priceType == PriceType.give
            ? PriceType.get
            : PriceType.give,
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
