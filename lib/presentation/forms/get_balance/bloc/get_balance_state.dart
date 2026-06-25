enum GetBalanceStatus { loading, success, failure }

class GetBalanceState {
  final GetBalanceStatus status;

  // Balances are in satoshis.
  final int confirmed;
  final int unconfirmed;
  final int total;
  final String? error;

  const GetBalanceState({
    this.status = GetBalanceStatus.loading,
    this.confirmed = 0,
    this.unconfirmed = 0,
    this.total = 0,
    this.error,
  });

  GetBalanceState copyWith({
    GetBalanceStatus? status,
    int? confirmed,
    int? unconfirmed,
    int? total,
    String? error,
  }) {
    return GetBalanceState(
      status: status ?? this.status,
      confirmed: confirmed ?? this.confirmed,
      unconfirmed: unconfirmed ?? this.unconfirmed,
      total: total ?? this.total,
      error: error ?? this.error,
    );
  }
}
