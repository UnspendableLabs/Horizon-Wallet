import 'package:horizon/domain/entities/psbt_type.dart';

abstract class Action {
  String get action;
}

abstract class RPCAction extends Action {
  final int tabId;
  final String requestId;
  final String? origin;
  final String? title;
  final String? favicon;
  RPCAction(this.tabId, this.requestId, this.origin, this.title, this.favicon);
}

class RPCGetAddressesAction extends RPCAction {
  @override
  String get action => 'getAddresses';
  @override
  RPCGetAddressesAction(
      super.tabId, super.requestId, super.origin, super.title, super.favicon);
}

class RPCSignPsbtAction extends RPCAction {
  @override
  String get action => 'signPsbt';
  final String psbt;
  final Map<String, List<int>> signInputs;
  final List<int>? sighashTypes;
  final PsbtType psbtType;
  RPCSignPsbtAction(
      super.tabId,
      super.requestId,
      super.origin,
      super.title,
      super.favicon,
      this.psbt,
      this.signInputs,
      this.sighashTypes,
      this.psbtType);
}

class RPCSignMessageAction extends RPCAction {
  @override
  String get action => 'signMessage';
  final String message;
  final String address;
  RPCSignMessageAction(super.tabId, super.requestId, super.origin, super.title,
      super.favicon, this.message, this.address);
}

class RPCSignMessageBLSAction extends RPCAction {
  @override
  String get action => 'signMessageBLS';
  final String message;
  final String? dst;
  RPCSignMessageBLSAction(super.tabId, super.requestId, super.origin,
      super.title, super.favicon, this.message, this.dst);
}

class RPCGetBLSPoPAction extends RPCAction {
  @override
  String get action => 'getBLSPoP';
  final String address;
  RPCGetBLSPoPAction(super.tabId, super.requestId, super.origin,
      super.title, super.favicon, this.address);
}
