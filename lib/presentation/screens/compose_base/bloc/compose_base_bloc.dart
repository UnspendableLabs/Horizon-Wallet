import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/screens/compose_base/bloc/compose_base_state.dart';

abstract interface class ComposeBaseBlocInterface<T extends ComposeStateBase> {
  void onFetchFormData(FetchFormData event, Emitter<T> emit);
  void onChangeFeeOption(ChangeFeeOption event, Emitter<T> emit);
  void onComposeTransaction(ComposeTransactionEvent event, Emitter<T> emit);
  void onFinalizeTransaction(FinalizeTransactionEvent event, Emitter<T> emit);
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, Emitter<T> emit);
}

abstract class ComposeBaseBloc<T extends ComposeStateBase>
    extends Bloc<ComposeBaseEvent, T> implements ComposeBaseBlocInterface<T> {
  ComposeBaseBloc(super.initialState) {
    on<FetchFormData>(onFetchFormData);
    on<ChangeFeeOption>(onChangeFeeOption);
    on<ComposeTransactionEvent>(onComposeTransaction);
    on<FinalizeTransactionEvent>(onFinalizeTransaction);
    on<SignAndBroadcastTransactionEvent>(onSignAndBroadcastTransaction);
  }

  @override
  void onFetchFormData(FetchFormData event, Emitter<T> emit);

  @override
  void onChangeFeeOption(ChangeFeeOption event, Emitter<T> emit);

  @override
  void onComposeTransaction(ComposeTransactionEvent event, Emitter<T> emit);
  @override
  void onFinalizeTransaction(FinalizeTransactionEvent event, Emitter<T> emit);

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, Emitter<T> emit);
}

mixin ComposeBaseBlocLogicMixin on Bloc<ComposeBaseEvent, ComposeStateBase>
    implements ComposeBaseBlocInterface {
  @override
  void onFetchFormData(FetchFormData event, emit) {
    // Default implementation
    // This can be overridden in child classes if needed
  }

  // Helper method to yield to child-specific logic
  void yieldToChildLogicFetchFormData(
      FetchFormData event, Emitter<ComposeStateBase> emit) {
    // Child classes can override this method to provide specific logic
  }

  @override
  void onChangeFeeOption(
      ChangeFeeOption event, Emitter<ComposeStateBase> emit) {
    // Default implementation
    // This can be overridden in child classes if needed
  }

  // Helper method to yield to child-specific logic
  void yieldToChildLogicChangeFeeOption(
      ChangeFeeOption event, Emitter<ComposeStateBase> emit) {}

  @override
  void onFinalizeTransaction(
      FinalizeTransactionEvent event, Emitter<ComposeStateBase> emit) {
    // Default implementation
    // This can be overridden in child classes if needed
  }

  // Helper method to yield to child-specific logic
  void yieldToChildLogicFinalizeTransaction(
      FinalizeTransactionEvent event, Emitter<ComposeStateBase> emit) {}

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, Emitter<ComposeStateBase> emit) {
    // Default implementation
    // This can be overridden in child classes if needed
  }

  // Helper method to yield to child-specific logic
  void yieldToChildLogicSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, Emitter<ComposeStateBase> emit) {}
}