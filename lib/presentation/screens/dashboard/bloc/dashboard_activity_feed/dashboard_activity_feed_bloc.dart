import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/cursor.dart';
import 'dart:async';

import "dashboard_activity_feed_event.dart";
import "dashboard_activity_feed_state.dart";

import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/activity_feed_item.dart';

// ignore: non_constant_identifier_names
final DEFAULT_WHITELIST = [
  "ENHANCED_SEND",
  "ASSET_ISSUANCE",
  "DISPENSE",
  "OPEN_DISPENSER",
  "REFILL_DISPENSER",
  "RESET_ISSUANCE",
  "ASSET_CREATION",
];

class DashboardActivityFeedBloc
    extends Bloc<DashboardActivityFeedEvent, DashboardActivityFeedState> {
  Timer? timer;
  Address currentAddress;
  int pageSize;
  TransactionLocalRepository transactionLocalRepository;
  EventsRepository eventsRepository;
  AddressRepository addressRepository;
  BitcoinRepository bitcoinRepository;
  bool _isLoading = false; // New flag to track loading state
  bool _isCancelled = false;

  DashboardActivityFeedBloc(
      {required this.currentAddress,
      required this.eventsRepository,
      required this.pageSize,
      required this.transactionLocalRepository,
      required this.addressRepository,
      required this.bitcoinRepository})
      : super(DashboardActivityFeedStateInitial()) {
    on<StartPolling>(_onStartPolling);
    on<StopPolling>(_onStopPolling);
    on<Load>(_onLoad);
    // on<LoadMore>(_onLoadMore);
    on<LoadQuiet>(_onLoadQuiet);
    // on<Reload>(_onReload);
  }
  void _onLoadQuiet(
      LoadQuiet event, Emitter<DashboardActivityFeedState> emit) async {
    // just do a standard load if we are in any state other than complete ok

    if (_isLoading) return;

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
      String address = currentAddress.address;

      String? mostRecentCounterpartyEventHash =
          currentState.mostRecentCounterpartyEventHash;
      String? mostRecentBitcoinTxHash = currentState.mostRecentBitcoinTxHash;

      // 1) compute count of all counterparty events above last seen
      late List<VerboseEvent> newCounterpartyEvents = [];
      if (mostRecentCounterpartyEventHash == null) {
        // 1a) if null, list of new counterparty events is =
        //     all returned by getEventsByAddress.  But we
        //     need to fetch all in order to dedupe by
        //     by txhash

        newCounterpartyEvents = await eventsRepository.getAllByAddressVerbose(
            address: address, unconfirmed: true, whitelist: DEFAULT_WHITELIST);
      } else {
        // 1b) otherwise, we need to get the list of all events
        //     above the most recent counterparty event hash
        bool found = false;
        Cursor? nextCursor;
        while (!found) {
          final (remoteEvents, nextCursor_, _) =
              await eventsRepository.getByAddressVerbose(
                  address: address,
                  limit: pageSize,
                  unconfirmed: true,
                  cursor: nextCursor,
                  whitelist: DEFAULT_WHITELIST);

          for (final event in remoteEvents) {
            if (event.txHash == mostRecentCounterpartyEventHash) {
              found = true;
              break;
            }
            newCounterpartyEvents.add(event);
          }

          if (found || nextCursor_ == null) {
            break;
          } else {
            nextCursor = nextCursor_;
          }
        }
      }

      // 2) compute all new btc transactions above last seen
      List<BitcoinTx> newBitcoinTransactions = [];
      if (mostRecentBitcoinTxHash == null) {
        // 2a) if null list of new btc transactions equal to all of them
        final bitcoinTxsE = await bitcoinRepository.getTransactions([address]);

        // TODO: we should at least log that there was an error here.
        //       but correct behavior is to just ignore.
        newBitcoinTransactions = bitcoinTxsE
            .getOrElse((left) => throw left)
            .where(
              (tx) => !tx.isCounterpartyTx(),
            )
            .toList();
      } else {
        // 2b otherwise, bitcoin transactions are all above last seen
        final bitcoinTxsE = await bitcoinRepository.getTransactions([address]);

        // TODO: log possible excetion here
        final bitcoinTxs = bitcoinTxsE
            .getOrElse((left) => throw left)
            .where(
              (tx) => !tx.isCounterpartyTx(),
            )
            .toList();

        for (final tx in bitcoinTxs) {
          if (tx.txid == mostRecentBitcoinTxHash) {
            break;
          }
          newBitcoinTransactions.add(tx);
        }
      }

      final blockHeightE = await bitcoinRepository.getBlockHeight();
      final blockHeight = blockHeightE.getOrElse((left) => throw left);

      // 3) dedupe by tx hash
      final deduplicatedActivityFeedItems = <ActivityFeedItem>[];
      final seenHashes = <String>{};

      for (final event in newCounterpartyEvents) {
        if (!seenHashes.contains(event.txHash)) {
          final activityFeedItem =
              ActivityFeedItem(hash: event.txHash, event: event);
          if (activityFeedItem.getBlockIndex() != null) {
            activityFeedItem.confirmations = _getConfirmations(
                blockHeight, activityFeedItem.getBlockIndex()!);
          }
          deduplicatedActivityFeedItems.add(activityFeedItem);
          seenHashes.add(event.txHash);
        }
      }

      for (final btcTx in newBitcoinTransactions) {
        if (!seenHashes.contains(btcTx.txid)) {
          final activityFeedItem =
              ActivityFeedItem(hash: btcTx.txid, bitcoinTx: btcTx);
          if (activityFeedItem.getBlockIndex() != null) {
            activityFeedItem.confirmations = _getConfirmations(
                blockHeight, activityFeedItem.getBlockIndex()!);
          }
          deduplicatedActivityFeedItems.add(activityFeedItem);
          seenHashes.add(btcTx.txid);
        }
      }
      // Sort the deduplicated transactions
      deduplicatedActivityFeedItems.sort((a, b) {
        final aIndex = a.getBlockIndex();
        final bIndex = b.getBlockIndex();
        return (bIndex ?? -1).compareTo(aIndex ?? -1);
      });

      final deduplicatedActivityFeedMap = {
        for (var tx in deduplicatedActivityFeedItems) tx.hash: tx
      };

      String? nextMostRecentBitcoinTxHash;
      String? nextMostRecentCounterpartyEventHash;

      final transactionMap = {
        for (final tx in currentState.transactions) tx.hash: tx
      };
      // new transaction count = deduplicated activity feed items
      // without correspondint hash in existing transactions
      int newTransactionCount = 0;

      for (final tx in deduplicatedActivityFeedItems) {
        if (!transactionMap.containsKey(tx.hash)) {
          newTransactionCount++;
        }
      }

      List<ActivityFeedItem> nextList = currentState.transactions.map(
        (tx) {
          ActivityFeedItem updatedTx = tx;

          // 1) local -> mempool | confirmed
          if (tx.info != null &&
              deduplicatedActivityFeedMap.containsKey(tx.hash)) {
            updatedTx = deduplicatedActivityFeedMap[tx.hash]!;
          }

          // 2) mempool -> confirmed
          // 2a) if item is btc and mempool and we have confirmed, replace it
          else if (tx.bitcoinTx != null &&
              !tx.bitcoinTx!.status.confirmed &&
              deduplicatedActivityFeedMap.containsKey(tx.hash)) {
            final newTx = deduplicatedActivityFeedMap[tx.hash]!;
            if (newTx.bitcoinTx != null && newTx.bitcoinTx!.status.confirmed) {
              updatedTx = newTx;
            }
          }

          // 2b) if item is xcp and mempool and we have confirmed, replace it
          else if (tx.event != null &&
              tx.event!.state is EventStateMempool &&
              deduplicatedActivityFeedMap.containsKey(tx.hash)) {
            final newTx = deduplicatedActivityFeedMap[tx.hash]!;
            if (newTx.event != null &&
                newTx.event!.state is EventStateConfirmed) {
              updatedTx = newTx;
            }
          }

          if (updatedTx.bitcoinTx != null &&
              updatedTx.bitcoinTx!.status.confirmed) {
            nextMostRecentBitcoinTxHash ??= updatedTx.hash;
          } else if (updatedTx.event != null) {
            nextMostRecentCounterpartyEventHash ??= updatedTx.hash;
          }

          return updatedTx;
        },
      ).toList();

      // we only update new transaction count
      // ( i.e. UI stays the same save for banner)
      // that shows current number of news transactions
      // that can be loaded with a click

      emit(DashboardActivityFeedStateCompleteOk(
        nextCursor: currentState.nextCursor,
        newTransactionCount: newTransactionCount,
        mostRecentBitcoinTxHash:
            nextMostRecentBitcoinTxHash ?? currentState.mostRecentBitcoinTxHash,
        mostRecentCounterpartyEventHash: nextMostRecentCounterpartyEventHash ??
            currentState.mostRecentCounterpartyEventHash,
        transactions: nextList,
      ));
    } catch (e) {
      // if we fail for any reason, just emit current state ( which is CompleteOK)
      emit(currentState);
    }
  }

  // we just load everything for now

  // void _onLoadMore(
  //     LoadMore event, Emitter<DashboardActivityFeedState> emit) async {
  //   // can only call when stte is complete ok
  //   if (state is! DashboardActivityFeedStateCompleteOk) {
  //     return;
  //   }
  //
  //   final currentState = state as DashboardActivityFeedStateCompleteOk;
  //
  //   // we are at the end of the list
  //   if (currentState.nextCursor == null) {
  //     return;
  //   }
  //
  //   emit(DashboardActivityFeedStateReloadingOk(
  //     transactions: currentState.transactions,
  //     newTransactionCount: currentState.newTransactionCount,
  //   ));
  //
  //   try {
  //     // we don't care about local transactions, just load remote if we have a cursor
  //
  //     final addresses_ =
  //         await addressRepository.getAllByAccountUuid(accountUuid);
  //
  //     List<String> addresses = addresses_.map((a) => a.address).toList();
  //
  //     final (remoteEvents, nextCursor, _) =
  //         await eventsRepository.getByAddressesVerbose(
  //             addresses: addresses,
  //             cursor: currentState.nextCursor,
  //             limit: pageSize,
  //             unconfirmed: true,
  //             whitelist: DEFAULT_WHITELIST);
  //
  //     // appent new transactions to existing transactions
  //
  //     final remoteDisplayTransactions = remoteEvents
  //         .map((tx) => ActivityFeedItem(hash: tx.txHash, event: tx))
  //         .toList();
  //
  //     emit(DashboardActivityFeedStateCompleteOk(
  //         nextCursor: nextCursor,
  //         mostRecentCounterpartyEventHash:
  //             currentState.mostRecentCounterpartyEventHash,
  //         newTransactionCount: currentState.newTransactionCount,
  //         transactions: [
  //           ...currentState.transactions,
  //           ...remoteDisplayTransactions
  //         ]));
  //   } catch (e) {
  //     rethrow;
  //     emit(DashboardActivityFeedStateCompleteError(error: e.toString()));
  //   }
  // }

  void _onLoad(event, Emitter<DashboardActivityFeedState> emit) async {
    if (_isLoading) return; // Skip if already loading
    _isLoading = true;

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
      // get most recent confirmed tx
      final addresses_ = [currentAddress];

      List<String> addresses = addresses_.map((a) => a.address).toList();

      // query local transactions above mose recent confirmed event
      final localTransactions =
          await transactionLocalRepository.getAllByAddressesVerbose(addresses);

      final counterpartyEvents = await eventsRepository.getAllByAddressVerbose(
          address: currentAddress.address,
          // limit: pageSize,
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

      final btcMempoolList = btcMempoolE
          .getOrElse((left) => throw left)
          .where(
            (tx) => !tx.isCounterpartyTx(),
          )
          .toList();

      final btcMempoolMap = {for (var tx in btcMempoolList) tx.txid: tx};

      String? lastSeenTxId;
      bool hasMore = true;
      List allBTCConfirmed = [];

      final blockHeightE = await bitcoinRepository.getBlockHeight();
      final blockHeight = blockHeightE.getOrElse((left) => throw left);

      while (hasMore) {
        if (_isCancelled) {
          _isCancelled = false;
          break;
        }
        final transactionsE = await bitcoinRepository
            .getConfirmedTransactionsPaginated(addresses[0], lastSeenTxId);

        final btcConfirmedList = transactionsE.getOrElse((left) => throw left);

        if (btcConfirmedList.isEmpty) {
          hasMore = false;
        } else {
          lastSeenTxId = btcConfirmedList.last.txid;
        }

        allBTCConfirmed.addAll(btcConfirmedList);

        final btcConfirmedMap = {for (var tx in allBTCConfirmed) tx.txid: tx};

        List<ActivityFeedItem> localActivityFeedItems = localTransactions
            .where((tx) =>
                !counterpartyMempoolByHash.keys.contains(tx.hash) &&
                !counterpartyConfirmedByHash.keys.contains(tx.hash) &&
                !btcConfirmedMap.keys.contains(tx.hash) &&
                !btcMempoolMap.keys.contains(tx.hash))
            .map((tx) {
          return ActivityFeedItem(hash: tx.hash, info: tx);
        }).toList();

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
        final seenHashes = <String>{};
        for (final event in counterpartyConfirmed) {
          if (!seenHashes.contains(event.txHash)) {
            final activityFeedItem =
                ActivityFeedItem(hash: event.txHash, event: event);

            activityFeedItem.confirmations = _getConfirmations(
                blockHeight, activityFeedItem.getBlockIndex()!);
            confirmedActivityFeedItems.add(activityFeedItem);
            seenHashes.add(event.txHash);
          }
        }

        for (final btx in allBTCConfirmed) {
          if (!seenHashes.contains(btx.txid)) {
            final activityFeedItem =
                ActivityFeedItem(hash: btx.txid, bitcoinTx: btx);
            activityFeedItem.confirmations = _getConfirmations(
                blockHeight, activityFeedItem.getBlockIndex()!);
            confirmedActivityFeedItems.add(activityFeedItem);
            seenHashes.add(btx.txid);
          }
        }

        confirmedActivityFeedItems.sort((a, b) {
          final aIndex = a.getBlockIndex();
          final bIndex = b.getBlockIndex();
          return (bIndex ?? -1).compareTo(aIndex ?? -1);
        });

        final transactions = [
          ...localActivityFeedItems,
          ...mempoolActivityFeedItems,
          ...confirmedActivityFeedItems,
        ];

        emit(DashboardActivityFeedStateCompleteOk(
            nextCursor: null,
            newTransactionCount: 0,
            mostRecentBitcoinTxHash:
                allBTCConfirmed.isNotEmpty ? allBTCConfirmed[0].txid : null,
            mostRecentCounterpartyEventHash: counterpartyEvents.isNotEmpty
                ? counterpartyEvents[0].txHash
                : null,
            transactions: transactions));
      }
    } catch (e) {
      emit(DashboardActivityFeedStateCompleteError(error: e.toString()));
    } finally {
      _isLoading = false;
    }
  }

  void _onStartPolling(
      StartPolling event, Emitter<DashboardActivityFeedState> emit) {
    if (timer != null) {
      return;
    }

    _isCancelled = false;
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
    _isCancelled = true;
  }

  int _getConfirmations(int blockHeight, int blockIndex) {
    // Number of confirmations = Current Bitcoin block height - Transaction block height + 1
    final confirmations = blockHeight - blockIndex + 1;
    return confirmations;
  }
}
