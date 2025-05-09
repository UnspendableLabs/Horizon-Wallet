enum CallerType { app, extension }

abstract class Action {
  String get action;
  CallerType get caller;
}

class DispenseAction extends Action {
  @override
  String get action => 'dispense';
  @override
  final CallerType caller;

  final String address;

  DispenseAction(this.address, this.caller);
}

class FairmintAction extends Action {
  @override
  String get action => 'fairmint';
  @override
  final CallerType caller;
  final String fairminterTxHash;
  final int? numLots;
  FairmintAction(this.fairminterTxHash, this.caller, {this.numLots});
}

class OpenOrderAction extends Action {
  @override
  String get action => 'open-order';

  @override
  final CallerType caller;
  final int giveQuantity;
  final String giveAsset;
  final int getQuantity;
  final String getAsset;

  OpenOrderAction(
      {required this.caller,
      required this.giveQuantity,
      required this.giveAsset,
      required this.getQuantity,
      required this.getAsset});
}

abstract class RPCAction extends Action {
  final int tabId;
  final String requestId;
  RPCAction(this.tabId, this.requestId);
}

class RPCGetAddressesAction extends RPCAction {
  @override
  String get action => 'getAddresses';
  @override
  CallerType get caller => CallerType.extension;
  RPCGetAddressesAction(super.tabId, super.requestId);
}

class RPCSignPsbtAction extends RPCAction {
  @override
  String get action => 'signPsbt';
  @override
  CallerType get caller => CallerType.extension;
  final String psbt;
  final Map<String, List<int>> signInputs;
  final List<int>? sighashTypes;
  RPCSignPsbtAction(super.tabId, super.requestId, this.psbt, this.signInputs,
      this.sighashTypes);
}

class RPCSignMessageAction extends RPCAction {
  @override
  String get action => 'signMessage';
  @override
  CallerType get caller => CallerType.extension;
  final String message;
  final String address;
  RPCSignMessageAction(
      super.tabId, super.requestId, this.message, this.address);
}
