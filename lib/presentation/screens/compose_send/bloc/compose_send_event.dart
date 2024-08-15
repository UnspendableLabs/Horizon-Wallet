import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/compose_send.dart';

abstract class ComposeSendEvent {}

class FetchFormData extends ComposeSendEvent {
  String accountUuid;
  FetchFormData({required this.accountUuid});
}

class FetchBalances extends ComposeSendEvent {
  String address;
  FetchBalances({required this.address});
}

class ConfirmTransactionEvent extends ComposeSendEvent {
  final String sourceAddress;
  final String destinationAddress;
  final int quantity;
  final String quantityDisplay;
  final String asset;
  // final String password;
  final String? memo;
  final bool? memoIsHex;
  ConfirmTransactionEvent({
    required this.sourceAddress,
    required this.destinationAddress,
    required this.quantity,
    required this.quantityDisplay,
    required this.asset,
    // required this.password,
    this.memo,
    this.memoIsHex,
  });
}

class SendTransactionEvent extends ComposeSendEvent {
  final ComposeSend composeSend;
  final String password;

  SendTransactionEvent({
    required this.composeSend,
    required this.password,

  });
}

class SignTransactionEvent extends ComposeSendEvent {
  final String unsignedTransactionHex;
  final Address sourceAddress;
  final String network;
  SignTransactionEvent({required this.unsignedTransactionHex, required this.sourceAddress, required this.network});
}
