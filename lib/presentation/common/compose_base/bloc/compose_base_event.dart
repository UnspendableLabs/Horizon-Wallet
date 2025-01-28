import 'package:horizon/domain/entities/fee_option.dart';

abstract class ComposeBaseEvent {}

class AsyncFormDependenciesRequested extends ComposeBaseEvent {
  String? currentAddress;
  String? assetName;
  String?
      initialDispenserAddress; // this is a total hack but necessary due to current base bloc implementation
  AsyncFormDependenciesRequested({
    this.currentAddress,
    this.assetName,
    this.initialDispenserAddress,
  });
}

class FeeOptionChanged extends ComposeBaseEvent {
  final FeeOption value;
  FeeOptionChanged({required this.value});
}

class FormSubmitted<T> extends ComposeBaseEvent {
  final String sourceAddress;
  final T params;

  FormSubmitted({
    required this.sourceAddress,
    required this.params,
  });
}

class ReviewSubmitted<T> extends ComposeBaseEvent {
  final T composeTransaction;
  final int fee;

  ReviewSubmitted({
    required this.composeTransaction,
    required this.fee,
  });
}

class SignAndBroadcastFormSubmitted extends ComposeBaseEvent {
  final String password;

  SignAndBroadcastFormSubmitted({
    required this.password,
  });
}

// class PasswordlessTransactionConfirmed extends ComposeBaseEvent {
//   PasswordlessTransactionConfirmed();
// }
