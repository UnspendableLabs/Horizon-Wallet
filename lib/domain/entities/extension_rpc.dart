import 'package:horizon/domain/entities/address.dart';

class RPCGetAddressesSuccessCallbackArgs {
  final int tabId;
  final String requestId;
  final List<Address> addresses;

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
