import 'package:horizon/domain/entities/address.dart';

class AccountServiceReturn {
  final String xPub;
  final Address address;

  AccountServiceReturn({required this.xPub, required this.address});
}
