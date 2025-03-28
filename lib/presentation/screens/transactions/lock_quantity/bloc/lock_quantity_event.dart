import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';

class LockQuantityDependenciesRequested extends DependenciesRequested {
  LockQuantityDependenciesRequested({
    required super.assetName,
    required super.addresses,
  });
}

class LockQuantityTransactionComposed
    extends TransactionComposed<ComposeIssuanceParams> {
  LockQuantityTransactionComposed({
    required super.sourceAddress,
    required super.params,
  });
}

class LockQuantityTransactionBroadcasted extends TransactionEvent {
  final String? password;

  LockQuantityTransactionBroadcasted({this.password});
}
