import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/compose_base/shared/sign_and_broadcast_tx.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_bloc.dart';
import 'package:horizon/presentation/screens/update_issuance/bloc/update_issuance_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:logger/logger.dart';

class UpdateIssuanceEventParams extends ComposeIssuanceEventParams {
  final IssuanceActionType issuanceActionType;
  final String? destination;

  UpdateIssuanceEventParams({
    required super.name,
    required super.quantity,
    required super.description,
    required super.divisible,
    required super.lock,
    required super.reset,
    required this.issuanceActionType,
    this.destination,
  });
}

class UpdateIssuanceBloc extends ComposeBaseBloc<UpdateIssuanceState> {
  final Logger logger = Logger();
  final AssetRepository assetRepository;
  final AddressRepository addressRepository;
  final BalanceRepository balanceRepository;
  final ComposeRepository composeRepository;
  final UtxoRepository utxoRepository;
  final AccountRepository accountRepository;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final TransactionService transactionService;
  final BitcoindService bitcoindService;
  final TransactionRepository transactionRepository;
  final TransactionLocalRepository transactionLocalRepository;
  final BitcoinRepository bitcoinRepository;
  final AnalyticsService analyticsService;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;

  UpdateIssuanceBloc({
    required this.assetRepository,
    required this.addressRepository,
    required this.balanceRepository,
    required this.composeRepository,
    required this.utxoRepository,
    required this.accountRepository,
    required this.walletRepository,
    required this.encryptionService,
    required this.addressService,
    required this.transactionService,
    required this.bitcoindService,
    required this.transactionRepository,
    required this.transactionLocalRepository,
    required this.bitcoinRepository,
    required this.analyticsService,
    required this.getFeeEstimatesUseCase,
    required this.composeTransactionUseCase,
  }) : super(UpdateIssuanceState(
          submitState: const SubmitInitial(),
          feeOption: FeeOption.Medium(),
          balancesState: const BalancesState.initial(),
          feeState: const FeeState.initial(),
          assetState: const AssetState.initial(),
        ));

  @override
  void onChangeFeeOption(ChangeFeeOption event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
  }

  @override
  void onFetchFormData(FetchFormData event, emit) async {
    if (event.assetName == null || event.currentAddress == null) {
      return;
    }

    emit(state.copyWith(
      balancesState: const BalancesState.loading(),
      submitState: const SubmitInitial(),
      assetState: const AssetState.loading(),
    ));

    final Asset asset;
    late FeeEstimates feeEstimates;

    try {
      asset = await assetRepository.getAssetVerbose(event.assetName!);
    } catch (e) {
      emit(state.copyWith(assetState: AssetState.error(e.toString())));
      return;
    }

    try {
      feeEstimates = await getFeeEstimatesUseCase.call(
        targets: (1, 3, 6),
      );
    } catch (e) {
      emit(state.copyWith(feeState: FeeState.error(e.toString())));
      return;
    }

    emit(state.copyWith(
      assetState: AssetState.success(asset),
      balancesState: const BalancesState.success([]),
      feeState: FeeState.success(feeEstimates),
    ));
  }

  @override
  void onComposeTransaction(ComposeTransactionEvent event, emit) async {
    emit((state).copyWith(submitState: const SubmitInitial(loading: true)));

    try {
      final feeRate = _getFeeRate();
      final source = event.sourceAddress;
      final name = event.params.name;
      final quantity = event.params.quantity;
      final divisible = event.params.divisible;
      final lock = event.params.lock;
      final reset = event.params.reset;
      final description = event.params.description;
      final destination = event.params.destination;

      final composeResponse = await composeTransactionUseCase
          .call<ComposeIssuanceParams, ComposeIssuanceResponseVerbose>(
        source: source,
        feeRate: feeRate,
        params: ComposeIssuanceParams(
          source: source,
          name: name,
          quantity: quantity,
          divisible: divisible,
          lock: lock,
          reset: reset,
          description: description,
          transferDestination: destination,
        ),
        composeFn: composeRepository.composeIssuanceVerbose,
      );

      final composed = composeResponse.$1;
      final virtualSize = composeResponse.$2;

      emit(state.copyWith(
          submitState: SubmitComposingTransaction<
              ComposeIssuanceResponseVerbose, ComposeIssuanceEventParams>(
        composeTransaction: composed,
        fee: composed.btcFee,
        feeRate: feeRate,
        virtualSize: virtualSize.virtualSize,
        adjustedVirtualSize: virtualSize.adjustedVirtualSize,
      )));
    } on ComposeTransactionException catch (e) {
      emit(state.copyWith(
          submitState: SubmitInitial(loading: false, error: e.message)));
    } catch (e) {
      emit(state.copyWith(
          submitState: SubmitInitial(
              loading: false,
              error: 'An unexpected error occurred: ${e.toString()}')));
    }
  }

  @override
  void onFinalizeTransaction(FinalizeTransactionEvent event, emit) async {
    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeIssuanceResponseVerbose>(
      loading: false,
      error: null,
      composeTransaction: event.composeTransaction,
      fee: event.fee,
    )));
  }

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, emit) async {
    await signAndBroadcastTransaction<ComposeIssuanceResponseVerbose,
            UpdateIssuanceState>(
        state: state,
        emit: emit,
        password: event.password,
        addressRepository: addressRepository,
        accountRepository: accountRepository,
        walletRepository: walletRepository,
        utxoRepository: utxoRepository,
        encryptionService: encryptionService,
        addressService: addressService,
        transactionService: transactionService,
        bitcoindService: bitcoindService,
        composeRepository: composeRepository,
        transactionRepository: transactionRepository,
        transactionLocalRepository: transactionLocalRepository,
        analyticsService: analyticsService,
        logger: logger,
        extractParams: () {
          final issuanceParams = (state.submitState
                  as SubmitFinalizing<ComposeIssuanceResponseVerbose>)
              .composeTransaction;
          final source = issuanceParams.params.source;
          final rawTx = issuanceParams.rawtransaction;
          final destination =
              issuanceParams.params.transferDestination ?? source;
          final quantity = issuanceParams.params.quantity;
          final asset = issuanceParams.params.asset;

          return (source, rawTx, destination, quantity, asset);
        },
        successAction:
            (txHex, txHash, source, destination, quantity, asset) async {
          TransactionInfo txInfo = await transactionRepository.getInfo(txHex);

          await transactionLocalRepository.insert(txInfo.copyWith(
            hash: txHash,
          ));

          logger.d('issue broadcasted txHash: $txHash');

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex, sourceAddress: source!)));

          analyticsService.trackEvent('broadcast_tx_issue');
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
