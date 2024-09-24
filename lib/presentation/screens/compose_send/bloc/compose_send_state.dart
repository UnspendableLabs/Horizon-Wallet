import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/address.dart';

part 'compose_send_state.freezed.dart';

sealed class ComposeSendFee {}

class Fast extends ComposeSendFee {}

class Medium extends ComposeSendFee {}

class Slow extends ComposeSendFee {}

@freezed
class ComposeSendState with _$ComposeSendState {
  const factory ComposeSendState({
    @Default(BalancesState.initial()) balancesState,
    @Default(FeeState.initial()) feeState,
    @Default(MaxValueState.initial()) maxValue,
    @Default(false) bool sendMax,
    required FeeOption feeOption,
    required SubmitState submitState,
    Address? source, // TODO: smell
    String? destination,
    String? asset,
    @Default("") String quantity,
    String? composeSendError,
  }) = _ComposeSendState;
}

@freezed
class MaxValueState with _$MaxValueState {
  const factory MaxValueState.initial() = _MaxValueInital;
  const factory MaxValueState.loading() = _MaxValueLoading;
  const factory MaxValueState.success(int maxValue) = _MaxValueSuccess;
  const factory MaxValueState.error(String error) = _MaxValueError;
}

@freezed
class BalancesState with _$BalancesState {
  const factory BalancesState.initial() = _BalanceInital;
  const factory BalancesState.loading() = _BalanceLoading;
  const factory BalancesState.success(List<Balance> balances) = _BalanceSuccess;
  const factory BalancesState.error(String error) = _BalanceError;
}

@freezed
class FeeState with _$FeeState {
  const factory FeeState.initial() = _FeeInitial;
  const factory FeeState.loading() = _FeeLoading;
  const factory FeeState.success(FeeEstimates feeEstimates) = _FeeSuccess;
  const factory FeeState.error(String error) = _FeeError;
}

sealed class SubmitState {
  const SubmitState();
}

class SubmitInitial extends SubmitState {
  final bool loading;
  final String? error;

  const SubmitInitial({
    this.loading = false,
    this.error,
  });
}

class SubmitComposing extends SubmitState {
  final SubmitStateComposingSend submitStateComposingSend;
  const SubmitComposing(this.submitStateComposingSend);
}

class SubmitFinalizing extends SubmitState {
  final ComposeSend composeSend;
  final int fee;
  final bool loading;
  final String? error;

  SubmitFinalizing(
      {required this.loading,
      required this.error,
      required this.composeSend,
      required this.fee});

  SubmitFinalizing copyWith({
    required ComposeSend composeSend,
    required int fee,
    required bool loading,
    required String? error,
  }) {
    return SubmitFinalizing(
      composeSend: composeSend,
      fee: fee,
      loading: loading,
      error: error,
    );
  }
}

class SubmitSuccess extends SubmitState {
  final String transactionHex;
  final String sourceAddress;
  const SubmitSuccess(
      {required this.transactionHex, required this.sourceAddress});
}

class SubmitError extends SubmitState {
  final String error;
  const SubmitError(this.error);
}

class SubmitStateComposingSend {
  final ComposeSend composeSend;
  final int virtualSize;
  final int fee;
  final int feeRate;
  SubmitStateComposingSend({
    required this.composeSend,
    required this.virtualSize,
    required this.fee,
    required this.feeRate,
  });
}
