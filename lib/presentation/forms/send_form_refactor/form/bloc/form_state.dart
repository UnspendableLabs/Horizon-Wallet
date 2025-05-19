import 'package:formz/formz.dart';
import "package:decimal/decimal.dart";
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';

import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
// TODO: refine FeeOptionError

enum FeeOptionError { invalid }

class FeeOptionInput extends FormzInput<FeeOption, FeeOptionError> {
  FeeOptionInput.pure() : super.pure(Medium());
  const FeeOptionInput.dirty(super.value) : super.dirty();
  @override
  FeeOptionError? validator(FeeOption value) {
    return switch (value) {
      Custom(fee: var value) => value < 0 ? FeeOptionError.invalid : null,
      _ => null
    };
  }
}

class TransactionFormModelBase<TComposeResponse> with FormzMixin {
  final FeeEstimates feeEstimates;
  final FeeOptionInput feeOptionInput;
  final FormzSubmissionStatus status;
  final TComposeResponse? composeResponse;
  final String? error;

  TransactionFormModelBase({
    required this.feeEstimates,
    required this.feeOptionInput,
    required this.status,
    this.composeResponse,
    this.error,
  });

  @override
  List<FormzInput> get inputs => [feeOptionInput];
}

class AddressBalanceInput extends FormzInput<MultiAddressBalanceEntry, void> {
  const AddressBalanceInput.dirty({required MultiAddressBalanceEntry value})
      : super.dirty(value);

  @override
  void validator(MultiAddressBalanceEntry value) {}
}

enum DestinationInputError { required, invaild }

class DestinationInput extends FormzInput<String, DestinationInputError> {
  const DestinationInput.pure() : super.pure('');

  const DestinationInput.dirty({String value = ''}) : super.dirty(value);

  @override
  DestinationInputError? validator(String value) {
    // if (value.isEmpty) {
    //   return DestinationInputError.required;
    // }
    // TODO: refine
    return null;
  }
}

enum QuantityInputError { required, exceedsMax, invalid }

class QuantityInput extends FormzInput<String, QuantityInputError> {
  // TODO: maybe this shouldn't be double
  final Decimal maxValue;

  const QuantityInput.pure({required this.maxValue}) : super.pure("");
  const QuantityInput.dirty({String value = '', required this.maxValue})
      : super.dirty(value);

  @override
  QuantityInputError? validator(String value) {
    if (value.isEmpty) {
      return QuantityInputError.required;
    }

    final d = Decimal.tryParse(value);

    if (d == null) {
      return QuantityInputError.invalid;
    }

    if (d > maxValue) {
      return QuantityInputError.exceedsMax;
    }

    // TODO: refine
    return null;
  }
}

class FormModel extends TransactionFormModelBase<ComposeSendResponse> {
  final AddressBalanceInput addressBalanceInput;
  final DestinationInput destinationInput;
  final QuantityInput quantityInput;

  FormModel(
      {required this.addressBalanceInput,
      required this.destinationInput,
      required this.quantityInput,
      required super.feeOptionInput,
      required super.feeEstimates,
      super.composeResponse,
      super.error,
      super.status = FormzSubmissionStatus.initial});
  @override
  List<FormzInput> get inputs =>
      [addressBalanceInput, destinationInput, quantityInput, ...super.inputs];

  FormModel copyWith({
    AddressBalanceInput? addressBalanceInput,
    DestinationInput? destinationInput,
    QuantityInput? quantityInput,
    FeeOptionInput? feeOptionInput,
    FeeEstimates? feeEstimates,
    FormzSubmissionStatus? status,
    ComposeSendResponse? composeResponse,
    String? error,
  }) {
    return FormModel(
      error: error ?? this.error,
      composeResponse: composeResponse,
      addressBalanceInput: addressBalanceInput ?? this.addressBalanceInput,
      destinationInput: destinationInput ?? this.destinationInput,
      quantityInput: quantityInput ?? this.quantityInput,
      feeOptionInput: feeOptionInput ?? this.feeOptionInput,
      feeEstimates: feeEstimates ?? this.feeEstimates,
      status: status ?? this.status,
    );
  }
}
