import 'package:horizon/common/constants.dart';

abstract class ImportAddressPkEvent {}

class Finalize extends ImportAddressPkEvent {}

class Reset extends ImportAddressPkEvent {
  final String? pk;
  Reset({this.pk});
}

class Submit extends ImportAddressPkEvent {
  final String pk;
  final String password;
  final ImportAddressPkFormat format;
  Submit({
    required this.pk,
    required this.password,
    required this.format,
  });
}
