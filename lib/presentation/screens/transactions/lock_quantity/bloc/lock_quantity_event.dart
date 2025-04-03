import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';

class LockQuantityDependenciesRequested extends DependenciesRequested {
  final String assetName;
  final List<String> addresses;
  LockQuantityDependenciesRequested({
    required this.assetName,
    required this.addresses,
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
  final dynamic decryptionStrategy;

  LockQuantityTransactionBroadcasted({required this.decryptionStrategy});
}
