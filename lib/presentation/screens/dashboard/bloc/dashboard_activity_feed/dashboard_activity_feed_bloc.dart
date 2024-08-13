import 'package:flutter_bloc/flutter_bloc.dart';
import "package:fpdart/src/either.dart";
import 'dart:async';
import 'dart:math';

import "dashboard_activity_feed_event.dart";
import "dashboard_activity_feed_state.dart";

import 'package:horizon/domain/repositories/bitcoin_repository.dart';
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
  BitcoinRepository bitcoinRepository;

  DashboardActivityFeedBloc(
      {required this.accountUuid,
      required this.eventsRepository,
      required this.pageSize,
      required this.transactionLocalRepository,
      required this.addressRepository,
      required this.bitcoinRepository})
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
      String? mostRecentCounterpartyEventHash =
          currentState.mostRecentCounterpartyEventHash;

      final addresses_ =
          await addressRepository.getAllByAccountUuid(accountUuid);

      List<String> addresses = addresses_.map((a) => a.address).toList();

      // no transactions found on initial load
      if (mostRecentCounterpartyEventHash == null) {
        // get highest confirmed

        final (events, _, resultCount) =
            await eventsRepository.getByAddressesVerbose(
                addresses: addresses,
                limit: 1,
                unconfirmed: true,
                whitelist: DEFAULT_WHITELIST);

        // TODO: add mempool here

        emit(DashboardActivityFeedStateCompleteOk(
            nextCursor: null,
            newTransactionCount: events.length,
            mostRecentCounterpartyEventHash: null,
            transactions:
                currentState.transactions)); // might have sme locally;

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
            if (event.txHash != mostRecentCounterpartyEventHash
                // &&
                //   event.txHash != currentState.transactions[0].hash
                ) {
              newTransactionCount += 1;
            } else {
              found = true;
              break;
            }
          }

          // if we don't have a cursor, and we haven't
          // found a match, brea... but this shouldn't
          // happen i don't think
          if (nextCursor == null) {
            break;
          } else {
            nextCursor = nextCursor;
          }
        }

        final remoteMap = {for (var e in remoteEvents) e.txHash: e};

        final btcMempoolE =
            await bitcoinRepository.getMempoolTransactions(addresses);

        final btcMempoolList = switch (btcMempoolE) {
          Left(value: var failure) => throw Exception(failure.message),
          Right(value: var transactions) => transactions
        };

        final btcMempoolMap = {for (var tx in btcMempoolList) tx.txid: tx};

        // increase new tx count by length of mempool list
        // TODO: ( we may need to factor out OP return );
        // not an issue on regtest on testnet tho

        newTransactionCount += btcMempoolList.length;

        String? replacedHash;
        List<ActivityFeedItem> nextList = currentState.transactions.map(
          (tx) {
            if (tx.info != null &&
                tx.info!.btcAmount != null &&
                tx.info!.btcAmount! > 0 &&
                btcMempoolMap.containsKey(tx.hash)) {
              // this is a btc transaction so we can swap it out
              newTransactionCount -= 1;
              return ActivityFeedItem(
                  hash: tx.hash, bitcoinTx: btcMempoolMap[tx.hash]);
            }

            if (tx.info != null && remoteMap.containsKey(tx.hash)) {
              newTransactionCount -= 1;
              replacedHash ??= tx.hash;
              return ActivityFeedItem(hash: tx.hash, event: remoteMap[tx.hash]);
            }

            return tx;
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
            // mostRecentCounterpartyEventHash: nextNewTransactionCount == 0 ? nextList[0].hash : currentState.mostRecentCounterpartyEventHash,
            mostRecentCounterpartyEventHash:
                replacedHash ?? currentState.mostRecentCounterpartyEventHash,
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
          mostRecentCounterpartyEventHash:
              currentState.mostRecentCounterpartyEventHash,
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

      // get most recent confirmed tx so we can query local txs above blocktime
      final (confirmedCounterpartyEvents, _, _) =
          await eventsRepository.getByAddressesVerbose(
              addresses: addresses,
              limit: 10,
              unconfirmed: false,
              whitelist: DEFAULT_WHITELIST);

      if (confirmedCounterpartyEvents.isNotEmpty) {
        final event = confirmedCounterpartyEvents[0];
        if (event.state is EventStateConfirmed) {
          int blocktime = (event.state as EventStateConfirmed).blockTime!;

          mostRecentBlocktime =
              DateTime.fromMillisecondsSinceEpoch(blocktime * 1000);
        }
      }

      // query local transactions above mose recent confirmed event
      final localTransactions = mostRecentBlocktime != null
          ? await transactionLocalRepository.getAllByAccountAfterDateVerbose(
              accountUuid, mostRecentBlocktime)
          : await transactionLocalRepository
              .getAllByAccountVerbose(accountUuid);

      // get all counterparty events

      final (counterpartyEvents, nextCursor, _) =
          await eventsRepository.getByAddressesVerbose(
              addresses: addresses,
              limit: pageSize,
              unconfirmed: true,
              whitelist: DEFAULT_WHITELIST);

      // factor out counterparty events by unconfirmed / confirmed
      List<VerboseEvent> counterpartyMempool = [];
      List<VerboseEvent> counterpartyConfirmed = [];

      for (final event in counterpartyEvents) {
        switch (event.state) {
          case EventStateMempool():
            counterpartyMempool.add(event);
          case EventStateConfirmed():
            counterpartyConfirmed.add(event);
        }
      }

      final counterpartyMempoolByHash = {
        for (var e in counterpartyMempool) e.txHash: e
      };

      final counterpartyConfirmedByHash = {
        for (var e in counterpartyConfirmed) e.txHash: e
      };

      // get all btc mempool transactions
      final btcMempoolE =
          await bitcoinRepository.getMempoolTransactions(addresses);

      final btcMempoolList =
          btcMempoolE.getOrElse((left) => throw Exception(left));

      final btcMempoolMap = {for (var tx in btcMempoolList) tx.txid: tx};

      final btcConfirmedE = await bitcoinRepository.getConfirmedTransactions(addresses);

      final btcConfirmedList =
          btcConfirmedE.getOrElse((left) => throw Exception(left));

      final btcConfirmedMap = {for (var tx in btcConfirmedList) tx.txid: tx};

      // Local transactions are not seen in either the:
      //    1) counterparty mempool
      //    2) counterparty confirmed
      //    3) btc mempool
      //    4) btc confirmed

      List<ActivityFeedItem> localActivityFeedItems = localTransactions
          .where((tx) =>
              !counterpartyMempoolByHash.keys.contains(tx.hash) &&
              !counterpartyConfirmedByHash.keys.contains(tx.hash) &&
              !btcConfirmedMap.keys.contains(tx.hash) &&
              !btcMempoolMap.keys.contains(tx.hash))
          .map((tx) {
        return ActivityFeedItem(hash: tx.hash, info: tx);
      }).toList();

      // mempool transactions are the set of txs in ( preferring counterparty events over btc):
      //  1) counterpartry mempool
      //  2) btc mempool
      List<ActivityFeedItem> mempoolActivityFeedItems = [];

      // don't add btc mempool if it's in the counterparty mempoool
      for (final tx in btcMempoolList) {
        mempoolActivityFeedItems
            .add(ActivityFeedItem(hash: tx.txid, bitcoinTx: tx));
      }

      for (final tx in counterpartyMempool) {
        mempoolActivityFeedItems
            .add(ActivityFeedItem(hash: tx.txHash, event: tx));
      }

      // add btc confirmed, preferring counterparty events
      // where there are conflicts and sorting by blockIndex

      List<ActivityFeedItem> confirmedActivityFeedItems = [];

      for (final tx in btcConfirmedList) {
        if (counterpartyConfirmedByHash.containsKey(tx.txid)) {
          confirmedActivityFeedItems.add(ActivityFeedItem(
              hash: tx.txid, event: counterpartyConfirmedByHash[tx.txid]));
        } else {
          confirmedActivityFeedItems
              .add(ActivityFeedItem(hash: tx.txid, bitcoinTx: tx));
        }
      }

      for (final tx in counterpartyConfirmed) {
        if (!btcConfirmedMap.containsKey(tx.txHash)) {
          confirmedActivityFeedItems
              .add(ActivityFeedItem(hash: tx.txHash, event: tx));
        }
      }

      emit(DashboardActivityFeedStateCompleteOk(
          nextCursor: nextCursor,
          newTransactionCount: 0,
          mostRecentCounterpartyEventHash: counterpartyEvents.isNotEmpty
              ? counterpartyEvents[0].txHash
              : null,
          transactions: [
            ...localActivityFeedItems,
            ...mempoolActivityFeedItems,
            ...confirmedActivityFeedItems, // ...remoteDisplayTransactions
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
