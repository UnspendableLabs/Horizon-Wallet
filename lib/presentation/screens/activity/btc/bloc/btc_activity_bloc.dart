import "package:equatable/equatable.dart";
import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import "package:horizon/domain/entities/activity_feed_item.dart";
import "package:horizon/domain/entities/bitcoin_tx.dart";
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/usecases/esplora/get_block_height.dart';
import 'package:horizon/domain/usecases/esplora/get_confirmed_transactions_paginated.dart';
import 'package:horizon/domain/usecases/esplora/get_mempool_transactions.dart';

abstract class BTCActivityEvent extends Equatable {
  const BTCActivityEvent();
  @override
  List<Object> get props => [];
}

class Load extends BTCActivityEvent {
  const Load();
}

class LoadMore extends BTCActivityEvent {
  const LoadMore();
}

class BtcFeedStateReplete extends Equatable {
  final String? lastHash;
  final List<BitcoinTx> transactions;
  final int blockHeight;
  final bool endReached;
  final DateTime lastUpdatedAt;

  const BtcFeedStateReplete({
    required this.lastHash,
    required this.transactions,
    required this.blockHeight,
    required this.lastUpdatedAt,
    this.endReached = false,
  });

  @override
  List<Object?> get props => [
        lastHash,
        transactions,
        blockHeight,
        endReached,
        lastUpdatedAt,
      ];

  List<ActivityFeedItem> get items => transactions
      .filter((tx) => !tx.isCounterpartyTx(null))
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
    final bool? endReached,
    final List<BitcoinTx>? transactions,
    final int? blockHeight,
    final DateTime? lastUpdatedAt,
  }) =>
      BtcFeedStateReplete(
        lastHash: lastHash,
        transactions: transactions ?? this.transactions,
        blockHeight: blockHeight ?? this.blockHeight,
        endReached: endReached ?? this.endReached,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
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
  final GetBlockHeightEsploraUseCase _getBlockHeightEsploraUseCase;
  final GetConfirmedTransactionsPaginatedUseCase
      _getConfirmedTransactionsPaginatedUseCase;
  final GetMempoolTransactionsEsploraUseCase
      _getMempoolTransactionsEsploraUseCase;

  BtcActivityBloc({
    required this.httpConfig,
    this.logger,
    required this.address,
    BitcoinRepository? bitcoinRepository,
    GetBlockHeightEsploraUseCase? getBlockHeightEsploraUseCase,
    GetConfirmedTransactionsPaginatedUseCase?
        getConfirmedTransactionsPaginatedUseCase,
    GetMempoolTransactionsEsploraUseCase? getMempoolTransactionsEsploraUseCase,
  })  : _getBlockHeightEsploraUseCase = getBlockHeightEsploraUseCase ??
            GetIt.I<GetBlockHeightEsploraUseCase>(),
        _getConfirmedTransactionsPaginatedUseCase =
            getConfirmedTransactionsPaginatedUseCase ??
                GetIt.I<GetConfirmedTransactionsPaginatedUseCase>(),
        _getMempoolTransactionsEsploraUseCase =
            getMempoolTransactionsEsploraUseCase ??
                GetIt.I<GetMempoolTransactionsEsploraUseCase>(),
        super(const BtcActivityState(remoteState: Initial())) {
    on<Load>(_onLoad);
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
      final confirmedTask = _getConfirmedTransactionsPaginatedUseCase
          .call(GetConfirmedTransactionsPaginateParams(
        httpConfig: httpConfig,
        address: address,
        lastSeenTxid: lastHash,
      ));

      final blockHeightTask = _getBlockHeightEsploraUseCase
          .call(GetBlockHeightEsploraParams(httpConfig: httpConfig))
          .mapLeft((_) => "error fetching block height");

      final [confirmedTxs as List<BitcoinTx>, blockHeight as int] =
          await $(TaskEither.sequenceList([confirmedTask, blockHeightTask]));

      return BtcFeedStateReplete(
        lastHash: confirmedTxs.isNotEmpty ? confirmedTxs.last.txid : null,
        blockHeight: blockHeight,
        transactions: [...replete.transactions, ...confirmedTxs],
        endReached: confirmedTxs.isEmpty || confirmedTxs.last.txid == lastHash,
        // since we are just paging, don't change
        lastUpdatedAt: replete.lastUpdatedAt,
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

  void _onLoad(Load event, Emitter<BtcActivityState> emit) async {
    if (state.remoteState.isLoading) return;

    RemoteData<BtcFeedStateReplete> nextState = state.remoteState.fold3(
      onNone: () => const Loading(),
      onReplete: (value) => Refreshing(value),
      onFailure: (error) => Loading(),
    );

    emit(state.copyWith(remoteState: nextState));

    final task = TaskEither<String, dynamic>.Do(($) async {
      final mempoolTask = _getMempoolTransactionsEsploraUseCase
          .call(GetMempoolTransactionsEsploraParams(
            httpConfig: httpConfig,
            addresses: [address],
          ))
          .mapLeft((_) => "error fetching mempool tx");

      final confirmedTask = _getConfirmedTransactionsPaginatedUseCase
          .call(GetConfirmedTransactionsPaginateParams(
            address: address,
            httpConfig: httpConfig,
          ))
          .mapLeft((_) => "error fetching confirmed tx");

      final blockHeightTask = _getBlockHeightEsploraUseCase
          .call(GetBlockHeightEsploraParams(httpConfig: httpConfig))
          .mapLeft((_) => "error fetching block height");

      final [
        mempoolTxs as List<BitcoinTx>,
        confirmedTxs as List<BitcoinTx>,
        blockHeight as int
      ] = await $(TaskEither.sequenceList(
          [mempoolTask, confirmedTask, blockHeightTask]));

      return BtcFeedStateReplete(
          lastHash: confirmedTxs.isNotEmpty ? confirmedTxs.last.txid : null,
          blockHeight: blockHeight,
          transactions: [...mempoolTxs, ...confirmedTxs],
          lastUpdatedAt: DateTime.now());
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
}
