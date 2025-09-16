import "package:equatable/equatable.dart";
import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';
import "package:horizon/domain/entities/cursor.dart";
import 'package:horizon/domain/entities/remote_data.dart';
import "package:horizon/domain/entities/activity_feed_item.dart";
import "package:horizon/domain/entities/bitcoin_tx.dart";
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/js/bip39.dart';

abstract class BTCActivityEvent extends Equatable {
  const BTCActivityEvent();
  @override
  List<Object> get props => [];
}

class StartPolling extends BTCActivityEvent {
  final Duration interval;
  const StartPolling({required this.interval});
}

class StopPolling extends BTCActivityEvent {
  const StopPolling();
}

class Load extends BTCActivityEvent {
  const Load();
}

class LoadMore extends BTCActivityEvent {
  const LoadMore();
}

class LoadQuiet extends BTCActivityEvent {
  const LoadQuiet();
}

class BtcFeedStateReplete extends Equatable {
  final String? lastHash;
  final String? newestSeenHash;
  final List<BitcoinTx> transactions;
  final int blockHeight;
  final int newTransactionCount;
  final bool endReached;

  const BtcFeedStateReplete({
    required this.lastHash,
    required this.newestSeenHash,
    required this.transactions,
    required this.blockHeight,
    this.newTransactionCount = 0,
    this.endReached = false,
  });

  @override
  List<Object?> get props => [
        lastHash,
        newestSeenHash,
        transactions,
        blockHeight,
        newTransactionCount,
        endReached,
      ];

  List<ActivityFeedItem> get items => transactions
      .map((tx) => ActivityFeedItem(
            id: tx.txid,
            hash: tx.txid,
            bitcoinTx: tx,
            confirmations: tx.status.confirmed
                ? blockHeight - (tx.status.blockHeight!) + 1
                : null,
          ))
      .toList();

  BtcFeedStateReplete copyWith({
    final int? newTransactionCount,
    final bool? endReached,
    final String? newestSeenHash,
    final List<BitcoinTx>? transactions,
    final int? blockHeight,
  }) =>
      BtcFeedStateReplete(
        lastHash: lastHash,
        transactions: transactions ?? this.transactions,
        blockHeight: blockHeight ?? this.blockHeight,
        newTransactionCount: newTransactionCount ?? this.newTransactionCount,
        endReached: endReached ?? this.endReached,
        newestSeenHash: newestSeenHash ?? this.newestSeenHash,
      );
}

class BtcActivityState extends Equatable {
  final RemoteData<BtcFeedStateReplete> remoteState;

  const BtcActivityState({required this.remoteState});

  @override
  List<Object> get props => [
        remoteState,
      ];

  BtcActivityState copyWith({
    RemoteData<BtcFeedStateReplete>? remoteState,
  }) {
    return BtcActivityState(
      remoteState: remoteState ?? this.remoteState,
    );
  }
}

class BtcActivityBloc extends Bloc<BTCActivityEvent, BtcActivityState> {
  final HttpConfig httpConfig;
  Logger? logger;
  Timer? timer;
  String address;
  BitcoinRepository _bitcoinRepository;

  BtcActivityBloc({
    required this.httpConfig,
    this.logger,
    required this.address,
    BitcoinRepository? bitcoinRepository,
  })  : _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        super(const BtcActivityState(remoteState: Initial())) {
    on<StartPolling>(_onStartPolling);
    on<StopPolling>(_onStopPolling);
    on<Load>(_onLoad);
    on<LoadQuiet>(_onLoadQuiet);
    on<LoadMore>(_onLoadMore);
  }

  void _onLoadMore(LoadMore event, Emitter<BtcActivityState> emit) async {
    if (!state.remoteState.isSuccess) {
      return;
    }

    final replete = state.remoteState.getOrNull()!;
    if (replete.lastHash == null) {
      return;
    }

    emit(state.copyWith(remoteState: Refreshing(replete)));

    final lastHash = replete.lastHash!;

    final task = TaskEither<String, BtcFeedStateReplete>.Do(($) async {
      final confirmedTask =
          _bitcoinRepository.getConfirmedTransactionsPaginatedT(
              address: address,
              lastSeenTxid: lastHash,
              httpConfig: httpConfig,
              onError: (e) {
                return "error fetching confirmed tx";
              });

      final blockHeightTask = _bitcoinRepository.getBlockHeightT(
          httpConfig: httpConfig,
          onError: (e) {
            return "error fetching block height";
          });

      final [confirmedTxs as List<BitcoinTx>, blockHeight as int] =
          await $(TaskEither.sequenceList([confirmedTask, blockHeightTask]));

      return BtcFeedStateReplete(
        newestSeenHash: replete.newestSeenHash,
        lastHash: confirmedTxs.isNotEmpty ? confirmedTxs.last.txid : null,
        blockHeight: blockHeight,
        transactions: [...replete.transactions, ...confirmedTxs],
        endReached: confirmedTxs.isEmpty || confirmedTxs.last.txid == lastHash,
      );
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

  void _onStartPolling(StartPolling event, Emitter<BtcActivityState> emit) {
    // timer?.cancel();
    timer = Timer.periodic(event.interval, (_) {
      add(const LoadQuiet());
    });
    add(const Load());
  }

  void _onStopPolling(StopPolling event, Emitter<BtcActivityState> emit) {
    timer?.cancel();
    timer = null;
  }

  void _onLoad(Load event, Emitter<BtcActivityState> emit) async {
    if (state.remoteState.isLoading) return;

    RemoteData<BtcFeedStateReplete> nextState = state.remoteState.fold3(
      onNone: () => const Loading(),
      onReplete: (value) => Refreshing(value),
      onFailure: (error) => Loading(),
    );

    emit(state.copyWith(remoteState: nextState));

    final task = TaskEither<String, dynamic>.Do(($) async {
      final mempoolTask = _bitcoinRepository.getMempoolTransactionsT(
          addresses: [address],
          httpConfig: httpConfig,
          onError: (_) => "error fetching mempol tx");

      final confirmedTask =
          _bitcoinRepository.getConfirmedTransactionsPaginatedT(
              address: address,
              httpConfig: httpConfig,
              onError: (_) => "error fetching confirmed tx");

      final blockHeightTask = _bitcoinRepository.getBlockHeightT(
          httpConfig: httpConfig,
          onError: (_) => "error fetching block height");

      final [
        mempoolTxs as List<BitcoinTx>,
        confirmedTxs as List<BitcoinTx>,
        blockHeight as int
      ] = await $(TaskEither.sequenceList(
          [mempoolTask, confirmedTask, blockHeightTask]));

      return BtcFeedStateReplete(
          newestSeenHash: [...mempoolTxs, ...confirmedTxs].isNotEmpty
              ? [...mempoolTxs, ...confirmedTxs].first.txid
              : null,
          lastHash: confirmedTxs.isNotEmpty ? confirmedTxs.last.txid : null,
          blockHeight: blockHeight,
          transactions: [...mempoolTxs, ...confirmedTxs]);
    });

    final result = await task.run();

    BtcActivityState nextState_ = result.fold(
      (error) {
        return state.copyWith(
          remoteState: Failure(error),
        );
      },
      (replete) {
        return state.copyWith(remoteState: Success(replete));
      },
    );

    // CHAT somehow this state is not being emitted
    emit(nextState_);
  }

  void _onLoadQuiet(LoadQuiet event, Emitter<BtcActivityState> emit) async {
    if (state.remoteState.isLoading) {
      return;
    }
    if (state.remoteState.isRefreshing) {
      return;
    }
    if (!state.remoteState.isSuccess) {
      add(const Load());
      return;
    }

    final replete = state.remoteState.getOrNull()!;

    TaskEither<String, BtcFeedStateReplete> firstPage =
        TaskEither<String, BtcFeedStateReplete>.Do(($) async {
      final mempoolTask = _bitcoinRepository.getMempoolTransactionsT(
        addresses: [address],
        httpConfig: httpConfig,
        onError: (_) => "error fetching mempool tx",
      );

      final confirmedTask =
          _bitcoinRepository.getConfirmedTransactionsPaginatedT(
        address: address,
        httpConfig: httpConfig,
        onError: (_) => "error fetching confirmed tx",
      );

      final blockHeightTask = _bitcoinRepository.getBlockHeightT(
        httpConfig: httpConfig,
        onError: (_) => "error fetching block height",
      );

      final [
        mempoolTxs as List<BitcoinTx>,
        confirmedTxs as List<BitcoinTx>,
        blockHeight as int,
      ] = await $(TaskEither.sequenceList(
          [mempoolTask, confirmedTask, blockHeightTask]));

      return BtcFeedStateReplete(
        newestSeenHash: replete.newestSeenHash,
        lastHash: confirmedTxs.isNotEmpty ? confirmedTxs.last.txid : null,
        blockHeight: blockHeight,
        transactions: [...mempoolTxs, ...confirmedTxs],
      );
    });

    final firstPageResult = await firstPage.run();
    String? lastHash = state.remoteState.getOrNull()?.newestSeenHash;

    final nextState = firstPageResult.fold((error) {
      return state.copyWith(remoteState: Failure(error));
    }, (newReplete) {
      // new transaction count are all those up until last hash

      List<BitcoinTx> newTxs = [];
      for (final tx in newReplete.transactions) {
        if (tx.txid == lastHash) {
          break;
        }
        newTxs.add(tx);
      }

      // reconcile mempooltxs

      final newMempoolTxs = newReplete.transactions
          .where((tx) => !tx.status.confirmed)
          .toList(growable: false);

      final oldMempoolTxs = replete.transactions
          .where((tx) => !tx.status.confirmed)
          .toList(growable: false);

      // add new mempool txs that aren't already in old mempool txs
      for (var tx in newMempoolTxs) {
        if (!oldMempoolTxs.any((oldTx) => oldTx.txid == tx.txid)) {
          newTxs.add(tx);
        }
      }

      return state.copyWith(
        remoteState: Success(
          state.remoteState
              .getOrNull()!
              .copyWith(newTransactionCount: newTxs.length),
        ),
      );
    });

    emit(nextState);
  }
}
