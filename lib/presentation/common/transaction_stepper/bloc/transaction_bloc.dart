import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';

/// Interface that all transaction blocs must implement
abstract interface class TransactionBlocInterface<
    T extends TransactionState<T, R>, R> {
  /// Handle dependencies requested when the page is loaded
  Future<void> onDependenciesRequested(
      DependenciesRequested event, Emitter<T> emit);

  /// Handle transaction composition (moving from input to confirmation)
  void onTransactionComposed(TransactionComposed event, Emitter<T> emit);

  /// Handle transaction submission (moving from confirmation to submission)
  void onTransactionBroadcasted(TransactionBroadcasted event, Emitter<T> emit);

  /// Handle fee option selection (optional override)
  void onFeeOptionSelected(FeeOptionSelected event, Emitter<T> emit) {}
}

/// Base bloc for transaction flows
abstract class TransactionBloc<T extends TransactionState<T, R>, R>
    extends Bloc<TransactionEvent, T>
    implements TransactionBlocInterface<T, R> {
  final String transactionType;
  late final ErrorService _errorService;

  TransactionBloc(
    super.initialState, {
    required this.transactionType,
  }) {
    _errorService = GetIt.I.get<ErrorService>();

    on<DependenciesRequested>((event, emit) async {
      await onDependenciesRequested(event, emit);
    });

    // Set up handler for fee option selection
    on<FeeOptionSelected>((event, emit) {
      onFeeOptionSelected(event, emit);
    });

    on<TransactionComposed>(onTransactionComposed);
    on<TransactionBroadcasted>(onTransactionBroadcasted);
  }

  @override
  Future<void> onDependenciesRequested(
      DependenciesRequested event, Emitter<T> emit);

  @override
  void onTransactionComposed(TransactionComposed event, Emitter<T> emit);

  @override
  void onTransactionBroadcasted(TransactionBroadcasted event, Emitter<T> emit);

  @override
  void onFeeOptionSelected(FeeOptionSelected event, Emitter<T> emit);
}

num getFeeRate(TransactionState<dynamic, dynamic> state) {
  FeeEstimates feeEstimates = state.getFeeEstimatesOrThrow();
  return switch (state.feeOption) {
    FeeOption.Fast() => feeEstimates.fast,
    FeeOption.Medium() => feeEstimates.medium,
    FeeOption.Slow() => feeEstimates.slow,
    FeeOption.Custom(fee: var fee) => fee,
  };
}
