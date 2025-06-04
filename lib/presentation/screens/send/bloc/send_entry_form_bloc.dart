import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';

abstract class SendEntryFormEvent {
  const SendEntryFormEvent();
}

class AddressBalanceInputChanged extends SendEntryFormEvent {
  final MultiAddressBalance value;
  const AddressBalanceInputChanged(this.value);
}

class DestinationInputChanged extends SendEntryFormEvent {
  final String value;
  const DestinationInputChanged(this.value);
}

class QuantityInputChanged extends SendEntryFormEvent {
  final String value;
  const QuantityInputChanged(this.value);
}

class MemoInputChanged extends SendEntryFormEvent {
  final String value;
  const MemoInputChanged(this.value);
}

class MaxAmountSelected extends SendEntryFormEvent {
  final MultiAddressBalance value;
  const MaxAmountSelected(this.value);
}

class SendEntryFormBloc extends Bloc<SendEntryFormEvent, SendEntryFormModel> {
  SendEntryFormBloc(
      {MultiAddressBalance? initialBalance,
      required String initialQuantity,
      required String initialDestination,
      required String initialMemo})
      : super(SendEntryFormModel(
          balanceSelectorInput:
              initialBalance != null
                  ? BalanceSelectorInput.dirty(value: initialBalance)
                  : const BalanceSelectorInput.pure(),
          destinationInput: DestinationInput.dirty(value: initialDestination),
          quantityInput: QuantityInput.dirty(value: initialQuantity),
          memoInput: MemoInput.dirty(value: initialMemo),
        )) {
    on<AddressBalanceInputChanged>(_onAddressBalanceInputChanged);
    on<DestinationInputChanged>(_onDestinationInputChanged);
    on<QuantityInputChanged>(_onQuantityInputChanged);
    on<MemoInputChanged>(_onMemoInputChanged);
  }

  _onAddressBalanceInputChanged(
      AddressBalanceInputChanged event, Emitter<SendEntryFormModel> emit) {
    emit(state.copyWith(
        balanceSelectorInput: BalanceSelectorInput.dirty(value: event.value)));
  }

  _onDestinationInputChanged(
      DestinationInputChanged event, Emitter<SendEntryFormModel> emit) {
    emit(state.copyWith(
        destinationInput: DestinationInput.dirty(value: event.value)));
  }

  _onQuantityInputChanged(
      QuantityInputChanged event, Emitter<SendEntryFormModel> emit) {
    emit(
        state.copyWith(quantityInput: QuantityInput.dirty(value: event.value)));
  }

  _onMemoInputChanged(
      MemoInputChanged event, Emitter<SendEntryFormModel> emit) {
    emit(state.copyWith(memoInput: MemoInput.dirty(value: event.value)));
  }
}

enum SendEntryFormInputError {
  destinationRequired,
  quantityRequired,
  balanceRequired,
  invalidQuantity,
}

class DestinationInput extends FormzInput<String, SendEntryFormInputError> {
  const DestinationInput.pure() : super.pure("");
  const DestinationInput.dirty({required String value}) : super.dirty(value);

  @override
  SendEntryFormInputError? validator(String? value) {
    if (value == null || value.isEmpty) {
      return SendEntryFormInputError.destinationRequired;
    }
    // TODO: check is valid address
    return null;
  }
}

class QuantityInput extends FormzInput<String, SendEntryFormInputError> {
  const QuantityInput.pure() : super.pure("");
  const QuantityInput.dirty({required String value}) : super.dirty(value);

  @override
  SendEntryFormInputError? validator(String? value) {
    if (value == null || value.isEmpty) {
      return SendEntryFormInputError.quantityRequired;
    }

    if (double.tryParse(value) == null) {
      return SendEntryFormInputError.invalidQuantity;
    }

    return null;
  }
}

class BalanceSelectorInput
    extends FormzInput<MultiAddressBalance?, SendEntryFormInputError> {
  const BalanceSelectorInput.dirty({required MultiAddressBalance value})
      : super.dirty(value);

  const BalanceSelectorInput.pure() : super.pure(null);

  @override
  SendEntryFormInputError? validator(MultiAddressBalance? value) {
    if (value == null) {
      return SendEntryFormInputError.balanceRequired;
    }
    return null;
  }
}

class MemoInput extends FormzInput<String, SendEntryFormInputError> {
  const MemoInput.pure() : super.pure("");
  const MemoInput.dirty({required String value}) : super.dirty(value);

  @override
  SendEntryFormInputError? validator(String? value) {
    return null;
  }
}

class SendEntryFormModel with FormzMixin {
  final DestinationInput destinationInput;
  final QuantityInput quantityInput;
  final BalanceSelectorInput balanceSelectorInput;
  final MemoInput memoInput;

  SendEntryFormModel(
      {required this.destinationInput,
      required this.quantityInput,
      required this.balanceSelectorInput,
      required this.memoInput});

  @override
  List<FormzInput> get inputs =>
      [destinationInput, quantityInput, balanceSelectorInput, memoInput];

  SendEntryFormModel copyWith({
    DestinationInput? destinationInput,
    QuantityInput? quantityInput,
    BalanceSelectorInput? balanceSelectorInput,
    MemoInput? memoInput,
  }) {
    return SendEntryFormModel(
      destinationInput: destinationInput ?? this.destinationInput,
      quantityInput: quantityInput ?? this.quantityInput,
      balanceSelectorInput: balanceSelectorInput ?? this.balanceSelectorInput,
      memoInput: memoInput ?? this.memoInput,
    );
  }

  get assetIsDivisible =>
      balanceSelectorInput.value?.assetInfo.divisible ?? false;

  get assetQuantityNormalized =>
      balanceSelectorInput.value?.totalNormalized ?? "";

  @override
  String toString() {
    return "SendEntryFormModel(destinationInput: $destinationInput, quantityInput: $quantityInput, balanceSelectorInput: $balanceSelectorInput, memoInput: $memoInput)";
  }
}
