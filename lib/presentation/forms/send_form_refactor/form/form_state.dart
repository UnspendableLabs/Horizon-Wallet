import 'package:formz/formz.dart';
import "package:decimal/decimal.dart";
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';

import 'package:horizon/domain/entities/fee_option.dart';
// TODO: refine FeeOptionError

enum FeeOptionError { invalid }

class FeeOptionInput extends FormzInput<FeeOption, FeeOptionError> {
  FeeOptionInput.pure() : super.pure(Medium());
  const FeeOptionInput.dirty(FeeOption value) : super.dirty(value);
  @override
  FeeOptionError? validator(FeeOption value) {
    return switch (value) {
      Custom(fee: var value) => value < 0 ? FeeOptionError.invalid : null,
      _ => null
    };
  }
}

class TransactionFormModelBase with FormzMixin {
  final FeeOptionInput feeOptionInput;

  TransactionFormModelBase({required this.feeOptionInput});

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

class FormModel extends TransactionFormModelBase {
  final AddressBalanceInput addressBalanceInput;
  final DestinationInput destinationInput;
  final QuantityInput quantityInput;

  FormModel(
      {required this.addressBalanceInput,
      required this.destinationInput,
      required this.quantityInput,
      required super.feeOptionInput});
  @override
  List<FormzInput> get inputs =>
      [addressBalanceInput, destinationInput, quantityInput, ...super.inputs];
}
