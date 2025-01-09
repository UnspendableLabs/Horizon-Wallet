import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'compose_rbf_state.dart';
import 'compose_rbf_event.dart';
import "package:fpdart/fpdart.dart";
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

T unwrapOrThrow<L extends Object, T>(Either<L, T> either) {
  return either.fold(
    (l) => throw l,
    (r) => r,
  );
}

class ComposeRBFBloc extends ComposeBaseBloc<ReplaceByFeeState> {
  final String txHash;
  final String currentAddress;
  final BalanceRepository balanceRepository;
  final BitcoinRepository bitcoinRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;

  ComposeRBFBloc(
      {required this.currentAddress,
      required this.txHash,
      required this.balanceRepository,
      required this.bitcoinRepository,
      required this.getFeeEstimatesUseCase})
      : super(ReplaceByFeeState.initial(txHash: txHash), 
      composePage: "compose_rbf"
      ) {}

  @override
  Future<void> onFetchFormData(
      FetchFormData event, Emitter<ReplaceByFeeState> emit) async {
    emit(state.copyWith(
      balancesState: const BalancesState.loading(),
      submitState: const SubmitInitial(),
      originalTxState: const OriginalTxState.loading(),
    ));

    List<Balance> balances;
    FeeEstimates feeEstimates;
    BitcoinTx originalTx;

    try {
      balances =
          await balanceRepository.getBalancesForAddress(currentAddress, true);
      print("balances $balances");
    } catch (e) {
      emit(state.copyWith(balancesState: BalancesState.error(e.toString())));
      return;
    }

    try {
      feeEstimates = await getFeeEstimatesUseCase.call();
    } catch (e) {
      emit(state.copyWith(feeState: FeeState.error(e.toString())));
      return;
    }

    try {
      print("txHash $txHash");
      originalTx =
          unwrapOrThrow(await bitcoinRepository.getTransaction(txHash));
      print("og $originalTx");
    } catch (e) {
      emit(
          state.copyWith(originalTxState: OriginalTxState.error(e.toString())));
      return;
    }

    emit(state.copyWith(
      originalTxState: OriginalTxState.success(originalTx),
      balancesState: BalancesState.success([balances.first]),
      feeState: FeeState.success(feeEstimates),
    ));
  }

  @override
  void onChangeFeeOption(
      ChangeFeeOption event, Emitter<ReplaceByFeeState> emit) {}

  @override
  void onComposeTransaction(
      ComposeTransactionEvent event, Emitter<ReplaceByFeeState> emit) {}

  @override
  void onFinalizeTransaction(
      FinalizeTransactionEvent event, Emitter<ReplaceByFeeState> emit) {}

  @override
  void onSignAndBroadcastTransaction(SignAndBroadcastTransactionEvent event,
      Emitter<ReplaceByFeeState> emit) {}
}
