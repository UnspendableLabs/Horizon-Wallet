import 'package:horizon/domain/entities/address.dart';

abstract class ComposeIssuanceEvent {}

class FetchFormData extends ComposeIssuanceEvent {
  String accountUuid;
  FetchFormData({required this.accountUuid});
}

class FetchBalances extends ComposeIssuanceEvent {
  String address;
  FetchBalances({required this.address});
}

class CreateIssuanceEvent extends ComposeIssuanceEvent {
  final String sourceAddress;
  final String password;
  final String name;
  final double quantity;
  final bool? divisible;
  final bool? lock;
  final bool? reset;
  final String? description;
  final String? transferDestination;

  CreateIssuanceEvent(
      {required this.sourceAddress,
      required this.password,
      required this.name,
      required this.quantity,
      this.divisible,
      this.lock,
      this.reset,
      this.description,
      this.transferDestination});
}
