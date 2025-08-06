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

enum SelectionMode { slider, manual }

enum SelectedAtomicSwapsValidationError { empty }

class SelectedAtomicSwapsInput
    extends FormzInput<List<AtomicSwap>, SelectedAtomicSwapsValidationError> {
  const SelectedAtomicSwapsInput.pure() : super.pure(const []);
  const SelectedAtomicSwapsInput.dirty({required List<AtomicSwap> value})
      : super.dirty(value);

  @override
  SelectedAtomicSwapsValidationError? validator(List<AtomicSwap> value) {
    return value.isEmpty ? SelectedAtomicSwapsValidationError.empty : null;
  }

  AssetQuantity get totalPrice {
    return value.fold(AssetQuantity(divisible: true, quantity: BigInt.zero),
        (prev, item) {
      return prev + item.price;
    });
  }

  AssetQuantity get totalQuantity => value.fold(
      AssetQuantity(
        quantity: BigInt.zero,
        divisible: true, // quantities from swaps api are always divisible
      ),
      (prev, item) => prev + item.assetQuantity);
}

enum SliderInputError {
  required,
}

class SliderInput extends FormzInput<int, SliderInputError> {
  final SelectionMode selectionMode;

  const SliderInput.pure({this.selectionMode = SelectionMode.slider})
      : super.pure(0);
  const SliderInput.dirty(
      {required int value, this.selectionMode = SelectionMode.slider})
      : super.dirty(value);

  @override
  SliderInputError? validator(int value) {
    if (selectionMode == SelectionMode.slider && value == 0) {
      return SliderInputError.required;
    }
    return null;
  }

  @override
  bool get isValid {
    return selectionMode == SelectionMode.slider ? super.isValid : true;
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
  final AssetQuantity price;
  final AssetQuantity pricePerUnit;

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
  final SelectedAtomicSwapsInput selectedSwapsInput;
  final Set<int> manuallySelectedSwapIndices;

  final FormzSubmissionStatus submissionStatus;

  SwapSliderFormModel({
    required this.assetName,
    required this.atomicSwaps,
    required this.asset,
    required this.sliderInput,
    required this.totalCostInput,
    required this.selectedSwapsInput,
    required this.submissionStatus,
    required this.manuallySelectedSwapIndices,
  });

  @override
  List<FormzInput> get inputs =>
      [sliderInput, totalCostInput, selectedSwapsInput];

  SwapSliderFormModel copyWith({
    String? assetName,
    RemoteData<List<AtomicSwap>>? atomicSwaps,
    RemoteData<Asset>? asset,
    SliderInput? sliderInput,
    TotalCostInput? totalCostInput,
    SelectedAtomicSwapsInput? selectedSwapsInput,
    FormzSubmissionStatus? submissionStatus,
    Set<int>? manuallySelectedSwapIndices,
  }) {
    return SwapSliderFormModel(
      sliderInput: sliderInput ?? this.sliderInput,
      totalCostInput: totalCostInput ?? this.totalCostInput,
      selectedSwapsInput: selectedSwapsInput ?? this.selectedSwapsInput,
      assetName: assetName ?? this.assetName,
      atomicSwaps: atomicSwaps ?? this.atomicSwaps,
      asset: asset ?? this.asset,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      manuallySelectedSwapIndices:
          manuallySelectedSwapIndices ?? this.manuallySelectedSwapIndices,
    );
  }

  String? get errorMessage {
    if (isValid || isPure) return null;

    if (totalCostInput.error == TotalCostValidationError.insufficientBalance) {
      return "Insufficient balance";
    }

    if (selectedSwapsInput.error == SelectedAtomicSwapsValidationError.empty) {
      return "No swaps selected";
    }

    if (sliderInput.error == SliderInputError.required) {
      return "Invalid slider value";
    }

    return "Invalid form";
  }

  RemoteData<AtomicSwapListModel> get atomicSwapListModel {
    return asset.combine(atomicSwaps, (asset, atomicSwaps) {
      final swaps = atomicSwaps.mapWithIndex((swap, idx) {
        final isSelected = sliderInput.selectionMode == SelectionMode.slider
            ? idx + 1 <= sliderInput.value
            : manuallySelectedSwapIndices.contains(idx);
        return AtomicSwapListItemModel(
            selected: isSelected,
            asset: asset,
            quantity: swap.assetQuantity,
            price: swap.price,
            pricePerUnit: swap.pricePerUnit);
      }).toList();

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

class RowClicked extends SwapSliderFormEvent {
  final int index;
  const RowClicked({required this.index});
}

class SubmitClicked extends SwapSliderFormEvent {
  const SubmitClicked();
  @override
  List<Object?> get props => [];
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
              manuallySelectedSwapIndices: {},
              totalCostInput: TotalCostInput.pure(
                  userBalance: AssetQuantity(
                quantity: BigInt.from(bitcoinBalance.quantity),
                divisible: true,
              )),
              selectedSwapsInput: const SelectedAtomicSwapsInput.pure(),
              assetName: assetName,
              atomicSwaps: const Initial<List<AtomicSwap>>(),
              asset: const Initial<Asset>(),
              sliderInput: const SliderInput.pure(),
              submissionStatus: FormzSubmissionStatus.initial),
        ) {
    on<SwapSliderFormInitialized>(_handleInitialized);
    on<SliderDragged>(_handleSliderDragged);
    on<RowClicked>(_handleRowClicked);
    on<SubmitClicked>(_handleSubmitClicked);
    add(SwapSliderFormInitialized());
  }

  _handleRowClicked(
    RowClicked event,
    Emitter<SwapSliderFormModel> emit,
  ) {
    final currentlySelected = state.manuallySelectedSwapIndices;
    final index = event.index;
    final nextSelected = {...currentlySelected};
    if (nextSelected.contains(index)) {
      nextSelected.remove(index);
    } else {
      nextSelected.add(index);
    }

    final selectedSwapsInput = SelectedAtomicSwapsInput.dirty(
        value: state.atomicSwaps.replete(
            onNone: () => [],
            onReplete: (swaps) {
              return swaps
                  .filterWithIndex(
                      (swap, index) => nextSelected.contains(index))
                  .toList();
            }));

    emit(state.copyWith(
        manuallySelectedSwapIndices: nextSelected,
        sliderInput: SliderInput.dirty(
          value: state.sliderInput.value,
          selectionMode: SelectionMode.manual,
        ),
        totalCostInput: TotalCostInput.dirty(
          value: selectedSwapsInput.totalPrice,
          userBalance: state.totalCostInput.userBalance,
        ),
        selectedSwapsInput: selectedSwapsInput));
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
    final selectedSwapsInput = SelectedAtomicSwapsInput.dirty(
        value: state.atomicSwaps.replete(
            onNone: () => [],
            onReplete: (swaps) {
              return swaps
                  .filterWithIndex((swap, index) => index + 1 <= event.value)
                  .toList();
            }));

    emit(state.copyWith(
        manuallySelectedSwapIndices: {},
        sliderInput: SliderInput.dirty(
          value: event.value,
          selectionMode: SelectionMode.slider,
        ),
        totalCostInput: TotalCostInput.dirty(
          value: selectedSwapsInput.totalPrice,
          userBalance: state.totalCostInput.userBalance,
        ),
        selectedSwapsInput: selectedSwapsInput));
  }

  _handleSubmitClicked(
    SubmitClicked event,
    Emitter<SwapSliderFormModel> emit,
  ) {
    if (state.isValid) {
      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.success,
      ));

      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.initial,
      ));
    }
    // shouldn't be possible to click if form is invalid
  }
}
