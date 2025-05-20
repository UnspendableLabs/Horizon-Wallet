import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';

abstract class AssetPairFormEvent extends Equatable {
  const AssetPairFormEvent();

  @override
  List<Object?> get props => [];
}

class GiveAssetChanged extends AssetPairFormEvent {
  final MultiAddressBalance value;
  const GiveAssetChanged({required this.value});
}

class AssetPairFormModel with FormzMixin {
  final List<MultiAddressBalance> giveAssets;

  final GiveAssetInput giveAssetInput;

  AssetPairFormModel({
    required this.giveAssets,
    required this.giveAssetInput,
  });

  @override
  List<FormzInput> get inputs => [giveAssetInput];

  AssetPairFormModel copyWith({
    List<MultiAddressBalance>? giveAssets,
    GiveAssetInput? giveAssetInput,
  }) {
    return AssetPairFormModel(
      giveAssets: giveAssets ?? this.giveAssets,
      giveAssetInput: giveAssetInput ?? this.giveAssetInput,
    );
  }
}

class GiveAssetInput extends FormzInput<MultiAddressBalance?, void> {
  const GiveAssetInput.dirty({required MultiAddressBalance? value})
      : super.dirty(value);

  @override
  void validator(MultiAddressBalance? value) {
    if (value == null) {
      throw Exception("give asset input is null");
    }
  }
}

class AssetPairFormBloc extends Bloc<AssetPairFormEvent, AssetPairFormModel> {
  AssetPairFormBloc(
      {required List<MultiAddressBalance> initialGiveAssets,
      required MultiAddressBalance? initialMultiAddressBalanceEntry})
      : super(
          AssetPairFormModel(
              giveAssets: initialGiveAssets,
              giveAssetInput:
                  GiveAssetInput.dirty(value: initialMultiAddressBalanceEntry)),
        ) {
    on<GiveAssetChanged>(_handleGiveAssetChanged);
  }

  _handleGiveAssetChanged(
      GiveAssetChanged event, Emitter<AssetPairFormModel> emit) {
    emit(state.copyWith(
      giveAssetInput: GiveAssetInput.dirty(value: event.value),
    ));
  }
}
