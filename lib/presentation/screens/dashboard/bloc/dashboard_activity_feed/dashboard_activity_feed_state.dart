import "package:equatable/equatable.dart";
import "package:horizon/data/sources/network/api/cursor.dart";
import "package:horizon/domain/entities/activity_feed_item.dart";

abstract class DashboardActivityFeedState extends Equatable {
  const DashboardActivityFeedState();

  @override
  List<Object?> get props => [];
}

class DashboardActivityFeedStateInitial extends DashboardActivityFeedState {}

class DashboardActivityFeedStateLoading extends DashboardActivityFeedState {}

// TODO: really wish there was a nice result type that i could put in something
// like DashboardActivityFeedLoaded but not sure if that will allow me to
// take advantage of native pattern matching, so just multiplying out all
// of the possible states as classes that extend DashboardActivityFeedState

class DashboardActivityFeedStateCompleteOk extends DashboardActivityFeedState {
  final List<ActivityFeedItem> transactions;
  final int newTransactionCount;
  final Cursor? nextCursor;
  final String? mostRecentCounterpartyEventHash;
  final String? mostRecentBitcoinTxHash;

  const DashboardActivityFeedStateCompleteOk({
    required this.transactions,
    required this.newTransactionCount,
    required this.nextCursor,
    required this.mostRecentCounterpartyEventHash,
    required this.mostRecentBitcoinTxHash,
  });

  @override
  List<Object?> get props => [
        List<Object?>.from(transactions),
        newTransactionCount,
        nextCursor,
        mostRecentCounterpartyEventHash
      ];
}

class DashboardActivityFeedStateCompleteError
    extends DashboardActivityFeedState {
  final String error;
  const DashboardActivityFeedStateCompleteError({required this.error});
  @override
  List<Object> get props => [error];
}

class DashboardActivityFeedStateReloadingOk extends DashboardActivityFeedState {
  final List<ActivityFeedItem> transactions;
  final int newTransactionCount;

  const DashboardActivityFeedStateReloadingOk(
      {required this.transactions, required this.newTransactionCount});

  copyWith({List<ActivityFeedItem>? transactions, int? newTransactionCount}) {
    return DashboardActivityFeedStateReloadingOk(
        transactions: transactions ?? this.transactions,
        newTransactionCount: newTransactionCount ?? this.newTransactionCount);
  }

  @override
  List<Object> get props =>
      [List<Object>.from(transactions), newTransactionCount];
}

class DashboardActivityFeedStateReloadingError
    extends DashboardActivityFeedState {
  final String error;
  const DashboardActivityFeedStateReloadingError({required this.error});

  copyWith({String? error}) {
    return DashboardActivityFeedStateReloadingError(error: error ?? this.error);
  }

  @override
  List<Object> get props => [error];
}
