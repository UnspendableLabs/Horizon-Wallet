import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';

/// Interface that all transaction blocs must implement
abstract interface class TransactionBlocInterface<
    T extends TransactionState<T>> {
  /// Handle dependencies requested when the page is loaded
  Future<void> onDependenciesRequested(
      DependenciesRequested event, Emitter<T> emit);

  /// Handle transaction composition (moving from input to confirmation)
  void onTransactionComposed(TransactionComposed event, Emitter<T> emit);

  /// Handle transaction submission (moving from confirmation to submission)
  void onTransactionSubmitted(TransactionSubmitted event, Emitter<T> emit);
}

/// Base bloc for transaction flows
abstract class TransactionBloc<T extends TransactionState<T>>
    extends Bloc<TransactionEvent, T> implements TransactionBlocInterface<T> {
  final String transactionType;
  late final ErrorService _errorService;

  TransactionBloc(
    super.initialState, {
    required this.transactionType,
  }) {
    _errorService = GetIt.I.get<ErrorService>();

    on<DependenciesRequested>((event, emit) async {
      _errorService.addBreadcrumb(
        type: 'navigation',
        category: 'transaction',
        message: '$transactionType transaction page opened',
      );

      await onDependenciesRequested(event, emit);
    });

    on<TransactionComposed>(onTransactionComposed);
    on<TransactionSubmitted>(onTransactionSubmitted);
  }

  @override
  Future<void> onDependenciesRequested(
      DependenciesRequested event, Emitter<T> emit);

  @override
  void onTransactionComposed(TransactionComposed event, Emitter<T> emit);

  @override
  void onTransactionSubmitted(TransactionSubmitted event, Emitter<T> emit);
}
