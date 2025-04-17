import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';

class RBFDependenciesRequested extends DependenciesRequested {
  final String txHash;
  final String address;
  RBFDependenciesRequested({
    required this.txHash,
    required this.address,
  });
}

class RBFTransactionComposed extends TransactionComposed<RBFTransactionParams> {
  RBFTransactionComposed({
    required super.sourceAddress,
    required super.params,
  });
}

class RBFTransactionParams {
  final BitcoinTx tx;
  final String hex;
  final int adjustedVirtualSize;

  RBFTransactionParams({
    required this.tx,
    required this.hex,
    required this.adjustedVirtualSize,
  });
}

class RBFTransactionBroadcasted extends TransactionBroadcasted {
  RBFTransactionBroadcasted({required super.decryptionStrategy});
}
