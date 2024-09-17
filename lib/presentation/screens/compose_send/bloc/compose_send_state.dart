import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset.dart';

part 'compose_send_state.freezed.dart';

sealed class ComposeSendFee {}

class Fast extends ComposeSendFee {}

class Medium extends ComposeSendFee {}

class Slow extends ComposeSendFee {}

@freezed
class ComposeSendState with _$ComposeSendState {
  const factory ComposeSendState({
    @Default(BalancesState.initial()) balancesState,
    @Default(SubmitState.initial()) submitState,
    @Default(FeeState.initial()) feeState,
    @Default(MaxValueState.initial()) maxValue,
    @Default(false) bool sendMax,
    required FeeOption feeOption,
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

@freezed
class SubmitState with _$SubmitState {
  const factory SubmitState.initial() = _SubmitInitial;
  const factory SubmitState.loading() = _SubmitLoading;
  const factory SubmitState.composing(
      SubmitStateComposingSend submitStateComposingSend) = _SubmitComposing;
  const factory SubmitState.finalizing(
      SubmitStateFinalizing submitStateFinalizing) = _SubmitFinalizing;
  const factory SubmitState.success(
      String transactionHex, String sourceAddress) = _SubmitSuccess;
  const factory SubmitState.error(String error) = _SubmitError;
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

class SubmitStateFinalizing {
  final ComposeSend composeSend;
  final int fee;
  SubmitStateFinalizing({required this.composeSend, required this.fee});
}
