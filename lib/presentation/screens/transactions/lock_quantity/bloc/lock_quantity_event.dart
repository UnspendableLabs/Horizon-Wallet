import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';

class LockQuantityDependenciesRequested extends DependenciesRequested {
  LockQuantityDependenciesRequested({
    required super.assetName,
    required super.addresses,
  });
}

class LockQuantityTransactionComposed
    extends TransactionComposed<LockQuantityTransactionParams> {
  LockQuantityTransactionComposed({
    required super.sourceAddress,
    required super.params,
  });
}

class LockQuantityTransactionParams {}

class LockQuantityTransactionBroadcasted extends TransactionEvent {
  final String? password;

  LockQuantityTransactionBroadcasted({this.password});
}
