import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';

abstract class ComposeIssuanceEvent {}

class FetchFormData extends ComposeIssuanceEvent {
  Address currentAddress;
  FetchFormData({required this.currentAddress});
}

class FetchBalances extends ComposeIssuanceEvent {
  String address;
  FetchBalances({required this.address});
}

class ComposeTransactionEvent extends ComposeIssuanceEvent {
  final String sourceAddress;
  final String name;
  final int quantity;
  final String description;
  final bool divisible;
  final bool lock;
  final bool reset;

  ComposeTransactionEvent({
    required this.sourceAddress,
    required this.name,
    required this.quantity,
    required this.description,
    required this.divisible,
    required this.lock,
    required this.reset,
  });
}

class SignAndBroadcastTransactionEvent extends ComposeIssuanceEvent {
  final ComposeIssuanceVerbose composeIssuance;
  final String password;
  final int fee;

  SignAndBroadcastTransactionEvent({
    required this.composeIssuance,
    required this.password,
    required this.fee,
  });
}
