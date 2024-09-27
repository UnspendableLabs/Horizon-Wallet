import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/fee_option.dart';

abstract class ComposeBaseEvent {}

class FetchFormData extends ComposeBaseEvent {
  Address currentAddress;
  FetchFormData({required this.currentAddress});
}

class ChangeFeeOption extends ComposeBaseEvent {
  final FeeOption value;
  ChangeFeeOption({required this.value});
}

class FinalizeTransactionEvent<T> extends ComposeBaseEvent {
  final T composeTransaction;
  final int fee;

  FinalizeTransactionEvent({
    required this.composeTransaction,
    required this.fee,
  });
}

class SignAndBroadcastTransactionEvent extends ComposeBaseEvent {
  final String password;

  SignAndBroadcastTransactionEvent({
    required this.password,
  });
}
