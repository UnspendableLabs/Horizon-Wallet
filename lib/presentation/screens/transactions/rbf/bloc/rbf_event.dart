import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';

class RBFDependenciesRequested extends DependenciesRequested {
  final String txHash;
  final String address;
  RBFDependenciesRequested({
    required this.txHash,
    required this.address,
  });
}

class RBFTransactionComposed extends TransactionComposed<MakeRBFResponse> {
  RBFTransactionComposed({
    required super.sourceAddress,
    required super.params,
  });
}

// class SendTransactionParams {
//   final String destinationAddress;
//   final String asset;
//   final int quantity;

//   SendTransactionParams({
//     required this.destinationAddress,
//     required this.asset,
//     required this.quantity,
//   });
// }

class RBFTransactionBroadcasted extends TransactionEvent {
  final String? password;

  RBFTransactionBroadcasted({this.password});
}
