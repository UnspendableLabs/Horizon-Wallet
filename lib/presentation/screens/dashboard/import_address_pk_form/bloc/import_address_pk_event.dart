import 'package:horizon/common/constants.dart';

abstract class ImportAddressPkEvent {}

class Finalize extends ImportAddressPkEvent {}

class ResetForm extends ImportAddressPkEvent {
  final String? pk;
  ResetForm({this.pk});
}

class Submit extends ImportAddressPkEvent {
  final String pk;
  final String password;
  final ImportAddressPkFormat format;
  final String name;
  Submit({
    required this.pk,
    required this.password,
    required this.format,
    required this.name,
  });
}
