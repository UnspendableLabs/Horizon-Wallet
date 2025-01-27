import 'package:horizon/domain/entities/fee_option.dart';

abstract class ComposeBaseEvent {}

class FetchFormData extends ComposeBaseEvent {
  String? currentAddress;
  String? assetName;
  String?
      initialDispenserAddress; // this is a total hack but necessary due to current base bloc implementation
  FetchFormData({
    this.currentAddress,
    this.assetName,
    this.initialDispenserAddress,
  });
}

class ChangeFeeOption extends ComposeBaseEvent {
  final FeeOption value;
  ChangeFeeOption({required this.value});
}

class ComposeTransactionEvent<T> extends ComposeBaseEvent {
  final String sourceAddress;
  final T params;

  ComposeTransactionEvent({
    required this.sourceAddress,
    required this.params,
  });
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

// class PasswordlessTransactionConfirmed extends ComposeBaseEvent {
//   PasswordlessTransactionConfirmed();
// }
