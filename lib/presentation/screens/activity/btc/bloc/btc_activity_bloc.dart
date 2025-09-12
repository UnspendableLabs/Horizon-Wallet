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

abstract class BTCFeedEvent extends Equatable {
  const BTCFeedEvent();
  @override
  List<Object> get props => [];
}

class StartPolling extends BTCFeedEvent {
  final Duration interval;
  const StartPolling({required this.interval});
}

class StopPolling extends BTCFeedEvent {
  const StopPolling();
}

class Load extends BTCFeedEvent {
  const Load();
}

class LoadMore extends BTCFeedEvent {
  const LoadMore();
}

class LoadQuiet extends BTCFeedEvent {
  const LoadQuiet();
}

class BtcFeedStateReplete extends Equatable {
  final String? lastHash;
  final List<BitcoinTx> transactions;
  final int blockHeight;
  final int newTransactionCount;

  const BtcFeedStateReplete({
    required this.lastHash,
    required this.transactions,
    required this.blockHeight,
    this.newTransactionCount = 0,
  });

  @override
  List<Object> get props => [];

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
  }) =>
      BtcFeedStateReplete(
        lastHash: lastHash,
        transactions: transactions,
        blockHeight: blockHeight,
        newTransactionCount: newTransactionCount ?? this.newTransactionCount,
      );
}

extension BtcFeedStateRepleteX on BtcFeedStateReplete {
  BtcFeedStateReplete copyWith({
    String? lastHash,
    List<BitcoinTx>? transactions,
    int? blockHeight,
  }) {
    return BtcFeedStateReplete(
      lastHash: lastHash ?? this.lastHash,
      transactions: transactions ?? this.transactions,
      blockHeight: blockHeight ?? this.blockHeight,
    );
  }
}

class BtcFeedState extends Equatable {
  final RemoteData<BtcFeedStateReplete> remoteState;

  const BtcFeedState({required this.remoteState});

  @override
  List<Object> get props => [];

  BtcFeedState copyWith({
    RemoteData<BtcFeedStateReplete>? remoteState,
    bool? isCancelled,
  }) {
    return BtcFeedState(
      remoteState: remoteState ?? this.remoteState,
    );
  }
}

class BtcActivityBloc extends Bloc<BTCFeedEvent, BtcFeedState> {
  final HttpConfig httpConfig;
  Logger logger;
  Timer? timer;
  String address;
  BitcoinRepository _bitcoinRepository;

  BtcActivityBloc({
    required this.httpConfig,
    required this.logger,
    required this.address,
    BitcoinRepository? bitcoinRepository,
  })  : _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        super(const BtcFeedState(remoteState: Initial())) {
    on<StartPolling>(_onStartPolling);
    on<StopPolling>(_onStopPolling);
    on<Load>(_onLoad);
    // on<LoadMore>(_onLoadMore);
    on<LoadQuiet>(_onLoadQuiet);
  }

  void _onStartPolling(StartPolling event, Emitter<BtcFeedState> emit) {
    timer?.cancel();
    timer = Timer.periodic(event.interval, (_) {
      add(const LoadQuiet());
    });
    add(const Load());
  }

  void _onStopPolling(StopPolling event, Emitter<BtcFeedState> emit) {
    timer?.cancel();
    timer = null;
  }

  void _onLoad(Load event, Emitter<BtcFeedState> emit) async {
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
          lastHash: confirmedTxs.isNotEmpty ? confirmedTxs.last.txid : null,
          blockHeight: blockHeight,
          transactions: [...mempoolTxs, ...confirmedTxs]);
    });

    final result = await task.run();

    BtcFeedState nextState_ = result.fold(
      (error) {
        logger.error("Error loading BTC feed: $error");
        return state.copyWith(
          remoteState: Failure(error),
        );
      },
      (replete) => state.copyWith(
        remoteState: Success(replete),
      ),
    );

    emit(nextState_);
  }

  void _onLoadQuiet(LoadQuiet event, Emitter<BtcFeedState> emit) async {
    if (state.remoteState.isLoading) return;
    if (state.remoteState.isRefreshing) return;
    if (!state.remoteState.isSuccess) {
      add(const Load());
      return;
    }

    TaskEither<String, BtcFeedStateReplete> firstPage =
        TaskEither<String, BtcFeedStateReplete>.Do(($) async {
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
          lastHash: confirmedTxs.isNotEmpty ? confirmedTxs.last.txid : null,
          blockHeight: blockHeight,
          transactions: [...mempoolTxs, ...confirmedTxs]);
    });

    final firstPageResult = await firstPage.run();
    String? lastHash = state.remoteState.getOrNull()?.lastHash;

    final nextState = firstPageResult.fold((error) {
      logger.error("Error loading BTC feed: $error");
      return state.copyWith(
        remoteState: Failure(error),
      );
    }, (replete) {
      // new transaction count are all those up until lastd hash
      List<BitcoinTx> newTxs = [];
      for (final tx in replete.transactions) {
        if (tx.txid == lastHash) {
          break;
        }
        newTxs.add(tx);
      }

      return state.copyWith(
          remoteState: Success(state.remoteState
              .getOrNull()!
              .copyWith(newTransactionCount: newTxs.length)));
    });

    emit(nextState);

    // new transactions are all those to last hash
  }
}
