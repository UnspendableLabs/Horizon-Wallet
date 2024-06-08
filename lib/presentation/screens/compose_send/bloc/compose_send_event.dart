import 'package:horizon/domain/entities/address.dart';

abstract class ComposeSendEvent {}

class SendTransactionEvent extends ComposeSendEvent {
  final Address sourceAddress;
  final String destinationAddress;
  final double quantity;
  final String asset;
  final String network;
  final String? memo;
  final bool? memoIsHex;
  SendTransactionEvent(
      {required this.sourceAddress,
      required this.destinationAddress,
      required this.quantity,
      required this.asset,
      this.memo,
      this.memoIsHex,
      required this.network});
}

class SignTransactionEvent extends ComposeSendEvent {
  final String unsignedTransactionHex;
  final Address sourceAddress;
  final String network;
  SignTransactionEvent({required this.unsignedTransactionHex, required this.sourceAddress, required this.network});
}
