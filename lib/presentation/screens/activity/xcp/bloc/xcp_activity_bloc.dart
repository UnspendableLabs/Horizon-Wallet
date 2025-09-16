import 'package:chrome_extension/tts.dart';
import "package:equatable/equatable.dart";
import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';
import "package:horizon/domain/entities/cursor.dart";
import 'package:horizon/domain/entities/remote_data.dart';
import "package:horizon/domain/entities/activity_feed_item.dart";
import 'package:horizon/domain/entities/event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';

final DEFAULT_WHITELIST = [
  "ENHANCED_SEND",
  "MPMA_SEND",
  "ASSET_ISSUANCE",
  "DISPENSE",
  "OPEN_DISPENSER",
  "REFILL_DISPENSER",
  "RESET_ISSUANCE",
  "ASSET_CREATION",
  "DISPENSER_UPDATE",
  "NEW_FAIRMINT",
  "NEW_FAIRMINTER",
  "OPEN_ORDER",
  "ORDER_MATCH",
  "ORDER_UPDATE",
  "ORDER_FILLED",
  "CANCEL_ORDER",
  "ORDER_EXPIRATION",
  "ATTACH_TO_UTXO",
  "DETACH_FROM_UTXO",
  "UTXO_MOVE",
  "ASSET_DESTRUCTION",
  "ASSET_DIVIDEND",
  "SWEEP",
  "BURN"
];

abstract class XCPActivityEvent extends Equatable {
  const XCPActivityEvent();
  @override
  List<Object> get props => [];
}

class StartPolling extends XCPActivityEvent {
  final Duration interval;
  const StartPolling({required this.interval});
}

class StopPolling extends XCPActivityEvent {
  const StopPolling();
}

class Load extends XCPActivityEvent {
  const Load();
}

class LoadMore extends XCPActivityEvent {
  const LoadMore();
}

class LoadQuiet extends XCPActivityEvent {
  const LoadQuiet();
}

class XcpFeedStateReplete extends Equatable {
  final Cursor? cursor;
  final String? newestSeenHash;
  final List<Event> events;
  final int blockHeight;
  final int newEventCount;
  final bool endReached;

  const XcpFeedStateReplete({
    required this.cursor,
    required this.events,
    required this.blockHeight,
    this.newestSeenHash,
    this.newEventCount = 0,
    this.endReached = false,
  });

  @override
  List<Object?> get props =>
      [cursor, newestSeenHash, events, blockHeight, newEventCount, endReached];

  List<ActivityFeedItem> get items => events
      .map((event) => ActivityFeedItem(
            id: event.hashCode.toString(),
            hash: event.txHash,
            event: event,
            confirmations: event.blockIndex == null
                ? null
                : blockHeight - event.blockIndex! + 1,
          ))
      .toList();

  XcpFeedStateReplete copyWith({
    final int? newTransactionCount,
    final bool? endReached,
  }) =>
      XcpFeedStateReplete(
        cursor: cursor,
        events: events,
        blockHeight: blockHeight,
        newEventCount: newTransactionCount ?? this.newEventCount,
        endReached: endReached ?? this.endReached,
      );
}

extension XcpFeedStateRepleteX on XcpFeedStateReplete {
  XcpFeedStateReplete copyWith({
    Cursor? cursor,
    List<Event>? events,
    int? blockHeight,
  }) {
    return XcpFeedStateReplete(
      cursor: cursor ?? this.cursor,
      events: events ?? this.events,
      blockHeight: blockHeight ?? this.blockHeight,
    );
  }
}

class XcpActivityState extends Equatable {
  final RemoteData<XcpFeedStateReplete> remoteState;

  const XcpActivityState({required this.remoteState});

  @override
  List<Object> get props => [
        remoteState,
      ];

  XcpActivityState copyWith({
    RemoteData<XcpFeedStateReplete>? remoteState,
  }) {
    return XcpActivityState(
      remoteState: remoteState ?? this.remoteState,
    );
  }
}

class XcpActivityBloc extends Bloc<XCPActivityEvent, XcpActivityState> {
  final HttpConfig httpConfig;
  Logger? logger;
  Timer? timer;
  String address;
  final EventsRepository _eventsRepository;
  final BitcoinRepository _bitcoinRepository;

  XcpActivityBloc({
    required this.httpConfig,
    this.logger,
    required this.address,
    EventsRepository? eventsRepository,
    BitcoinRepository? bitcoinRepository,
  })  : _eventsRepository = eventsRepository ?? GetIt.I<EventsRepository>(),
        _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        super(const XcpActivityState(remoteState: Initial())) {
    on<StartPolling>(_onStartPolling);
    on<StopPolling>(_onStopPolling);
    on<Load>(_onLoad);
    on<LoadMore>(_onLoadMore);
    on<LoadQuiet>(_onLoadQuiet);
  }

  void _onLoadMore(LoadMore event, Emitter<XcpActivityState> emit) async {
    // if state isn't success do nothing

    if (!state.remoteState.isSuccess) return;
    final replete = state.remoteState.getOrNull()!;
    if (replete.cursor == null) return;
    emit(state.copyWith(remoteState: Refreshing(replete)));

    final task = TaskEither<String, XcpFeedStateReplete>.Do(($) async {
      final confirmedTask = _eventsRepository.getByAddressesVerboseT(
          httpConfig: httpConfig,
          cursor: replete.cursor,
          addresses: [address],
          whitelist: DEFAULT_WHITELIST,
          onError: (e, s) => "Error fetching XCP events at $address");

      final blockHeightTask = _bitcoinRepository.getBlockHeightT(
          httpConfig: httpConfig,
          onError: (_) => "error fetching block height");

      final [confirmedTxs as (List<Event>, Cursor?, int), blockHeight as int] =
          await $(TaskEither.sequenceList([confirmedTask, blockHeightTask]));

      return XcpFeedStateReplete(
          cursor: confirmedTxs.$2,
          blockHeight: blockHeight,
          events: [
            ...replete.events,
            ...confirmedTxs.$1
          ], // append new txs to existing ones
          endReached: confirmedTxs.$2 == null);
    });

    final result = await task.run();

    final nextState = result.fold((error) {
      return state.copyWith(
        remoteState: Failure(error),
      );
    }, (replete) {
      return state.copyWith(remoteState: Success(replete));
    });

    emit(nextState);
  }

  void _onStartPolling(StartPolling event, Emitter<XcpActivityState> emit) {
    timer?.cancel();
    timer = Timer.periodic(event.interval, (_) {
      add(const LoadQuiet());
    });
    add(const Load());
  }

  void _onStopPolling(StopPolling event, Emitter<XcpActivityState> emit) {
    timer?.cancel();
    timer = null;
  }

  void _onLoad(Load event, Emitter<XcpActivityState> emit) async {
    if (state.remoteState.isLoading) return;

    RemoteData<XcpFeedStateReplete> nextState = state.remoteState.fold3(
      onNone: () => const Loading(),
      onReplete: (value) => Refreshing(value),
      onFailure: (error) => Loading(),
    );

    emit(state.copyWith(remoteState: nextState));

    final task = TaskEither<String, dynamic>.Do(($) async {
      final mempoolTask =
          _eventsRepository.getAllMempoolVerboseEventsForAddressesT(
              httpConfig,
              [address],
              DEFAULT_WHITELIST,
              (_, __) => "error fetching mempool events for $address");

      final confirmedTask = _eventsRepository.getByAddressesVerboseT(
          httpConfig: httpConfig,
          addresses: [address],
          whitelist: DEFAULT_WHITELIST,
          onError: (e, s) => "Error fetching XCP events at $address");

      final blockHeightTask = _bitcoinRepository.getBlockHeightT(
          httpConfig: httpConfig,
          onError: (_) => "error fetching block height");

      final [
        mempoolTxs as List<Event>,
        confirmedTxs as (List<Event>, Cursor?, int),
        blockHeight as int
      ] = await $(TaskEither.sequenceList(
          [mempoolTask, confirmedTask, blockHeightTask]));

      return XcpFeedStateReplete(
          newestSeenHash:
              confirmedTxs.$1.isNotEmpty ? confirmedTxs.$1.first.txHash : null,
          cursor: confirmedTxs.$2,
          blockHeight: blockHeight,
          events: [...mempoolTxs, ...confirmedTxs.$1]);
    });

    final result = await task.run();

    XcpActivityState nextState_ = result.fold(
      (error) {
        return state.copyWith(
          remoteState: Failure(error),
        );
      },
      (replete) {
        return state.copyWith(remoteState: Success(replete));
      },
    );

    emit(nextState_);
  }

  void _onLoadQuiet(LoadQuiet event, Emitter<XcpActivityState> emit) async {
    if (state.remoteState.isLoading) return;
    if (state.remoteState.isRefreshing) return;
    if (!state.remoteState.isSuccess) {
      add(const Load());
      return;
    }

    final replete = state.remoteState.getOrNull()!;

    late TaskEither<String, int> newEventCountTask;

    if (replete.newestSeenHash == null) {
      newEventCountTask = _eventsRepository
          .getByAddressesVerboseT(
              httpConfig: httpConfig,
              addresses: [address],
              whitelist: DEFAULT_WHITELIST,
              onError: (e, s) => "Error fetching XCP events at $address")
          .map((result) => result.$3 ?? 0);
    } else {
      // don't bother to page through confirmed here
      newEventCountTask = TaskEither.sequenceList([
        _eventsRepository.getAllMempoolVerboseEventsForAddressesT(
            httpConfig,
            [address],
            DEFAULT_WHITELIST,
            (_, __) => "error fetching mempool events for $address"),
        _eventsRepository.getByAddressesVerboseT(
            httpConfig: httpConfig,
            addresses: [address],
            whitelist: DEFAULT_WHITELIST,
            onError: (e, s) => "Error fetching XCP events at $address")
      ]).map((results) {
        //
        final newMempoolTxs = results[0] as List<Event>;
        final confirmedTxs = results[1] as (List<Event>, Cursor?, int);

        final newEvents = [];

        for (var tx in [...newMempoolTxs, ...confirmedTxs.$1]) {
          if (tx.txHash == replete.newestSeenHash) {
            break;
          }
          newEvents.add(tx);
        }

        print("original count ${newEvents.length}");

        final oldMempoolTxs = replete.events
            .where((tx) => !tx.isConfirmed)
            .toList(growable: false);

        // reconcile mempooltxs

        for (var tx in newMempoolTxs) {
          if (!oldMempoolTxs.any((oldTx) => oldTx.txHash == tx.txHash)) {
            newEvents.add(tx);
          }
        }

        return newEvents.length;
      });
    }

    Either<String, int> newCounterpartyEventCount =
        await newEventCountTask.run();

    final nextState = newCounterpartyEventCount.fold((error) {
      return state.copyWith(
        remoteState: Failure(error),
      );
    }, (count) {
      return state.copyWith(
          remoteState: Success(state.remoteState
              .getOrNull()!
              .copyWith(newTransactionCount: count)));
    });
    emit(nextState);

    // new transactions are all those to last hash
  }
}
