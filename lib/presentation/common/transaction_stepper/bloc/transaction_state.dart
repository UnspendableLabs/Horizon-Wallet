import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';

part 'transaction_state.freezed.dart';

class TransactionState<T, R> {
  final BalancesState balancesState;
  final FeeState feeState;
  final FeeOption feeOption;
  final TransactionDataState<T> dataState;
  final ComposeState<R> composeState;
  final BroadcastState broadcastState;

  TransactionState({
    required this.balancesState,
    required this.feeState,
    required this.feeOption,
    required this.dataState,
    ComposeState<R>? composeState,
    BroadcastState? broadcastState,
  })  : composeState = composeState ?? const ComposeState.initial(),
        broadcastState = broadcastState ?? const BroadcastState.initial();

  String? get formLoadingError {
    final balancesError = balancesState.maybeWhen(
      error: (error) => error,
      orElse: () => null,
    );

    final feeError = feeState.maybeWhen(
      error: (error) => error,
      orElse: () => null,
    );

    final dataError = dataState.maybeWhen(
      error: (error) => error,
      orElse: () => null,
    );

    return balancesError ?? feeError ?? dataError;
  }

  bool get formLoading {
    return balancesState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        ) ||
        feeState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        ) ||
        dataState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
  }

  bool get formInitial {
    return balancesState.maybeWhen(
          initial: () => true,
          orElse: () => false,
        ) ||
        feeState.maybeWhen(
          initial: () => true,
          orElse: () => false,
        ) ||
        dataState.maybeWhen(
          initial: () => true,
          orElse: () => false,
        );
  }

  MultiAddressBalance getBalancesOrThrow() {
    return balancesState.maybeWhen(
      success: (balances) => balances,
      orElse: () => throw StateError('BalancesState is not in a success state'),
    );
  }

  FeeEstimates getFeeEstimatesOrThrow() {
    return feeState.maybeWhen(
      success: (feeEstimates) => feeEstimates,
      orElse: () => throw StateError('FeeState is not in a success state'),
    );
  }

  T? getDataOrThrow() {
    return dataState.maybeWhen(
      success: (data) => data,
      orElse: () =>
          throw StateError('TransactionDataState is not in a success state'),
    );
  }

  ComposeStateSuccess<R> getComposeStateOrThrow() {
    return composeState.maybeWhen(
      success: (data) => ComposeStateSuccess(data),
      orElse: () => throw StateError('ComposeState is not in a success state'),
    );
  }

  R getComposeDataOrThrow() {
    return composeState.maybeWhen(
      success: (data) => data,
      orElse: () => throw StateError('ComposeState is not in a success state'),
    );
  }

  TransactionState<T, R> copyWith({
    BalancesState? balancesState,
    FeeState? feeState,
    FeeOption? feeOption,
    TransactionDataState<T>? dataState,
    ComposeState<R>? composeState,
    BroadcastState? broadcastState,
  }) {
    return TransactionState<T, R>(
      balancesState: balancesState ?? this.balancesState,
      feeState: feeState ?? this.feeState,
      feeOption: feeOption ?? this.feeOption,
      dataState: dataState ?? this.dataState,
      composeState: composeState ?? this.composeState,
      broadcastState: broadcastState ?? this.broadcastState,
    );
  }

  @override
  String toString() {
    return 'TransactionState(balancesState: $balancesState, feeState: $feeState, feeOption: $feeOption, dataState: $dataState, composeState: $composeState, broadcastState: $broadcastState)';
  }
}

@freezed
class BalancesState with _$BalancesState {
  const factory BalancesState.initial() = _InitialBalancesState;
  const factory BalancesState.loading() = _LoadingBalancesState;
  const factory BalancesState.error(String message) = _ErrorBalancesState;
  const factory BalancesState.success(MultiAddressBalance balances) =
      _SuccessBalancesState;
}

@freezed
class FeeState with _$FeeState {
  const factory FeeState.initial() = _FeeInitial;
  const factory FeeState.loading() = _FeeLoading;
  const factory FeeState.success(FeeEstimates feeEstimates) = _FeeSuccess;
  const factory FeeState.error(String error) = _FeeError;
}

// generic state to handle any state that may not be common to all transaction types
@freezed
class TransactionDataState<T> with _$TransactionDataState<T> {
  const factory TransactionDataState.initial() = _InitialTransactionDataState;
  const factory TransactionDataState.loading() = _LoadingTransactionDataState;
  const factory TransactionDataState.success(T data) =
      _SuccessTransactionDataState;
  const factory TransactionDataState.error(String error) =
      _ErrorTransactionDataState;
}

@freezed
class ComposeState<T> with _$ComposeState<T> {
  const factory ComposeState.initial() = ComposeStateInitial;
  const factory ComposeState.loading() = ComposeStateLoading;
  const factory ComposeState.error(String error) = ComposeStateError;
  const factory ComposeState.success(T composeData) = ComposeStateSuccess;
}

@freezed
class BroadcastState with _$BroadcastState {
  const factory BroadcastState.initial() = _BroadcastInitial;
  const factory BroadcastState.loading() = _BroadcastLoading;
  const factory BroadcastState.success(BroadcastStateSuccess data) =
      _BroadcastSuccess;
  const factory BroadcastState.error(String error) = _BroadcastError;
}

class BroadcastStateSuccess {
  final String txHex;
  final String txHash;

  BroadcastStateSuccess({required this.txHex, required this.txHash});
}
