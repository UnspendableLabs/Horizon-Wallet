abstract class BalancesEvent {}

class Fetch extends BalancesEvent {}

class Start extends BalancesEvent {
  final Duration pollingInterval;
  Start({required this.pollingInterval});
}

class Stop extends BalancesEvent {}

class ToggleStarred extends BalancesEvent {
  final String asset;
  ToggleStarred({required this.asset});
}
