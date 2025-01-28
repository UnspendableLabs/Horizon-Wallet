import 'package:collection/collection.dart';
import 'package:horizon/common/format.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_attach_utxo.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/block_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/bloc/compose_attach_utxo_state.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/usecase/fetch_form_data.dart';

class ComposeAttachUtxoEventParams {
  final String asset;
  final int quantity;

  ComposeAttachUtxoEventParams({
    required this.asset,
    required this.quantity,
  });
}

class ComposeAttachUtxoBloc extends ComposeBaseBloc<ComposeAttachUtxoState> {
  final ComposeRepository composeRepository;
  final AnalyticsService analyticsService;
  final Logger logger;
  final FetchComposeAttachUtxoFormDataUseCase
      fetchComposeAttachUtxoFormDataUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final BlockRepository blockRepository;
  final CacheProvider cacheProvider;
  final String? initialFairminterTxHash;

  ComposeAttachUtxoBloc({
    required this.logger,
    required this.fetchComposeAttachUtxoFormDataUseCase,
    required this.composeTransactionUseCase,
    required this.composeRepository,
    required this.analyticsService,
    required this.signAndBroadcastTransactionUseCase,
    required this.writelocalTransactionUseCase,
    required this.blockRepository,
    required this.cacheProvider,
    this.initialFairminterTxHash,
  }) : super(
          ComposeAttachUtxoState(
            submitState: const FormStep(),
            feeOption: FeeOption.Medium(),
            balancesState: const BalancesState.initial(),
            feeState: const FeeState.initial(),
            xcpFeeEstimate: '',
          ),
          composePage: 'compose_attach_utxo',
        );

  @override
  Future<void> onAsyncFormDependenciesRequested(
      AsyncFormDependenciesRequested event, emit) async {
    emit(state.copyWith(
      balancesState: const BalancesState.loading(),
      feeState: const FeeState.loading(),
      submitState: const FormStep(),
    ));

    try {
      final (feeEstimates, balances, xcpFeeEstimate) =
          await fetchComposeAttachUtxoFormDataUseCase
              .call(event.currentAddress!);

      // there is an xcp fee associated with attaching utxos
      // we need to check that the user has enough xcp to pay for the fee
      final xcpBalance =
          balances.firstWhereOrNull((balance) => balance.asset == 'XCP');
      final String xcpFeeEstimateString = xcpFeeEstimate > 0
          ? (xcpFeeEstimate / SATOSHI_RATE).toStringAsFixed(8)
          : '0';

      if (xcpBalance == null) {
        if (xcpFeeEstimate > 0) {
          emit(state.copyWith(
            balancesState: BalancesState.error(
                'Insufficient XCP balance for attach. Required: $xcpFeeEstimateString. Current XCP balance: 0'),
            xcpFeeEstimate: xcpFeeEstimateString,
          ));
          return;
        } else {
          emit(state.copyWith(
            balancesState: BalancesState.success(balances),
            feeState: FeeState.success(feeEstimates),
            xcpFeeEstimate: xcpFeeEstimateString,
          ));
          return;
        }
      }
      if (xcpBalance.quantity < xcpFeeEstimate) {
        emit(state.copyWith(
          balancesState: BalancesState.error(
              'Insufficient XCP balance for attach. Required: $xcpFeeEstimateString. Current XCP balance: ${xcpBalance.quantityNormalized}'),
          xcpFeeEstimate: xcpFeeEstimateString,
        ));
        return;
      }
      emit(state.copyWith(
        balancesState: BalancesState.success(balances),
        feeState: FeeState.success(feeEstimates),
        xcpFeeEstimate: xcpFeeEstimateString,
      ));
    } on FetchFeeEstimatesException catch (e) {
      emit(state.copyWith(
        feeState: FeeState.error(e.message),
      ));
    } on FetchBalanceException catch (e) {
      emit(state.copyWith(
        balancesState: BalancesState.error(e.message),
      ));
    } on FetchAttachXcpFeesException catch (e) {
      emit(state.copyWith(
        balancesState: BalancesState.error(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        balancesState: BalancesState.error(
            'An unexpected error occurred: ${e.toString()}'),
        feeState:
            FeeState.error('An unexpected error occurred: ${e.toString()}'),
      ));
    }
  }

  @override
  void onFeeOptionChanged(FeeOptionChanged event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
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

  @override
  void onFormSubmitted(FormSubmitted event, emit) async {
    emit((state).copyWith(submitState: const FormStep(loading: true)));

    try {
      final feeRate = _getFeeRate();
      final source = event.sourceAddress;
      final asset = event.params.asset;
      final quantity = event.params.quantity;

      final composeResponse = await composeTransactionUseCase
          .call<ComposeAttachUtxoParams, ComposeAttachUtxoResponse>(
              feeRate: feeRate,
              source: source,
              params: ComposeAttachUtxoParams(
                  address: source, quantity: quantity, asset: asset),
              composeFn: composeRepository.composeAttachUtxo);

      emit(state.copyWith(
          submitState: ReviewStep<ComposeAttachUtxoResponse, void>(
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
              error: 'An unexpected error occurred: ${e.toString()}')));
    }
  }

  @override
  void onReviewSubmitted(ReviewSubmitted event, emit) async {
    emit(state.copyWith(
        submitState: PasswordStep<ComposeAttachUtxoResponse>(
      loading: false,
      error: null,
      composeTransaction: event.composeTransaction,
      fee: event.fee,
    )));
  }

  @override
  void onSignAndBroadcastFormSubmitted(
      SignAndBroadcastFormSubmitted event, emit) async {
    if (state.submitState is! PasswordStep<ComposeAttachUtxoResponse>) {
      return;
    }

    final s = (state.submitState as PasswordStep<ComposeAttachUtxoResponse>);
    final compose = s.composeTransaction;
    final fee = s.fee;

    emit(state.copyWith(
        submitState: PasswordStep<ComposeAttachUtxoResponse>(
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

          // Use the source address as the key and tx hash as the value
          final sourceAddress = compose.params.source;

          // Fetch existing tx hashes for the source address
          final txHashes = cacheProvider.getValue(sourceAddress) ?? [];

          // Add the new tx hash
          txHashes.add(txHash);

          // Save back to the cache
          await cacheProvider.setObject(sourceAddress, txHashes);

          logger.info('attach utxo broadcasted txHash: $txHash');
          analyticsService.trackAnonymousEvent('broadcast_tx_attach_utxo',
              properties: {'distinct_id': uuid.v4()});

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex,
                  sourceAddress: compose.params.source)));
        },
        onError: (msg) {
          emit(state.copyWith(
              submitState: PasswordStep<ComposeAttachUtxoResponse>(
            loading: false,
            error: msg,
            fee: fee,
            composeTransaction: compose,
          )));
        });
  }
}
