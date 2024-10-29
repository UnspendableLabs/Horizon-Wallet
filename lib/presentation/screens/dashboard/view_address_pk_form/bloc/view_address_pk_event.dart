abstract class ViewAddressPkFormEvent {}

class ViewAddressPk extends ViewAddressPkFormEvent {
  final String password;
  final String address;
  ViewAddressPk({required this.password, required this.address});
}
