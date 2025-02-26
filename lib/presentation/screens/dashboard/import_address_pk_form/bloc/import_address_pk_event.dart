import 'package:horizon/common/constants.dart';

abstract class ImportAddressPkEvent {}

class Submit extends ImportAddressPkEvent {
  final String wif;
  final String password;
  final ImportAddressPkFormat format;
  final String name;
  Submit({
    required this.wif,
    required this.password,
    required this.format,
    required this.name,
  });
}
