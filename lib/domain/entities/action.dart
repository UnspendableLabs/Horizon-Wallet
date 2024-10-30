abstract class Action {
  String get action;
}

class DispenseAction extends Action {
  @override
  String get action => 'dispense';
  final String address;
  DispenseAction(this.address);
}

class FairmintAction extends Action {
  @override
  String get action => 'fairmint';
  final String fairminterTxHash;
  FairmintAction(this.fairminterTxHash);
}

class OpenOrderAction extends Action {
  @override
  String get action => 'open-order';
  final int giveQuantity;
  final String giveAsset;
  final int getQuantity;
  final String getAsset;

  OpenOrderAction(
      {required this.giveQuantity,
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
  RPCGetAddressesAction(super.tabId, super.requestId);
}

class RPCSignPsbtAction extends RPCAction {
  @override
  String get action => 'signPsbt';
  final String psbt;
  RPCSignPsbtAction(super.tabId, super.requestId, this.psbt);
}
