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
import 'package:horizon/domain/usecases/esplora/get_block_height.dart';

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

class Load extends XCPActivityEvent {
  const Load();
}

class LoadMore extends XCPActivityEvent {
  const LoadMore();
}

class XcpFeedStateReplete extends Equatable {
  final Cursor? cursor;
  final List<Event> events;
  final int blockHeight;
  final bool endReached;
  final DateTime lastUpdatedAt;

  const XcpFeedStateReplete({
    required this.cursor,
    required this.events,
    required this.blockHeight,
    this.endReached = false,
    required this.lastUpdatedAt,
  });

  @override
  List<Object?> get props =>
      [cursor, events, blockHeight, endReached, lastUpdatedAt];

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
    Cursor? cursor,
    List<Event>? events,
    bool? endReached,
    int? blockHeight,
    DateTime? lastUpdatedAt,
  }) =>
      XcpFeedStateReplete(
        cursor: cursor ?? this.cursor,
        events: events ?? this.events,
        blockHeight: blockHeight ?? this.blockHeight,
        endReached: endReached ?? this.endReached,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      );
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
  final GetBlockHeightEsploraUseCase _getBlockHeightEsploraUseCase;

  XcpActivityBloc({
    required this.httpConfig,
    this.logger,
    required this.address,
    EventsRepository? eventsRepository,
    GetBlockHeightEsploraUseCase? getBlockHeightEsploraUseCase,
  })  : _eventsRepository = eventsRepository ?? GetIt.I<EventsRepository>(),
        _getBlockHeightEsploraUseCase = getBlockHeightEsploraUseCase ??
            GetIt.I<GetBlockHeightEsploraUseCase>(),
        super(const XcpActivityState(remoteState: Initial())) {
    on<Load>(_onLoad);
    on<LoadMore>(_onLoadMore);
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
          limit: 40,
          addresses: [address],
          whitelist: DEFAULT_WHITELIST,
          onError: (e, s) => "Error fetching XCP events at $address");

      final blockHeightTask = _getBlockHeightEsploraUseCase
          .call(GetBlockHeightEsploraParams(httpConfig: httpConfig))
          .mapLeft((error) => "error fetching block height");

      final [confirmedTxs as (List<Event>, Cursor?, int), blockHeight as int] =
          await $(TaskEither.sequenceList([confirmedTask, blockHeightTask]));

      return XcpFeedStateReplete(
          cursor: confirmedTxs.$2,
          blockHeight: blockHeight,
          lastUpdatedAt: replete.lastUpdatedAt,
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
          limit: 40,
          onError: (e, s) => "Error fetching XCP events at $address");

      final blockHeightTask = _getBlockHeightEsploraUseCase
          .call(GetBlockHeightEsploraParams(httpConfig: httpConfig))
          .mapLeft((error) => "error fetching block height");

      final [
        mempoolTxs as List<Event>,
        confirmedTxs as (List<Event>, Cursor?, int),
        blockHeight as int
      ] = await $(TaskEither.sequenceList(
          [mempoolTask, confirmedTask, blockHeightTask]));

      return XcpFeedStateReplete(
          cursor: confirmedTxs.$2,
          lastUpdatedAt: DateTime.now(),
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
}
