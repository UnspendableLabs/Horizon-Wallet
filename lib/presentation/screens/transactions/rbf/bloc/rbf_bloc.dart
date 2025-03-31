import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/fn.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/fee_option.dart' as fee_option;
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_bloc.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/transactions/rbf/bloc/rbf_event.dart';

class RBFData {
  final BitcoinTx tx;
  final String hex;
  final int adjustedSize;

  RBFData({required this.tx, required this.hex, required this.adjustedSize});
}

class RBFComposeData {
  final MakeRBFResponse makeRBFResponse;
  final num oldFee;
  final String txid;

  RBFComposeData(
      {required this.makeRBFResponse,
      required this.oldFee,
      required this.txid});
}

class RBFBloc
    extends Bloc<TransactionEvent, TransactionState<RBFData, RBFComposeData>> {
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final BitcoinRepository bitcoinRepository;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final AnalyticsService analyticsService;
  final TransactionService transactionService;
  final Logger logger;
  final SettingsRepository settingsRepository;

  RBFBloc({
    required this.getFeeEstimatesUseCase,
    required this.bitcoinRepository,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.analyticsService,
    required this.logger,
    required this.settingsRepository,
    required this.transactionService,
  }) : super(TransactionState<RBFData, RBFComposeData>(
          formState: TransactionFormState<RBFData>(
            balancesState: const BalancesState.initial(),
            feeState: const FeeState.initial(),
            dataState: const TransactionDataState.initial(),
            feeOption: fee_option.Medium(),
          ),
          composeState: const ComposeState.initial(),
          broadcastState: const BroadcastState.initial(),
        )) {
    on<RBFDependenciesRequested>(_onDependenciesRequested);
    on<RBFTransactionComposed>(_onTransactionComposed);
    on<RBFTransactionBroadcasted>(_onTransactionBroadcasted);
    on<FeeOptionSelected>(_onFeeOptionSelected);
  }

  void _onDependenciesRequested(
    RBFDependenciesRequested event,
    Emitter<TransactionState<RBFData, RBFComposeData>> emit,
  ) async {
    emit(state.copyWith(
      formState: state.formState.copyWith(
        balancesState: const BalancesState.loading(),
        feeState: const FeeState.loading(),
        dataState: const TransactionDataState.loading(),
      ),
    ));

    try {
      final feeEstimates = await getFeeEstimatesUseCase.call();

      BitcoinTx bitcoinTransaction =
          unwrapOrThrow(await bitcoinRepository.getTransaction(event.txHash));

      String bitcoinTransactionHex = unwrapOrThrow(
          await bitcoinRepository.getTransactionHex(event.txHash));

      final virtualSize =
          transactionService.getVirtualSize(bitcoinTransactionHex);

      final sigOps = transactionService.countSigOps(
        rawtransaction: bitcoinTransactionHex,
      );

      final adjustedVirtualSize = max(virtualSize, sigOps * 5);

      emit(state.copyWith(
          formState: state.formState.copyWith(
              balancesState: BalancesState.success(MultiAddressBalance.empty),
              feeState: FeeState.success(feeEstimates),
              dataState: TransactionDataState.success(RBFData(
                  tx: bitcoinTransaction,
                  hex: bitcoinTransactionHex,
                  adjustedSize: adjustedVirtualSize)))));
    } catch (e) {
      emit(state.copyWith(
        formState: state.formState.copyWith(
          dataState: TransactionDataState.error(e.toString()),
        ),
      ));
    }
  }

  void _onTransactionComposed(
    RBFTransactionComposed event,
    Emitter<TransactionState<RBFData, RBFComposeData>> emit,
  ) async {
    final source = event.sourceAddress;
    try {
      final newFeeRate = getFeeRate(state);
      num newFee = newFeeRate * event.params.adjustedVirtualSize;

      MakeRBFResponse rbfResponse = await transactionService.makeRBF(
        source: source,
        txHex: event.params.hex,
        oldFee: event.params.tx.fee,
        newFee: newFee,
      );

      final rbfComposeData = RBFComposeData(
        makeRBFResponse: rbfResponse,
        oldFee: event.params.tx.fee,
        txid: event.params.tx.txid,
      );

      emit(state.copyWith(composeState: ComposeStateSuccess(rbfComposeData)));
    } on TransactionServiceException catch (e) {
      emit(state.copyWith(
        composeState: ComposeStateError(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        composeState: ComposeStateError(e.toString()),
      ));
    }
    // emit(state.copyWith(composeState: const ComposeStateLoading()));
    // if (event.sourceAddress.isEmpty) {
    //   emit(state.copyWith(
    //     composeState: const ComposeStateError('Source address is required'),
    //   ));
    //   return;
    // }

    // try {
    //   final feeRate = getFeeRate(state);
    //   final source = event.sourceAddress;
    //   final destination = event.destinationAddress;
    //   final asset = event.asset;
    //   final quantity = event.quantity;

    //   final composeResponse = await composeTransactionUseCase
    //       .call<ComposeSendParams, ComposeSendResponse>(
    //     feeRate: feeRate,
    //     source: source,
    //     params: ComposeSendParams(
    //       source: source,
    //       destination: destination,
    //       asset: asset,
    //       quantity: quantity,
    //     ),
    //     composeFn: composeRepository.composeSendVerbose,
    //   );

    //   emit(state.copyWith(
    //     composeState: ComposeStateSuccess(composeResponse),
    //   ));
    // } on ComposeTransactionException catch (e) {
    //   emit(state.copyWith(
    //     composeState: ComposeStateError(e.message),
    //   ));
    // } catch (e) {
    //   emit(state.copyWith(
    //     composeState: ComposeStateError(e is ComposeTransactionException
    //         ? e.message
    //         : 'An unexpected error occurred: ${e.toString()}'),
    //   ));
    // }
  }

  void _onTransactionBroadcasted(
    RBFTransactionBroadcasted event,
    Emitter<TransactionState<RBFData, RBFComposeData>> emit,
  ) async {
    // try {
    //   final requirePassword =
    //       settingsRepository.requirePasswordForCryptoOperations;

    //   emit(state.copyWith(broadcastState: const BroadcastState.loading()));

    //   final composeData = state.getComposeDataOrThrow();

    //   await signAndBroadcastTransactionUseCase.call(
    //       decryptionStrategy:
    //           requirePassword ? Password(event.password!) : InMemoryKey(),
    //       source: composeData.params.source,
    //       rawtransaction: composeData.rawtransaction,
    //       onSuccess: (txHex, txHash) async {
    //         await writelocalTransactionUseCase.call(txHex, txHash);

    //         logger.info('send broadcasted txHash: $txHash');
    //         analyticsService.trackAnonymousEvent('broadcast_tx_send',
    //             properties: {'distinct_id': uuid.v4()});

    //         emit(state.copyWith(
    //             broadcastState: BroadcastState.success(
    //                 BroadcastStateSuccess(txHex: txHex, txHash: txHash))));
    //       },
    //       onError: (msg) {
    //         emit(state.copyWith(broadcastState: BroadcastState.error(msg)));
    //       });
    // } catch (e) {
    //   emit(state.copyWith(broadcastState: BroadcastState.error(e.toString())));
    // }
  }

  void _onFeeOptionSelected(
    FeeOptionSelected event,
    Emitter<TransactionState<RBFData, RBFComposeData>> emit,
  ) {
    emit(state.copyWith(
      formState: state.formState.copyWith(
        feeOption: event.feeOption,
      ),
    ));
  }
}
