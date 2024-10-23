import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/balance.dart';

part 'compose_base_state.freezed.dart';

/// Mixin containing common state properties shared between ComposeIssuanceState and ComposeSendState.
mixin ComposeStateBase {
  FeeState get feeState;
  BalancesState get balancesState;
  FeeOption get feeOption;
  SubmitState get submitState;
}

/// FeeState represents the state of fee estimation.
@freezed
class FeeState with _$FeeState {
  const factory FeeState.initial() = _FeeInitial;
  const factory FeeState.loading() = _FeeLoading;
  const factory FeeState.success(FeeEstimates feeEstimates) = _FeeSuccess;
  const factory FeeState.error(String error) = _FeeError;
}

extension FeeStateGetOrThrow on FeeState {
  FeeEstimates feeEstimatesOrThrow() {
    return maybeWhen(
      success: (feeEstimates) => feeEstimates,
      orElse: () => throw StateError('FeeState is not in a success state'),
    );
  }
}

/// BalancesState represents the state of fetching balances.
@freezed
class BalancesState with _$BalancesState {
  const factory BalancesState.initial() = _BalancesInitial;
  const factory BalancesState.loading() = _BalancesLoading;
  const factory BalancesState.success(List<Balance> balances) =
      _BalancesSuccess;
  const factory BalancesState.error(String error) = _BalancesError;
}

/// Abstract class for submit state, allows for different implementations.
@immutable
abstract class SubmitState {
  const SubmitState();
}

/// Initial state before submission begins.
class SubmitInitial extends SubmitState {
  final bool loading;
  final String? error;

  const SubmitInitial({this.loading = false, this.error});
}

/// State when submission is in progress.
class SubmitComposingTransaction<T, O extends Object?> extends SubmitState {
  final O? otherParams;
  final T composeTransaction;
  // final int virtualSize;
  final int fee;
  final int feeRate;
  final int virtualSize;
  final int adjustedVirtualSize;
  // final int virtualSize;
  // final int adjustedVirtualSize;
  const SubmitComposingTransaction({
    this.otherParams,
    required this.composeTransaction,
    // required this.virtualSize,
    required this.fee,
    required this.feeRate,
    required this.virtualSize,
    required this.adjustedVirtualSize,
    // required this.virtualSize,
    // required this.adjustedVirtualSize,
  });
}

/// State when submission is successful.
class SubmitSuccess extends SubmitState {
  final String transactionHex;
  final String sourceAddress;

  const SubmitSuccess({
    required this.transactionHex,
    required this.sourceAddress,
  });
}

/// State when submission fails.
class SubmitError extends SubmitState {
  final String error;

  const SubmitError(this.error);
}

class SubmitFinalizing<T> extends SubmitState {
  final T composeTransaction;
  final int fee;
  final bool loading;
  final String? error;

  const SubmitFinalizing(
      {required this.loading,
      required this.error,
      required this.composeTransaction,
      required this.fee});

  SubmitFinalizing copyWith({
    required T composeTransaction,
    required int fee,
    required bool loading,
    required String? error,
  }) {
    return SubmitFinalizing(
      composeTransaction: composeTransaction,
      fee: fee,
      loading: loading,
      error: error,
    );
  }
}
