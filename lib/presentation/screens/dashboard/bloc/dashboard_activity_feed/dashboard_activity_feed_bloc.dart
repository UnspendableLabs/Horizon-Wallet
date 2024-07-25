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
      DateTime? mostRecentBlocktime;
      // get most recent confirmed tx
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

      // 1. Get all local transactions
      final (remoteTransactions, _) =
          await transactionRepository.getByAccount(accountUuid: accountUuid);

      // 2. Create a set of remote transaction hashes for quick lookup
      final remoteHashes =
          Set<String>.from(remoteTransactions.map((tx) => tx.hash));

      // 3. Create DisplayTransactions for local transactions, excluding those that exist in remote
      final localDisplayTransactions = localTransactions
          .where((tx) => !remoteHashes.contains(tx.hash))
          .map((tx) => DisplayTransaction(hash: tx.hash, info: tx))
          .toList();

      // 4. Create DisplayTransactions for remote transactions
      final remoteDisplayTransactions = remoteTransactions
          .map((tx) => DisplayTransaction(hash: tx.hash, info: tx))
          .toList();

      emit(DashboardActivityFeedStateCompleteOk(
          newTransactionCount: 0,
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
