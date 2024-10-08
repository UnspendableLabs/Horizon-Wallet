import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';

abstract class ComposeSendEvent extends ComposeBaseEvent {}

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
  ChangeAsset({required this.asset});
}

class ChangeDestination extends ComposeSendEvent {
  final String value;
  ChangeDestination({required this.value});
}

class ChangeQuantity extends ComposeSendEvent {
  final String value;
  ChangeQuantity({required this.value});
}
