abstract class Action {
  String get action;
}

class DispenseAction extends Action {
  @override
  String get action => 'dispense';
  final String address;
  DispenseAction(this.address);
}
