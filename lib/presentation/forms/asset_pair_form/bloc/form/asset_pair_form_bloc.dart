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
  final GiveAssetInput giveAssetInput;

  AssetPairFormModel({
    required this.giveAssetInput,
  });

  @override
  List<FormzInput> get inputs => [giveAssetInput];

  AssetPairFormModel copyWith({
    GiveAssetInput? giveAssetInput,
  }) {
    return AssetPairFormModel(
      giveAssetInput: giveAssetInput ?? this.giveAssetInput,
    );
  }
}

class GiveAssetInput extends FormzInput<MultiAddressBalance, void> {
  const GiveAssetInput.dirty({required MultiAddressBalance value})
      : super.dirty(value);

  @override
  void validator(MultiAddressBalance value) {}
}

class AssetPairFormBloc extends Bloc<AssetPairFormEvent, AssetPairFormModel> {
  AssetPairFormBloc(
      {required MultiAddressBalance initialMultiAddressBalanceEntry})
      : super(
          AssetPairFormModel(
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
