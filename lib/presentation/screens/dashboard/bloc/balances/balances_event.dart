import "./balances_state.dart";

abstract class BalancesEvent {}

class Fetch extends BalancesEvent {
  final String accountUuid;
  Fetch({required this.accountUuid});
}

class Start extends BalancesEvent {
  final Duration pollingInterval;
  Start({required this.pollingInterval});
}

class Stop extends BalancesEvent {}
