import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import "dashboard_activity_feed_event.dart";
import "dashboard_activity_feed_state.dart";
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/entities/display_transaction.dart';

class DashboardActivityFeedBloc
    extends Bloc<DashboardActivityFeedEvent, DashboardActivityFeedState> {
  Timer? _timer;
  String accountUuid;
  TransactionRepository transactionRepository;

  DashboardActivityFeedBloc(
      {required this.accountUuid, required this.transactionRepository})
      : super(DashboardActivityFeedStateInitial()) {
    on<StartPolling>(_onStartPolling);
    on<StopPolling>(_onStopPolling);
    on<Load>(_onLoad);
  }

  void _onLoad(Load event, Emitter<DashboardActivityFeedState> emit) async {
    emit(DashboardActivityFeedStateLoading());

    try {
      // 1. Get all local transactions

      final transactions =
          await transactionRepository.getAllByAccount(accountUuid);

      // 2. get all transactions in mempool
      // skipping for now since can't really test mempool on
      // on testnet

      // 3. get all confirmed transactions up to a limit

      // 4. convert to display

      final displayTransactions =
          transactions.map((tx) => DisplayTransaction(hash: tx.hash)).toList();

      emit(DashboardActivityFeedStateCompleteOk(
          newTransactionCount: 0, transactions: displayTransactions));
    } catch (e) {
      emit(DashboardActivityFeedStateCompleteError(error: e.toString()));
    }
  }

  void _onStartPolling(
      StartPolling event, Emitter<DashboardActivityFeedState> emit) {
    _timer?.cancel();
    _timer = Timer.periodic(event.interval, (_) {
      add(const Reload());
    });
    add(const Load());
  }

  void _onStopPolling(
      StopPolling event, Emitter<DashboardActivityFeedState> emit) {
    _timer?.cancel();
    _timer = null;
  }
}
