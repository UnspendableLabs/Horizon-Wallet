abstract class BalancesEvent {}

class FetchBalances extends BalancesEvent {
  final String accountUuid;

  FetchBalances({required this.accountUuid});
}
