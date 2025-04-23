import 'package:equatable/equatable.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';

abstract class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object?> get props => [];
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
