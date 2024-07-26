import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'dart:async';

import "dashboard_activity_feed_event.dart";
import "dashboard_activity_feed_state.dart";
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/entities/display_transaction.dart';

class DashboardActivityFeedBloc
    extends Bloc<DashboardActivityFeedEvent, DashboardActivityFeedState> {
  Timer? timer;
  String accountUuid;
  int pageSize;
  TransactionRepository transactionRepository;
  TransactionLocalRepository transactionLocalRepository;

  DashboardActivityFeedBloc(
      {required this.accountUuid,
      required this.transactionRepository,
      required this.pageSize,
      required this.transactionLocalRepository})
      : super(DashboardActivityFeedStateInitial()) {
    on<StartPolling>(_onStartPolling);
    on<StopPolling>(_onStopPolling);
    on<Load>(_onLoad);
    on<LoadMore>(_onLoadMore);
    // on<Reload>(_onReload);
  }

  void _onLoadMore(
      LoadMore event, Emitter<DashboardActivityFeedState> emit) async {
    // can only call when stte is complete ok
    if (state is! DashboardActivityFeedStateCompleteOk) {
      return;
    }

    final currentState = state as DashboardActivityFeedStateCompleteOk;

    emit(DashboardActivityFeedStateReloadingOk(
      transactions: currentState.transactions,
      newTransactionCount: currentState.newTransactionCount,
    ));

    try {
      // we don't care about local transactions, just load remote if we have a cursor
      final (remoteTransactions, nextCursor) =
          await transactionRepository.getByAccount(
              accountUuid: accountUuid,
              cursor: currentState.nextCursor,
              unconfirmed: true);

      // appent new transactions to existing transactions

      final remoteDisplayTransactions = remoteTransactions
          .map((tx) => DisplayTransaction(hash: tx.hash, info: tx))
          .toList();

      emit(DashboardActivityFeedStateCompleteOk(
          nextCursor: nextCursor,
          mostRecentRemoteHash:
              remoteTransactions.isNotEmpty ? remoteTransactions[0].hash : null,
          newTransactionCount: currentState.newTransactionCount,
          transactions: [
            ...currentState.transactions,
            ...remoteDisplayTransactions
          ]));
    } catch (e) {
      rethrow;
      emit(DashboardActivityFeedStateCompleteError(error: e.toString()));
    }
  }

  void _onLoad(event, Emitter<DashboardActivityFeedState> emit) async {
    final nextState = switch (state) {
      DashboardActivityFeedStateCompleteOk completeOk =>
        DashboardActivityFeedStateReloadingOk(
          transactions: completeOk.transactions,
          newTransactionCount: 0,
        ),
      DashboardActivityFeedStateCompleteError completeError =>
        DashboardActivityFeedStateReloadingError(
          error: completeError.error,
        ),
      _ => DashboardActivityFeedStateLoading(),
    };

    emit(nextState);

    try {
      DateTime? mostRecentBlocktime;
      // get most recent confirmed tx

      print("accountUuid $accountUuid ");
      final (confirmed, _) = await transactionRepository.getByAccount(
          accountUuid: accountUuid, limit: 1, unconfirmed: false);

      if (confirmed.isNotEmpty) {
        final transaction = confirmed[0];
        if (transaction.domain is TransactionInfoDomainConfirmed) {
          int blocktime =
              (transaction.domain as TransactionInfoDomainConfirmed).blockTime;

          mostRecentBlocktime =
              DateTime.fromMillisecondsSinceEpoch(blocktime * 1000);
        } else {
          print(transaction.domain);
        }
      }

      final localTransactions = mostRecentBlocktime != null
          ? await transactionLocalRepository.getAllByAccountAfterDate(
              accountUuid, mostRecentBlocktime)
          : await transactionLocalRepository.getAllByAccount(accountUuid);

      final (remoteTransactions, nextCursor) = await transactionRepository
          .getByAccount(accountUuid: accountUuid, unconfirmed: true);

      final remoteHashes =
          Set<String>.from(remoteTransactions.map((tx) => tx.hash));

      final localDisplayTransactions = localTransactions
          .where((tx) => !remoteHashes.contains(tx.hash))
          .map((tx) => DisplayTransaction(hash: tx.hash, info: tx))
          .toList();

      final remoteDisplayTransactions = remoteTransactions
          .map((tx) => DisplayTransaction(hash: tx.hash, info: tx))
          .toList();

      emit(DashboardActivityFeedStateCompleteOk(
          nextCursor: nextCursor,
          newTransactionCount: 0,
          mostRecentRemoteHash:
              remoteTransactions.isNotEmpty ? remoteTransactions[0].hash : null,
          transactions: [
            ...localDisplayTransactions,
            ...remoteDisplayTransactions
          ]));
    } catch (e) {
      rethrow;
      emit(DashboardActivityFeedStateCompleteError(error: e.toString()));
    }
  }

  void _onStartPolling(
      StartPolling event, Emitter<DashboardActivityFeedState> emit) {
    timer?.cancel();
    timer = Timer.periodic(event.interval, (_) {
      add(const Load());
    });
    add(const Load());
  }

  void _onStopPolling(
      StopPolling event, Emitter<DashboardActivityFeedState> emit) {
    timer?.cancel();
    timer = null;
  }
}
