import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fee_option.dart';

abstract class ComposeSendEvent {}

class FetchFormData extends ComposeSendEvent {
  Address currentAddress;
  FetchFormData({required this.currentAddress});
}

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

class FinalizeTransactionEvent extends ComposeSendEvent {
  final ComposeSend composeSend;
  final int fee;

  FinalizeTransactionEvent({
    required this.composeSend,
    required this.fee,
  });
}

class SignAndBroadcastTransactionEvent extends ComposeSendEvent {
  final String password;

  SignAndBroadcastTransactionEvent({
    required this.password,
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

class ChangeFeeOption extends ComposeSendEvent {
  final FeeOption value;
  ChangeFeeOption({required this.value});
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
