import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import "package:decimal/decimal.dart";

// form stuff

import "form_event.dart";
import "form_state.dart";

class SendAssetFormBloc extends Bloc<FormEvent, FormModel> {
  SendAssetFormBloc(
      {required MultiAddressBalanceEntry initialAddressBalanceValue})
      : super(FormModel(
          addressBalanceInput:
              AddressBalanceInput.dirty(value: initialAddressBalanceValue),
          destinationInput: const DestinationInput.pure(),
          quantityInput: QuantityInput.pure(
            maxValue:
                Decimal.parse(initialAddressBalanceValue.quantityNormalized),
          ),
          feeOptionInput: FeeOptionInput.pure(),
        )) {
    on<AddressBalanceInputChanged>(_handleAddressBalanceInputChanged);
    on<DestinationInputChanged>(_handleDestinationInputChanged);
    on<QuantityInputChanged>(_handleQuantityInputChanged);
    on<FeeOptionChanged>(_handleFeeOptionChanged);
  }

  _handleAddressBalanceInputChanged(
    AddressBalanceInputChanged event,
    Emitter<FormModel> emit,
  ) {
    final addressBalanceInput = AddressBalanceInput.dirty(value: event.value);

    final maxValue =
        Decimal.parse(addressBalanceInput.value.quantityNormalized);

    final newState = FormModel(
      addressBalanceInput: addressBalanceInput,
      destinationInput: state.destinationInput,
      quantityInput: QuantityInput.dirty(
        value: state.quantityInput.value,
        maxValue: maxValue,
      ),
      feeOptionInput: state.feeOptionInput,
    );

    emit(newState);
  }

  _handleDestinationInputChanged(
    DestinationInputChanged event,
    Emitter<FormModel> emit,
  ) {
    final destinationInput = DestinationInput.dirty(value: event.value);

    final newState = FormModel(
      addressBalanceInput: state.addressBalanceInput,
      destinationInput: destinationInput,
      quantityInput: state.quantityInput,
      feeOptionInput: state.feeOptionInput,
    );

    emit(newState);
  }

  _handleQuantityInputChanged(
    QuantityInputChanged event,
    Emitter<FormModel> emit,
  ) {
    final quantityInput = QuantityInput.dirty(
        value: event.value, maxValue: state.quantityInput.maxValue);
    final newState = FormModel(
      addressBalanceInput: state.addressBalanceInput,
      destinationInput: state.destinationInput,
      quantityInput: quantityInput,
      feeOptionInput: state.feeOptionInput,
    );
    emit(newState);
  }

  _handleFeeOptionChanged(
    FeeOptionChanged event,
    Emitter<FormModel> emit,
  ) {
    final feeOptionInput = FeeOptionInput.dirty(event.value);
    final newState = FormModel(
      addressBalanceInput: state.addressBalanceInput,
      destinationInput: state.destinationInput,
      quantityInput: state.quantityInput,
      feeOptionInput: feeOptionInput,
    );
    emit(newState);
  }
}
