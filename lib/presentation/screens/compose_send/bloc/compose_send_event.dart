import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/compose_send.dart';

abstract class ComposeSendEvent {}

class FetchFormData extends ComposeSendEvent {
  Address currentAddress;
  FetchFormData({required this.currentAddress});
}

class FetchBalances extends ComposeSendEvent {
  String address;
  FetchBalances({required this.address});
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

class SignAndBroadcastTransactionEvent extends ComposeSendEvent {
  final ComposeSend composeSend;
  final String password;
  final int fee;

  SignAndBroadcastTransactionEvent({
    required this.composeSend,
    required this.password,
    required this.fee,
  });
}
