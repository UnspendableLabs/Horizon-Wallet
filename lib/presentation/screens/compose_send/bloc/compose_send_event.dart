import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/presentation/screens/compose_base/bloc/compose_base_event.dart';

abstract class ComposeSendEvent extends ComposeBaseEvent {}

class ComposeTransactionEvent extends ComposeSendEvent {
  final String sourceAddress;
  final String destinationAddress;
  final int quantity;
  final String asset;

  ComposeTransactionEvent({
    required this.sourceAddress,
    required this.destinationAddress,
    required this.quantity,
    required this.asset,
  });
}

// class ComputeMaxQuantityEvent extends ComposeSendEvent {
//   final String? asset;
//   final int? feeRate;
//   // final Balance? balance;
//   final String sourceAddress;
//   // final String? destinationAddress;
//   ComputeMaxQuantityEvent({
//     required this.asset,
//     required this.feeRate,
//     // required this.balance,
//     required this.sourceAddress,
//     // required this.destinationAddress,
//   });
// }

class ToggleSendMaxEvent extends ComposeSendEvent {
  final bool value;

  ToggleSendMaxEvent({required this.value});
}

// TODO: smell
class ChangeAsset extends ComposeSendEvent {
  final String asset;
  final Balance balance;
  ChangeAsset({required this.asset, required this.balance});
}

class ChangeDestination extends ComposeSendEvent {
  final String value;
  ChangeDestination({required this.value});
}

class ChangeQuantity extends ComposeSendEvent {
  final String value;
  ChangeQuantity({required this.value});
}
