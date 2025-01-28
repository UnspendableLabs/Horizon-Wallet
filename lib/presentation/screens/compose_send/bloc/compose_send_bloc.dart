import 'package:horizon/common/uuid.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/get_max_send_quantity.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_event.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';

class ComposeSendEventParams {
  final String destinationAddress;
  final int quantity;
  final String asset;

  ComposeSendEventParams({
    required this.destinationAddress,
    required this.quantity,
    required this.asset,
  });
}

class ComposeSendBloc extends ComposeBaseBloc<ComposeSendState> {
  final txName = 'send';
  final bool passwordRequired;
  final InMemoryKeyRepository inMemoryKeyRepository;
  final BalanceRepository balanceRepository;
  final ComposeRepository composeRepository;
  final AnalyticsService analyticsService;
  final TransactionService transactionService;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final Logger logger;

  ComposeSendBloc({
    required this.inMemoryKeyRepository,
    required this.passwordRequired,
    required this.balanceRepository,
    required this.composeRepository,
    required this.analyticsService,
    required this.transactionService,
    required this.getFeeEstimatesUseCase,
    required this.composeTransactionUseCase,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.logger,
  }) : super(
          ComposeSendState(
            feeOption: FeeOption.Medium(),
            submitState: const FormStep(),
            feeState: const FeeState.initial(),
            balancesState: const BalancesState.initial(),
            maxValue: const MaxValueState.initial(),
            sendMax: false,
            quantity: "",
          ),
          composePage: 'compose_send',
        ) {
    // Register additional event handlers specific to sending
    on<ToggleSendMaxEvent>(_onToggleSendMaxEvent);
    on<ChangeAsset>(_onChangeAsset);
    on<ChangeDestination>(_onChangeDestination);
    on<ChangeQuantity>(_onChangeQuantity);
  }

  _onChangeAsset(event, emit) async {
    final asset = event.asset;
    emit(state.copyWith(
        submitState: const FormStep(),
        asset: asset,
        sendMax: false,
        quantity: "",
        composeSendError: null,
        feeOption: FeeOption.Medium()));
  }

  _onChangeDestination(event, emit) async {
    final destination = event.value;
    emit(state.copyWith(
        submitState: const FormStep(),
        destination: destination,
        composeSendError: null));
  }

  _onChangeQuantity(event, emit) async {
    final quantity = event.value;

    emit(state.copyWith(
        submitState: const FormStep(),
        quantity: quantity,
        sendMax: false,
        composeSendError: null,
        maxValue: const MaxValueState.initial()));
  }

  _onToggleSendMaxEvent(event, emit) async {
    // return early if fee estimates haven't loaded
    FeeEstimates? feeEstimates =
        state.feeState.maybeWhen(success: (value) => value, orElse: () => null);
    if (feeEstimates == null) {
      return;
    }

    final value = event.value;
    emit(state.copyWith(
        submitState: const FormStep(), sendMax: value, composeSendError: null));

    if (!value) {
      emit(state.copyWith(maxValue: const MaxValueState.initial()));
    }

    emit(state.copyWith(maxValue: const MaxValueState.loading()));

    try {
      final source = state.source!;
      final asset = state.asset ?? "BTC";
      final feeRate = switch (state.feeOption) {
        FeeOption.Fast() => feeEstimates.fast,
        FeeOption.Medium() => feeEstimates.medium,
        FeeOption.Slow() => feeEstimates.slow,
        FeeOption.Custom(fee: var fee) => fee,
      };

      final max = await GetMaxSendQuantity(
        source: source,
        // destination: state.destination!,
        asset: asset,
        feeRate: feeRate,
        balanceRepository: balanceRepository,
        composeRepository: composeRepository,
        transactionService: transactionService,
      ).call();

      emit(state.copyWith(maxValue: MaxValueState.success(max)));
    } catch (e) {
      emit(state.copyWith(
          sendMax: false,
          composeSendError: "Insufficient funds",
          maxValue: MaxValueState.error(e.toString())));
    }
  }

  @override
  onFeeOptionChanged(event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value, composeSendError: null));

    if (!state.sendMax) return;

    FeeEstimates? feeEstimates =
        state.feeState.maybeWhen(success: (value) => value, orElse: () => null);
    if (feeEstimates == null) {
      return;
    }

    if (state.destination == null) {
      emit(state.copyWith(
          sendMax: false,
          submitState: const FormStep(),
          composeSendError: "Set destination",
          maxValue: const MaxValueState.initial()));
      return;
    }

    emit(state.copyWith(maxValue: const MaxValueState.loading()));

    try {
      final source = state.source!;
      final asset = state.asset ?? "BTC";
      final feeRate = switch (state.feeOption) {
        FeeOption.Fast() => feeEstimates.fast,
        FeeOption.Medium() => feeEstimates.medium,
        FeeOption.Slow() => feeEstimates.slow,
        FeeOption.Custom(fee: var fee) => fee,
      };

      final max = await GetMaxSendQuantity(
        source: source,
        // destination: state.destination!,
        asset: asset,
        feeRate: feeRate,
        balanceRepository: balanceRepository,
        composeRepository: composeRepository,
        transactionService: transactionService,
      ).call();

      emit(state.copyWith(maxValue: MaxValueState.success(max)));
    } catch (e) {
      emit(state.copyWith(
          sendMax: false,
          composeSendError: "Insufficient funds",
          maxValue: MaxValueState.error(e.toString())));
    }
  }

  @override
  onAsyncFormDependenciesRequested(event, emit) async {
    emit(state.copyWith(
      balancesState: const BalancesState.loading(),
      submitState: const FormStep(),
      source: event.currentAddress, // TODO: setting address this way is smell
    ));

    late List<Balance> balances;
    late FeeEstimates feeEstimates;
    try {
      List<String> addresses = [event.currentAddress!];

      balances =
          await balanceRepository.getBalancesForAddress(addresses[0], true);
    } catch (e) {
      emit(state.copyWith(
          balancesState: BalancesState.error(e.toString()),
          submitState: const FormStep()));
      return;
    }
    try {
      feeEstimates = await getFeeEstimatesUseCase.call();
    } catch (e) {
      emit(state.copyWith(
          feeState: FeeState.error(e.toString()),
          submitState: const FormStep()));
      return;
    }

    emit(state.copyWith(
        balancesState: BalancesState.success(balances),
        feeState: FeeState.success(feeEstimates),
        submitState: const FormStep()));
  }

  @override
  onReviewSubmitted(event, emit) async {
    if (passwordRequired) {
      emit(state.copyWith(
          submitState: PasswordStep<ComposeSendResponse>(
              loading: false,
              error: null,
              composeTransaction: event.composeTransaction,
              fee: event.fee)));
      return;
    }

    final s = (state.submitState as ReviewStep<ComposeSendResponse, void>);

    try {
      emit(state.copyWith(submitState: s.copyWith(loading: true)));

      final inMemoryKey = await inMemoryKeyRepository.get();

      await signAndBroadcastTransactionUseCase.call(
          decryptionStrategy: InMemoryKey(inMemoryKey!),
          source: s.composeTransaction.params.source,
          rawtransaction: s.composeTransaction.rawtransaction,
          onSuccess: (txHex, txHash) async {
            await writelocalTransactionUseCase.call(txHex, txHash);

            logger.info('$txName broadcasted txHash: $txHash');
            analyticsService.trackAnonymousEvent('broadcast_tx_$txName',
                properties: {'distinct_id': uuid.v4()});

            emit(state.copyWith(
                submitState: SubmitSuccess(
                    transactionHex: txHex,
                    sourceAddress: s.composeTransaction.params.source)));
          },
          onError: (msg) {
            emit(state.copyWith(
                submitState:
                    s.copyWith(loading: false, error: msg.toString())));
          });
    } catch (e) {
      emit(state.copyWith(
          submitState: s.copyWith(loading: false, error: e.toString())));
    }
  }

  @override
  onFormSubmitted(event, emit) async {
    emit((state).copyWith(submitState: const FormStep(loading: true)));

    try {
      final feeRate = _getFeeRate();
      final source = event.sourceAddress;
      final destination = event.params.destinationAddress;
      final asset = event.params.asset;
      final quantity = event.params.quantity;
      const useEnhancedSend = true;

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

      emit(state.copyWith(
          submitState: ReviewStep<ComposeSendResponse, void>(
        composeTransaction: composeResponse,
        fee: composeResponse.btcFee,
        feeRate: feeRate,
        virtualSize: composeResponse.signedTxEstimatedSize.virtualSize,
        adjustedVirtualSize:
            composeResponse.signedTxEstimatedSize.adjustedVirtualSize,
      )));
    } on ComposeTransactionException catch (e) {
      emit(state.copyWith(
          submitState: FormStep(loading: false, error: e.message)));
    } catch (e) {
      emit(state.copyWith(
          submitState: FormStep(
              loading: false,
              error: e is ComposeTransactionException
                  ? e.message
                  : 'An unexpected error occurred: ${e.toString()}')));
    }
  }

  @override
  void onSignAndBroadcastFormSubmitted(
      SignAndBroadcastFormSubmitted event, emit) async {
    if (state.submitState is! PasswordStep<ComposeSendResponse>) {
      return;
    }

    final s = (state.submitState as PasswordStep<ComposeSendResponse>);
    final compose = s.composeTransaction;
    final fee = s.fee;

    emit(state.copyWith(
        submitState: PasswordStep<ComposeSendResponse>(
      loading: true,
      error: null,
      fee: fee,
      composeTransaction: compose,
    )));

    await signAndBroadcastTransactionUseCase.call(
        decryptionStrategy: Password(event.password),
        source: compose.params.source,
        rawtransaction: compose.rawtransaction,
        onSuccess: (txHex, txHash) async {
          await writelocalTransactionUseCase.call(txHex, txHash);

          logger.info('send broadcasted txHash: $txHash');
          analyticsService.trackAnonymousEvent('broadcast_tx_send',
              properties: {'distinct_id': uuid.v4()});

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex,
                  sourceAddress: compose.params.source)));
        },
        onError: (msg) {
          emit(state.copyWith(
              submitState: PasswordStep<ComposeSendResponse>(
            loading: false,
            error: msg,
            fee: fee,
            composeTransaction: compose,
          )));
        });
  }

  int _getFeeRate() {
    FeeEstimates feeEstimates = state.feeState.feeEstimatesOrThrow();
    return switch (state.feeOption) {
      FeeOption.Fast() => feeEstimates.fast,
      FeeOption.Medium() => feeEstimates.medium,
      FeeOption.Slow() => feeEstimates.slow,
      FeeOption.Custom(fee: var fee) => fee,
    };
  }
}
