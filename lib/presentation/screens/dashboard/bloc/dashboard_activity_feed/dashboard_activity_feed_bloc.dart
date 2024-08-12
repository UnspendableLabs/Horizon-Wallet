import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:math';

import "dashboard_activity_feed_event.dart";
import "dashboard_activity_feed_state.dart";
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/entities/activity_feed_item.dart';

final DEFAULT_WHITELIST = ["ENHANCED_SEND", "ASSET_ISSUANCE"];

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

    // final nextState = DashboardActivityFeedStateReloadingOk(
    //   transactions: currentState.transactions,
    //   newTransactionCount: 0,
    // );
    //
    // emit(nextState);

    try {
      // get most recent confirmed tx

      String? mostRecentRemoteHash = currentState.mostRecentRemoteHash;

      final addresses_ =
          await addressRepository.getAllByAccountUuid(accountUuid);

      List<String> addresses = addresses_.map((a) => a.address).toList();

      // no transactions found on initial load
      if (mostRecentRemoteHash == null) {
        // get highest confirmed

        final (events, _, resultCount) =
            await eventsRepository.getByAddressesVerbose(
                addresses: addresses,
                limit: 1,
                unconfirmed: true,
                whitelist: DEFAULT_WHITELIST);

        emit(DashboardActivityFeedStateCompleteOk(
            nextCursor: null,
            newTransactionCount: events.length,
            mostRecentRemoteHash: null,
            transactions: currentState.transactions)); // might have sme locally;

        return;
      } else {
        bool found = false;
        int newTransactionCount = 0;
        int? nextCursor;
        List<Event> remoteEvents = [];

        while (!found) {
          final (remoteEvents_, nextCursor_, _) =
              await eventsRepository.getByAddressesVerbose(
                  addresses: addresses,
                  limit: pageSize,
                  unconfirmed: true,
                  cursor: nextCursor,
                  whitelist: DEFAULT_WHITELIST);

          remoteEvents = [...remoteEvents, ...remoteEvents_];
          // iterate all remote transactions
          for (final event in remoteEvents_) {
            if (event.txHash != mostRecentRemoteHash
                // &&
                //   event.txHash != currentState.transactions[0].hash
                ) {
              print("event.txHash $currentState");
              print("mostRecentRemoteHash $mostRecentRemoteHash");
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

        // final localTransactions =
        //     await transactionLocalRepository.getAllByAccount(accountUuid);
        //
        // final localTransactionsHashes =
        //     Set<String>.from(localTransactions.map((tx) => tx.hash));
        //
        final remoteMap = {for (var e in remoteEvents) e.txHash: e};
        //
        // for (final event in remoteEvents) {
        //   // if at most recent remote hash, break;
        //   if (event.txHash == mostRecentRemoteHash) {
        //     break;
        //   }
        //
        //   if (localTransactionsHashes.contains(event.txHash)) {
        //     newTransactionCount -= 1;
        //   }
        // }

        String? replacedHash;
        List<ActivityFeedItem> nextList = currentState.transactions.map(
          (tx) {
            // if we have a remote representation of a
            if (tx.info != null && remoteMap.containsKey(tx.hash)) {
              newTransactionCount -= 1;
              replacedHash ??= tx.hash;
              return ActivityFeedItem(hash: tx.hash, event: remoteMap[tx.hash]);
            } else {
              return tx;
            }
          },
        ).toList();

        // we only update new transaction count
        // ( i.e. UI stays the same save for banner)
        // that shows current number of news transactions
        // that can be loaded with a click

        final nextNewTransactionCount = max(0, newTransactionCount);
        emit(DashboardActivityFeedStateCompleteOk(
            nextCursor: currentState.nextCursor,
            newTransactionCount: nextNewTransactionCount,
            // mostRecentRemoteHash: nextNewTransactionCount == 0 ? nextList[0].hash : currentState.mostRecentRemoteHash,
            mostRecentRemoteHash:
                replacedHash ?? currentState.mostRecentRemoteHash,
            transactions: nextList));
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
          await eventsRepository.getByAddressesVerbose(
              addresses: addresses,
              cursor: currentState.nextCursor,
              limit: pageSize,
              unconfirmed: true,
              whitelist: DEFAULT_WHITELIST);

      // appent new transactions to existing transactions

      final remoteDisplayTransactions = remoteEvents
          .map((tx) => ActivityFeedItem(hash: tx.txHash, event: tx))
          .toList();

      emit(DashboardActivityFeedStateCompleteOk(
          nextCursor: nextCursor,
          mostRecentRemoteHash: currentState.mostRecentRemoteHash,
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

      final (confirmed, _, _) = await eventsRepository.getByAddressesVerbose(
          addresses: addresses,
          limit: 10,
          unconfirmed: false,
          whitelist: DEFAULT_WHITELIST);

      if (confirmed.isNotEmpty) {
        final event = confirmed[0];
        if (event.state is EventStateConfirmed) {
          int blocktime = (event.state as EventStateConfirmed).blockTime!;

          mostRecentBlocktime =
              DateTime.fromMillisecondsSinceEpoch(blocktime * 1000);
        }
      }

      final localTransactions = mostRecentBlocktime != null
          ? await transactionLocalRepository.getAllByAccountAfterDateVerbose(
              accountUuid, mostRecentBlocktime)
          : await transactionLocalRepository
              .getAllByAccountVerbose(accountUuid);

      final (remoteEvents, nextCursor, _) =
          await eventsRepository.getByAddressesVerbose(
              addresses: addresses,
              limit: pageSize,
              unconfirmed: true,
              whitelist: DEFAULT_WHITELIST);

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
      add(const LoadQuiet());
    });
    add(const Load());
  }

  void _onStopPolling(
      StopPolling event, Emitter<DashboardActivityFeedState> emit) {
    timer?.cancel();
    timer = null;
  }
}
