import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:horizon/domain/entities/fee_option.dart';

import 'package:horizon/domain/entities/bitcoin_tx.dart';
import "package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart";

part 'compose_rbf_state.freezed.dart';

@freezed
class OriginalTxState with _$OriginalTxState {
  const factory OriginalTxState.initial() = _OriginalTxInitial;
  const factory OriginalTxState.loading() = _OriginalTxLoading;
  const factory OriginalTxState.success(BitcoinTx transaction) =
      _OriginalTxSuccess;
  const factory OriginalTxState.error(String error) = _OriginalTxError;
}

@freezed
class ReplaceByFeeState with _$ReplaceByFeeState, ComposeStateBase {
  const ReplaceByFeeState._(); 

  const factory ReplaceByFeeState({
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,
    required String txHash,
    required OriginalTxState originalTxState,
  }) = _ReplaceByFeeState;

  factory ReplaceByFeeState.initial({
    required String txHash,
  }) =>
      ReplaceByFeeState(
        txHash: txHash,
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const SubmitInitial(),
        originalTxState: const OriginalTxState.initial(),
      );
}
