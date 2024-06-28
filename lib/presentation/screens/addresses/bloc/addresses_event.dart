
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/account.dart';
abstract class AddressesEvent {}

class Generate extends AddressesEvent {
  final String accountUuid;
  final int gapLimit;
  Generate({required this.accountUuid, required this.gapLimit});
}



