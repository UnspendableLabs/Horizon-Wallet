import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/repositories/atomic_swap_repository.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';

enum SliderInputError {
  required,
}

class SliderInput extends FormzInput<int, void> {
  const SliderInput.pure() : super.pure(0);
  const SliderInput.dirty({required int value}) : super.dirty(value);

  @override
  SliderInputError? validator(int value) {
    if (value == 0) {
      return SliderInputError.required;
    }
    return null;
  }
}

enum TotalCostValidationError {
  insufficientBalance,
}

class TotalCostInput
    extends FormzInput<AssetQuantity, TotalCostValidationError> {
  final AssetQuantity userBalance;

  TotalCostInput.pure({
    required this.userBalance,
  }) : super.pure(AssetQuantity(divisible: true, quantity: BigInt.zero));

  const TotalCostInput.dirty({
    required AssetQuantity value,
    required this.userBalance,
  }) : super.dirty(value);

  @override
  TotalCostValidationError? validator(AssetQuantity value) {
    return value.quantity > userBalance.quantity
        ? TotalCostValidationError.insufficientBalance
        : null;
  }
}

class AtomicSwapListModel {
  final Asset asset;
  final List<AtomicSwapListItemModel> items;
  AtomicSwapListModel({required this.asset, required this.items});
}

class AtomicSwapListItemModel {
  final bool selected;
  final Asset asset;
  final AssetQuantity quantity;
  final BigInt price;
  final BigInt pricePerUnit;

  AtomicSwapListItemModel({
    required this.selected,
    required this.asset,
    required this.quantity,
    required this.price,
    required this.pricePerUnit,
  });
}

class SwapSliderFormModel with FormzMixin {
  final String assetName;
  final RemoteData<List<AtomicSwap>> atomicSwaps;
  final RemoteData<Asset> asset;
  final SliderInput sliderInput;
  final TotalCostInput totalCostInput;

  SwapSliderFormModel(
      {required this.assetName,
      required this.atomicSwaps,
      required this.asset,
      required this.sliderInput,
      required this.totalCostInput});

  @override
  List<FormzInput> get inputs => [sliderInput, totalCostInput];

  SwapSliderFormModel copyWith({
    String? assetName,
    RemoteData<List<AtomicSwap>>? atomicSwaps,
    RemoteData<Asset>? asset,
    SliderInput? sliderInput,
    TotalCostInput? totalCostInput,
  }) {
    return SwapSliderFormModel(
      sliderInput: sliderInput ?? this.sliderInput,
      totalCostInput: totalCostInput ?? this.totalCostInput,
      assetName: assetName ?? this.assetName,
      atomicSwaps: atomicSwaps ?? this.atomicSwaps,
      asset: asset ?? this.asset,
    );
  }

  AssetQuantity get totalPrice {
    final zero = AssetQuantity(
      divisible: true,
      quantity: BigInt.zero,
    );

    return atomicSwapListModel.fold(
        onInitial: () => zero,
        onLoading: () => zero,
        onFailure: (_) => zero,
        onSuccess: (model) => model.items.filter((item) => item.selected).fold(
            AssetQuantity(
              quantity: BigInt.zero,
              divisible: true, // quantities from swaps api are always divisible
              // divisible: model.asset.divisible ?? false
            ),
            (previousValue, element) =>
                previousValue +
                AssetQuantity(divisible: true, quantity: element.price)),
        onRefreshing: (model) => model.items
            .filter((item) => item.selected)
            .fold(
                AssetQuantity(
                  quantity: BigInt.zero,
                  divisible:
                      true, // quantities from swaps api are always divisible
                ),
                (previousValue, element) =>
                    previousValue +
                    AssetQuantity(divisible: true, quantity: element.price)));
  }

  AssetQuantity get total {
    final zero = AssetQuantity(
      divisible: true,
      quantity: BigInt.zero,
    );

    return atomicSwapListModel.fold(
      onInitial: () => zero,
      onLoading: () => zero,
      onFailure: (_) => zero,
      onSuccess: (model) => model.items.filter((item) => item.selected).fold(
            AssetQuantity(
              quantity: BigInt.zero,
              divisible: true, // quantities from swaps api are always divisible
              // divisible: model.asset.divisible ?? false
            ),
            (previousValue, element) => previousValue + element.quantity,
          ),
      onRefreshing: (model) => model.items.filter((item) => item.selected).fold(
            AssetQuantity(
              quantity: BigInt.zero,
              divisible: true, // quantities from swaps api are always divisible
            ),
            (previousValue, element) => previousValue + element.quantity,
          ),
    );
  }

  RemoteData<AtomicSwapListModel> get atomicSwapListModel {
    return asset.combine(atomicSwaps, (asset, atomicSwaps) {
      final swaps = atomicSwaps
          .mapWithIndex((swap, idx) => AtomicSwapListItemModel(
              selected: idx + 1 <= sliderInput.value,
              asset: asset,
              quantity: AssetQuantity(
                divisible: true,
                quantity: swap.assetQuantity,
              ),
              price: swap.price,
              pricePerUnit: swap.pricePerUnit))
          .toList();

      return AtomicSwapListModel(items: swaps, asset: asset);
    });
  }
}

sealed class SwapSliderFormEvent extends Equatable {
  const SwapSliderFormEvent();

  @override
  List<Object?> get props => [];
}

class SwapSliderFormInitialized extends SwapSliderFormEvent {}

class SliderDragged extends SwapSliderFormEvent {
  final int value;
  const SliderDragged({required this.value});
}

class SwapSliderFormBloc
    extends Bloc<SwapSliderFormEvent, SwapSliderFormModel> {
  final HttpConfig httpConfig;
  final AtomicSwapRepository _atomicSwapRepository;
  final AssetRepository _assetRepository;

  SwapSliderFormBloc({
    required String assetName,
    required MultiAddressBalanceEntry bitcoinBalance,
    required this.httpConfig,
    AtomicSwapRepository? atomicSwapRepository,
    AssetRepository? assetRepository,
  })  : _atomicSwapRepository =
            atomicSwapRepository ?? GetIt.I<AtomicSwapRepository>(),
        _assetRepository = assetRepository ?? GetIt.I<AssetRepository>(),
        super(
          SwapSliderFormModel(
              totalCostInput: TotalCostInput.pure(
                  userBalance: AssetQuantity(
                quantity: BigInt.from(bitcoinBalance.quantity),
                divisible: true,
              )),
              assetName: assetName,
              atomicSwaps: const Initial<List<AtomicSwap>>(),
              asset: const Initial<Asset>(),
              sliderInput: const SliderInput.pure()),
        ) {
    on<SwapSliderFormInitialized>(_handleInitialized);
    on<SliderDragged>(_handleSliderDragged);

    add(SwapSliderFormInitialized());
  }

  _handleInitialized(
    SwapSliderFormInitialized event,
    Emitter<SwapSliderFormModel> emit,
  ) async {
    emit(state.copyWith(atomicSwaps: const Loading()));

    final task = TaskEither.sequenceList([
      _assetRepository.getAssetVerboseT(
        httpConfig: httpConfig,
        assetName: state.assetName,
      ),
      _atomicSwapRepository.getSwapsByAssetT(
        httpConfig: httpConfig,
        asset: state.assetName,
        orderBy: "price",
        order: "asc",
      )
    ]);

    final result = await task.run();

    result.fold(
      (err) => emit(
        state.copyWith(atomicSwaps: Failure(err), asset: Failure(err)),
      ),
      (result) => emit(
          // Chat is there any way to avoid this typecast?
          state.copyWith(
              asset: Success(result[0] as Asset),
              atomicSwaps: Success([
                ...result[1] as List<AtomicSwap>,
              ]))),
    );
  }

  _handleSliderDragged(
    SliderDragged event,
    Emitter<SwapSliderFormModel> emit,
  ) {
    final nextState = state.copyWith(
      sliderInput: SliderInput.dirty(value: event.value),
    );

    emit(
      nextState.copyWith(
        totalCostInput: TotalCostInput.dirty(
          value: nextState.totalPrice,
          userBalance: nextState.totalCostInput.userBalance,
        ),
      ),
    );
  }
}
