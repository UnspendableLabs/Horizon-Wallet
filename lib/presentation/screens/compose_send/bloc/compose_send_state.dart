import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_send.dart';

part 'compose_send_state.freezed.dart';

@freezed
class ComposeSendState with _$ComposeSendState {
  const factory ComposeSendState({
    @Default(BalancesState.initial()) balancesState,
    @Default(SubmitState.initial()) submitState,
  }) = _ComposeSendState;
}

@freezed
class BalancesState with _$BalancesState {
  const factory BalancesState.initial() = _BalanceInital;
  const factory BalancesState.loading() = _BalanceLoading;
  const factory BalancesState.success(List<Balance> balances) = _BalanceSuccess;
  const factory BalancesState.error(String error) = _BalanceError;
}

@freezed
class SubmitState with _$SubmitState {
  const factory SubmitState.initial() = _SubmitInitial;
  const factory SubmitState.loading() = _SubmitLoading;
  const factory SubmitState.composing(
      SubmitStateComposingSend submitStateComposingSend) = _SubmitComposing;
  const factory SubmitState.success(
      String transactionHex, String sourceAddress) = _SubmitSuccess;
  const factory SubmitState.error(String error) = _SubmitError;
}

class SubmitStateComposingSend {
  final ComposeSend composeSend;
  final int virtualSize;
  final Map<String, double> feeEstimates;
  final String confirmationTarget;
  SubmitStateComposingSend(
      {required this.composeSend,
      required this.virtualSize,
      required this.feeEstimates,
      required this.confirmationTarget});
}
