import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';
import 'package:horizon/presentation/screens/send/bloc/send_event.dart';
import 'package:horizon/presentation/screens/send/bloc/send_state.dart';

class SendBloc extends Bloc<TransactionEvent, SendState> {
  SendBloc() : super(const SendState()) {
    on<SendDependenciesRequested>(_onDependenciesRequested);
    on<SendTransactionComposed>(_onTransactionComposed);
    on<SendTransactionSubmitted>(_onTransactionSubmitted);
    on<SendTransactionSigned>(_onTransactionSigned);
  }

  void _onDependenciesRequested(
    SendDependenciesRequested event,
    Emitter<SendState> emit,
  ) {
    // Just set loading to false - in a real implementation you would load dependencies
    emit(state.copyWith(isLoading: false));
    print('SendDependenciesRequested');
  }

  void _onTransactionComposed(
    SendTransactionComposed event,
    Emitter<SendState> emit,
  ) {
    print('SendTransactionComposed');
    // Handle business logic for the first step completion
    // No navigation/step management here

    // In a real app, you might validate inputs, prepare transaction data, etc.
    emit(state.copyWith()); // Just emit current state for now
  }

  void _onTransactionSubmitted(
    SendTransactionSubmitted event,
    Emitter<SendState> emit,
  ) {
    print('SendTransactionSubmitted');
    // Handle business logic for the second step completion
    // No navigation/step management here

    // In a real app, you might calculate fees, prepare signature, etc.
    emit(state.copyWith()); // Just emit current state for now
  }

  void _onTransactionSigned(
    SendTransactionSigned event,
    Emitter<SendState> emit,
  ) {
    print('SendTransactionSigned');
    // Simulate transaction submission
    emit(state.copyWith(isLoading: true));

    // You would handle the actual transaction here
    Future.delayed(const Duration(seconds: 1), () {
      emit(state.copyWith(isLoading: false));
      // You would handle success state here
    });
  }
}
