
import 'package:horizon/domain/entities/address.dart';

abstract class BalancesEvent {}

class Fetch extends BalancesEvent {
  List<Address> addresses;

  Fetch({required this.addresses});
}
