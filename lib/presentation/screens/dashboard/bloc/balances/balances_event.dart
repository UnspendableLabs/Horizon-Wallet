import 'package:horizon/domain/entities/address.dart';

abstract class BalancesEvent {}

class FetchBalances extends BalancesEvent {
  List<Address> addresses;

  FetchBalances({required this.addresses});
}
