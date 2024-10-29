abstract class ViewAddressPkFormEvent {
  const ViewAddressPkFormEvent();
}

class ViewAddressPk extends ViewAddressPkFormEvent {
  final String password;
  final String address;

  const ViewAddressPk({required this.password, required this.address})
      : super();
}
