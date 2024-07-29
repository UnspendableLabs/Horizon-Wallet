import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'dart:async';

import "dashboard_activity_feed_event.dart";
import "dashboard_activity_feed_state.dart";
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/entities/activity_feed_item.dart';

class DashboardActivityFeedBloc
    extends Bloc<DashboardActivityFeedEvent, DashboardActivityFeedState> {
  Timer? timer;
  String accountUuid;
  int pageSize;
  TransactionLocalRepository transactionLocalRepository;
  EventsRepository eventsRepository;
  AddressRepository addressRepository;

  DashboardActivityFeedBloc(
      {required this.accountUuid,
      required this.eventsRepository,
      required this.pageSize,
      required this.transactionLocalRepository,
      required this.addressRepository})
      : super(DashboardActivityFeedStateInitial()) {
    on<StartPolling>(_onStartPolling);
    on<StopPolling>(_onStopPolling);
    on<Load>(_onLoad);
    on<LoadMore>(_onLoadMore);
    on<LoadQuiet>(_onLoadQuiet);
    // on<Reload>(_onReload);
  }

  void _onLoadQuiet(
      LoadQuiet event, Emitter<DashboardActivityFeedState> emit) async {
    // just do a standard load if we are in any state other than complete ok
    if (state is! DashboardActivityFeedStateCompleteOk) {
      add(const Load());
      return;
    }

    final currentState = state as DashboardActivityFeedStateCompleteOk;

    final nextState = DashboardActivityFeedStateReloadingOk(
      transactions: currentState.transactions,
      newTransactionCount: 0,
    );

    emit(nextState);

    try {
      // get most recent confirmed tx

      String? mostRecentRemoteHash = currentState.mostRecentRemoteHash;

      final addresses_ =
          await addressRepository.getAllByAccountUuid(accountUuid);

      List<String> addresses = addresses_.map((a) => a.address).toList();

      // no transactions found on initial load
      if (mostRecentRemoteHash == null) {
        // get highest confirmed

        final (_, _, resultCount) =
            await eventsRepository.getByAddressesVerbose(
                addresses: addresses, limit: 1, unconfirmed: true);

        emit(DashboardActivityFeedStateCompleteOk(
            nextCursor: null,
            newTransactionCount: resultCount ?? 0,
            mostRecentRemoteHash: null,
            transactions: const []));

        return;
      } else {
        bool found = false;
        int newTransactionCount = 0;
        int? nextCursor;

        while (!found) {
          final (remoteEvents, nextCursor_, _) =
              await eventsRepository.getByAddressesVerbose(
                  addresses: addresses,
                  limit: pageSize,
                  unconfirmed: true,
                  cursor: nextCursor);
          // iterate all remote transactions
          for (final event in remoteEvents) {
            if (event.txHash != mostRecentRemoteHash) {
              newTransactionCount += 1;
            } else {
              found = true;
              break;
            }
          }

          // if we don't have a cursor, and we haven't
          // found a match, break... but this shouldn't
          // happen i don't think
          if (nextCursor == null) {
            break;
          } else {
            nextCursor = nextCursor;
          }
        }

        // we only update new transaction count
        // ( i.e. UI stays the same save for banner)
        // that shows current number of news transactions
        // that can be loaded with a click
        emit(DashboardActivityFeedStateCompleteOk(
            nextCursor: currentState.nextCursor,
            newTransactionCount: newTransactionCount,
            mostRecentRemoteHash: currentState.mostRecentRemoteHash,
            transactions: currentState.transactions));
      }
    } catch (e) {
      rethrow;
      emit(DashboardActivityFeedStateCompleteError(error: e.toString()));
    }
  }

  void _onLoadMore(
      LoadMore event, Emitter<DashboardActivityFeedState> emit) async {
    // can only call when stte is complete ok
    if (state is! DashboardActivityFeedStateCompleteOk) {
      return;
    }

    final currentState = state as DashboardActivityFeedStateCompleteOk;

    // we are at the end of the list
    if (currentState.nextCursor == null) {
      return;
    }

    emit(DashboardActivityFeedStateReloadingOk(
      transactions: currentState.transactions,
      newTransactionCount: currentState.newTransactionCount,
    ));

    try {
      // we don't care about local transactions, just load remote if we have a cursor

      final addresses_ =
          await addressRepository.getAllByAccountUuid(accountUuid);

      List<String> addresses = addresses_.map((a) => a.address).toList();

      final (remoteEvents, nextCursor, _) =
          await eventsRepository.getByAddresses(
              addresses: addresses,
              cursor: currentState.nextCursor,
              limit: pageSize,
              unconfirmed: true);

      // appent new transactions to existing transactions

      final remoteDisplayTransactions = remoteEvents
          .map((tx) => ActivityFeedItem(hash: tx.txHash, event: tx))
          .toList();

      emit(DashboardActivityFeedStateCompleteOk(
          nextCursor: nextCursor,
          mostRecentRemoteHash:
              remoteEvents.isNotEmpty ? remoteEvents[0].txHash : null,
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
      final addresses_ =
          await addressRepository.getAllByAccountUuid(accountUuid);

      List<String> addresses = addresses_.map((a) => a.address).toList();

      final (confirmed, _, _) = await eventsRepository.getByAddresses(
          addresses: addresses, limit: 1, unconfirmed: false);

      if (confirmed.isNotEmpty) {
        final event = confirmed[0];
        if (event.state is EventStateConfirmed) {
          int blocktime = (event.state as EventStateConfirmed).blockTime!;

          mostRecentBlocktime =
              DateTime.fromMillisecondsSinceEpoch(blocktime * 1000);
        }
      }

      final localTransactions = mostRecentBlocktime != null
          ? await transactionLocalRepository.getAllByAccountAfterDate(
              accountUuid, mostRecentBlocktime)
          : await transactionLocalRepository.getAllByAccount(accountUuid);

      final (remoteEvents, nextCursor, _) =
          await eventsRepository.getByAddresses(
              addresses: addresses, limit: pageSize, unconfirmed: true);

      final remoteHashes =
          Set<String>.from(remoteEvents.map((event) => event.txHash));

      final localDisplayTransactions = localTransactions
          .where((tx) => !remoteHashes.contains(tx.hash))
          .map((tx) => ActivityFeedItem(hash: tx.hash, info: tx))
          .toList();

      final remoteDisplayTransactions = remoteEvents
          .map((event) => ActivityFeedItem(hash: event.txHash, event: event))
          .toList();

      emit(DashboardActivityFeedStateCompleteOk(
          nextCursor: nextCursor,
          newTransactionCount: 0,
          mostRecentRemoteHash:
              remoteEvents.isNotEmpty ? remoteEvents[0].txHash : null,
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
