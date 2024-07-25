import 'package:flutter_bloc/flutter_bloc.dart';
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
    // on<Reload>(_onReload);
  }

  // void _onLoad(Load event, Emitter<DashboardActivityFeedState> emit) async {
  //   emit(DashboardActivityFeedStateLoading());
  //
  //
  //   try {
  //     // 1. Get all local transactions
  //
  //     final transactions =
  //         await transactionRepository.getAllByAccount(accountUuid);
  //
  //     // 2. get all transactions in mempool
  //     // skipping for now since can't really test mempool on
  //     // on testnet
  //
  //     // 3. get all confirmed transactions up to a limit
  //
  //     // 4. convert to display
  //
  //     final displayTransactions =
  //         transactions.map((tx) => DisplayTransaction(hash: tx.hash)).toList();
  //
  //     emit(DashboardActivityFeedStateCompleteOk(
  //         newTransactionCount: 0, transactions: displayTransactions));
  //   } catch (e) {
  //     emit(DashboardActivityFeedStateCompleteError(error: e.toString()));
  //   }
  // }

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
      final localTransactions =
          await transactionLocalRepository.getAllByAccount(accountUuid);

      final displayTransactionsLocal = localTransactions
          .map((tx) => DisplayTransaction(hash: tx.hash))
          .toList();

      // 1. Get all local transactions
      final (remoteTransactions, _nextCursor) =
          await transactionRepository.getByAccount(accountUuid: accountUuid);

      final displayTransactionsRemote = remoteTransactions
          .map((tx) => DisplayTransaction(hash: tx.hash))
          .toList();

      emit(DashboardActivityFeedStateCompleteOk(
          newTransactionCount: 0,
          transactions: [
            ...displayTransactionsLocal,
            ...displayTransactionsRemote
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
