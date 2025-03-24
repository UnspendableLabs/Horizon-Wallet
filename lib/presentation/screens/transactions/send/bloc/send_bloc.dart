import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/fee_option.dart' as fee_option;
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_bloc.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/screens/transactions/send/bloc/send_event.dart';
import 'package:horizon/presentation/screens/transactions/send/bloc/send_state.dart';

/// Send transaction data to be stored in the TransactionState.success state

class SendBloc extends Bloc<TransactionEvent, TransactionState<SendState>> {
  final BalanceRepository balanceRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final ComposeRepository composeRepository;
  SendBloc({
    required this.balanceRepository,
    required this.getFeeEstimatesUseCase,
    required this.composeTransactionUseCase,
    required this.composeRepository,
  }) : super(TransactionState<SendState>(
          feeOption: fee_option.Medium(),
          dataState: const TransactionDataState.initial(),
          balancesState: const BalancesState.initial(),
          feeState: const FeeState.initial(),
        )) {
    on<SendDependenciesRequested>(_onDependenciesRequested);
    on<SendTransactionComposed>(_onTransactionComposed);
    on<SendTransactionSubmitted>(_onTransactionSubmitted);
    on<FeeOptionSelected>(_onFeeOptionSelected);
  }

  void _onDependenciesRequested(
    SendDependenciesRequested event,
    Emitter<TransactionState<SendState>> emit,
  ) async {
    // First, emit loading state
    emit(state.copyWith(
      balancesState: const BalancesState.loading(),
      feeState: const FeeState.loading(),
      dataState: const TransactionDataState.loading(),
    ));

    try {
      // Fetch the balances
      final balances = await balanceRepository.getBalancesForAddressesAndAsset(
          event.addresses, event.assetName, BalanceType.address);

      final feeEstimates = await getFeeEstimatesUseCase.call();

      // Emit success state with balances
      emit(state.copyWith(
          balancesState: BalancesState.success(balances),
          feeState: FeeState.success(feeEstimates),
          dataState: TransactionDataState.success(SendState())));
      print(state.toString());
    } catch (e) {
      // Emit error state with error message
      emit(state.copyWith(
          balancesState: BalancesState.error(e.toString()),
          feeState: FeeState.error(e.toString())));
    }

    print('SendDependenciesRequested');
  }

  void _onTransactionComposed(
    SendTransactionComposed event,
    Emitter<TransactionState<SendState>> emit,
  ) async {
    print('SendTransactionComposed');

    // First, emit loading state for the compose operation
    emit(state.copyWith(composeState: const ComposeStateLoading()));
    if (event.sourceAddress.isEmpty) {
      emit(state.copyWith(
        composeState: const ComposeStateError('Source address is required'),
      ));
      return;
    }

    try {
      final feeRate = getFeeRate(state);
      final source = event.sourceAddress;
      final destination = event.destinationAddress;
      final asset = event.asset;
      final quantity = event.quantity;

      final composeResponse = await composeTransactionUseCase
          .call<ComposeSendParams, ComposeSendResponse>(
        feeRate: feeRate,
        source: source,
        params: ComposeSendParams(
          source: source,
          destination: destination,
          asset: asset,
          quantity: quantity,
        ),
        composeFn: composeRepository.composeSendVerbose,
      );

      // Create a map with all the compose data to store in ComposeState
      final composeData = {
        'composeTransaction': composeResponse,
        'fee': composeResponse.btcFee,
        'feeRate': feeRate,
        'virtualSize': composeResponse.signedTxEstimatedSize.virtualSize,
        'adjustedVirtualSize':
            composeResponse.signedTxEstimatedSize.adjustedVirtualSize,
      };

      emit(state.copyWith(
        composeState: ComposeStateSuccess(composeData),
      ));
      print(state.toString());
    } on ComposeTransactionException catch (e) {
      emit(state.copyWith(
        composeState: ComposeStateError(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        composeState: ComposeStateError(e is ComposeTransactionException
            ? e.message
            : 'An unexpected error occurred: ${e.toString()}'),
      ));
    }
  }

  void _onTransactionSubmitted(
    SendTransactionSubmitted event,
    Emitter<TransactionState<SendState>> emit,
  ) {
    print('SendTransactionSubmitted');

    // First indicate that we're loading
    // emit(const TransactionState.loading());

    // In a real implementation, you would make an API call here
    // For now, we'll just simulate success after a delay

    // In a real implementation, you might want to:
    // 1. Get the current data from the previous state
    // 2. Submit the transaction to the blockchain
    // 3. Emit success or error state based on the result
  }

  void _onFeeOptionSelected(
    FeeOptionSelected event,
    Emitter<TransactionState<SendState>> emit,
  ) {
    // Update the fee option in the state
    emit(state.copyWith(
      feeOption: event.feeOption,
    ));
    print(state.toString());
  }
}
