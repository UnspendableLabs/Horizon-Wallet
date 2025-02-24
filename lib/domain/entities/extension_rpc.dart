import 'package:horizon/domain/entities/address_rpc.dart';

class RPCGetAddressesSuccessCallbackArgs {
  final int tabId;
  final String requestId;
  final List<AddressRpc> addresses;

  RPCGetAddressesSuccessCallbackArgs(
      {required this.tabId, required this.requestId, required this.addresses});
}

typedef RPCGetAddressesSuccessCallback = void Function(
    RPCGetAddressesSuccessCallbackArgs);

class RPCSignPsbtSuccessCallbackArgs {
  final int tabId;
  final String requestId;
  final String signedPsbt;

  RPCSignPsbtSuccessCallbackArgs(
      {required this.tabId, required this.requestId, required this.signedPsbt});
}

typedef RPCSignPsbtSuccessCallback = void Function(
    RPCSignPsbtSuccessCallbackArgs);

class RPCSignMessageSuccessCallbackArgs {
  final int tabId;
  final String requestId;
  final String signature;
  final String messageHash;
  final String address;

  RPCSignMessageSuccessCallbackArgs(
      {required this.tabId,
      required this.requestId,
      required this.signature,
      required this.messageHash,
      required this.address,
      });
}

typedef RPCSignMessageSuccessCallback = void Function(
    RPCSignMessageSuccessCallbackArgs);
