import 'package:horizon/domain/entities/address.dart';

abstract class ComposeIssuanceEvent {}

class CreateIssuanceEvent extends ComposeIssuanceEvent {
  final Address sourceAddress;
  final String name;
  final double quantity;
  final bool? divisible;
  final bool? lock;
  final bool? reset;
  final String? description;
  final String? transferDestination;

  CreateIssuanceEvent(
      {required this.sourceAddress,
      required this.name,
      required this.quantity,
      this.divisible,
      this.lock,
      this.reset,
      this.description,
      this.transferDestination});
}
