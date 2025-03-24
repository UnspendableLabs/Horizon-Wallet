import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';

part 'transaction_state.freezed.dart';

class TransactionState<T> {
  final BalancesState balancesState;
  final FeeState feeState;
  final FeeOption feeOption;
  final TransactionDataState<T> dataState;
  final ComposeState composeState;

  TransactionState({
    required this.balancesState,
    required this.feeState,
    required this.feeOption,
    required this.dataState,
    this.composeState = const ComposeStateInitial(),
  });

  String? get error {
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

    final composeError = composeState is ComposeStateError
        ? (composeState as ComposeStateError).error
        : null;

    return balancesError ?? feeError ?? dataError ?? composeError;
  }

  bool get loadingFetch {
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

  bool get initial {
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

  bool get loadingCompose {
    return composeState is ComposeStateLoading;
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

  Map<String, dynamic>? getComposeDataOrThrow() {
    if (composeState is ComposeStateSuccess) {
      return (composeState as ComposeStateSuccess).composeData;
    }
    throw StateError('ComposeState is not in a success state');
  }

  TransactionState<T> copyWith({
    BalancesState? balancesState,
    FeeState? feeState,
    FeeOption? feeOption,
    TransactionDataState<T>? dataState,
    ComposeState? composeState,
  }) {
    return TransactionState<T>(
      balancesState: balancesState ?? this.balancesState,
      feeState: feeState ?? this.feeState,
      feeOption: feeOption ?? this.feeOption,
      dataState: dataState ?? this.dataState,
      composeState: composeState ?? this.composeState,
    );
  }

  @override
  String toString() {
    return 'TransactionState(balancesState: $balancesState, feeState: $feeState, feeOption: $feeOption, dataState: $dataState, composeState: $composeState)';
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

// State to track composed transaction data across all transaction types
sealed class ComposeState {
  const ComposeState();
}

class ComposeStateInitial extends ComposeState {
  const ComposeStateInitial();
}

class ComposeStateLoading extends ComposeState {
  const ComposeStateLoading();
}

class ComposeStateError extends ComposeState {
  final String error;
  const ComposeStateError(this.error);
}

class ComposeStateSuccess extends ComposeState {
  final Map<String, dynamic> composeData;
  const ComposeStateSuccess(this.composeData);
}
