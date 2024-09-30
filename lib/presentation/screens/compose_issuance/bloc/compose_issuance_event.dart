import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';

abstract class ComposeIssuanceEvent extends ComposeBaseEvent {}

class FetchBalances extends ComposeIssuanceEvent {
  String address;
  FetchBalances({required this.address});
}

class ComposeIssuanceEventParams {
  final String name;
  final int quantity;
  final String description;
  final bool divisible;
  final bool lock;
  final bool reset;

  ComposeIssuanceEventParams({
    required this.name,
    required this.quantity,
    required this.description,
    required this.divisible,
    required this.lock,
    required this.reset,
  });
}
