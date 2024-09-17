import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/compose_send.dart';

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
