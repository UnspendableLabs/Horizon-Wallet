import 'package:horizon/domain/entities/address.dart';

abstract class ComposeIssuanceEvent {}

class CreateIssuanceEvent extends ComposeIssuanceEvent {
  final Address sourceAddress;
  final String name;
  final double quantity;

  CreateIssuanceEvent({required this.sourceAddress, required this.name, required this.quantity});
}
