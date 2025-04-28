import 'package:equatable/equatable.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/entities/fee_option.dart';

abstract class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object?> get props => [];
}

// TODO: same evnt shuold be shard by all forms.

class FeeOptionChanged extends FormEvent {
  final FeeOption value;
  const FeeOptionChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class FormSubmitted extends FormEvent {
  const FormSubmitted();
}

abstract class TextInputChanged extends FormEvent {
  final String value;

  const TextInputChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class AddressBalanceInputChanged extends FormEvent {
  final MultiAddressBalanceEntry value;
  const AddressBalanceInputChanged(this.value);
}

class DestinationInputChanged extends TextInputChanged {
  const DestinationInputChanged(super.value);
}

class QuantityInputChanged extends TextInputChanged {
  const QuantityInputChanged(super.value);
}
