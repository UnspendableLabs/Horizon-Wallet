import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/screens/transactions/send/bloc/send_event.dart';

/// Send transaction data to be stored in the TransactionState.success state
class SendData {
  final String? destinationAddress;
  final String? amount;

  const SendData({
    this.destinationAddress,
    this.amount,
  });

  SendData copyWith({
    String? destinationAddress,
    String? amount,
  }) {
    return SendData(
      destinationAddress: destinationAddress ?? this.destinationAddress,
      amount: amount ?? this.amount,
    );
  }
}

class SendBloc extends Bloc<TransactionEvent, TransactionState<SendData>> {
  final BalanceRepository balanceRepository;

  SendBloc({
    required this.balanceRepository,
  }) : super(const TransactionState.initial()) {
    on<SendDependenciesRequested>(_onDependenciesRequested);
    on<SendTransactionComposed>(_onTransactionComposed);
    on<SendTransactionSubmitted>(_onTransactionSubmitted);
  }

  void _onDependenciesRequested(
    SendDependenciesRequested event,
    Emitter<TransactionState<SendData>> emit,
  ) async {
    // First, emit loading state
    emit(const TransactionState.loading());

    try {
      // Fetch the balances
      final balances = await balanceRepository.getBalancesForAddressesAndAsset(
          event.addresses, event.assetName, BalanceType.address);

      // Emit success state with balances
      emit(TransactionState.success(balances: balances));
    } catch (e) {
      // Emit error state with error message
      emit(TransactionState.error(e.toString()));
    }

    print('SendDependenciesRequested');
  }

  void _onTransactionComposed(
    SendTransactionComposed event,
    Emitter<TransactionState<SendData>> emit,
  ) {
    print('SendTransactionComposed');

    // Get the current state data
    final currentData = state.maybeWhen(
      success: (balances, data) => data ?? const SendData(),
      orElse: () => const SendData(),
    );

    // Update the data with new values
    final updatedData = currentData.copyWith(
      destinationAddress: event.destinationAddress,
      amount: event.amount,
    );

    // Preserve the current state's balances
    state.maybeWhen(
      success: (balances, _) {
        emit(TransactionState.success(balances: balances, data: updatedData));
      },
      orElse: () {},
    );
  }

  void _onTransactionSubmitted(
    SendTransactionSubmitted event,
    Emitter<TransactionState<SendData>> emit,
  ) {
    print('SendTransactionSubmitted');

    // First indicate that we're loading
    emit(const TransactionState.loading());

    // In a real implementation, you would make an API call here
    // For now, we'll just simulate success after a delay

    // In a real implementation, you might want to:
    // 1. Get the current data from the previous state
    // 2. Submit the transaction to the blockchain
    // 3. Emit success or error state based on the result
  }
}
