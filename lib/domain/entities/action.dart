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
