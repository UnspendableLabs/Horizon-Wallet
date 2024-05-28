import 'package:horizon/domain/entities/address.dart';

abstract class DashboardEvent {}

class SetAccountAndWallet extends DashboardEvent {}

class GetAddresses extends DashboardEvent {}

class ChangeAddress extends DashboardEvent {
  final Address address;
  ChangeAddress({required this.address});
}
