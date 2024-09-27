// lib/presentation/screens/compose_issuance/bloc/compose_issuance_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';

import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/screens/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/screens/compose_base/bloc/submit_base_state.dart';

part 'compose_issuance_state.freezed.dart';

@freezed
class ComposeIssuanceState with _$ComposeIssuanceState, ComposeStateBase {
  const ComposeIssuanceState._(); // Added constructor for private use

  const factory ComposeIssuanceState({
    // Inherited properties
    required FeeState feeState,
    required BalancesState balancesState,
    required FeeOption feeOption,
    required SubmitState submitState,

    // Specific properties
    String? assetName,
    String? assetDescription,
    required String quantity,
  }) = _ComposeIssuanceState;

  factory ComposeIssuanceState.initial() => ComposeIssuanceState(
        feeState: const FeeState.initial(),
        balancesState: const BalancesState.initial(),
        feeOption: Medium(),
        submitState: const SubmitInitial(),
        quantity: '',
      );
}

class SubmitComposingIssuance extends SubmitState {
  final ComposeIssuanceVerbose composeIssuance;
  final int virtualSize;
  final int fee;
  final int feeRate;
  const SubmitComposingIssuance({
    required this.composeIssuance,
    required this.virtualSize,
    required this.fee,
    required this.feeRate,
  });
}

class SubmitFinalizing extends SubmitState {
  final ComposeIssuanceVerbose composeIssuance;
  final int fee;
  final bool loading;
  final String? error;

  const SubmitFinalizing(
      {required this.loading,
      required this.error,
      required this.composeIssuance,
      required this.fee});

  SubmitFinalizing copyWith({
    required ComposeIssuanceVerbose composeIssuance,
    required int fee,
    required bool loading,
    required String? error,
  }) {
    return SubmitFinalizing(
      composeIssuance: composeIssuance,
      fee: fee,
      loading: loading,
      error: error,
    );
  }
}
